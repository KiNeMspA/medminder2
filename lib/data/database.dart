import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';
part 'database.g.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) => fromDb.split(',').where((e) => e.isNotEmpty).toList();
  @override
  String toSql(List<String> value) => value.join(',');
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  RealColumn get concentration => real()();
  TextColumn get concentrationUnit => text()();
  RealColumn get stockQuantity => real()();
  TextColumn get form => text()();
}

class Doses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  TextColumn get medicationName => text()();
  RealColumn get amount => real()();
  TextColumn get unit => text()();
  DateTimeColumn get time => dateTime()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();
  RealColumn get weight => real().withDefault(const Constant(0.0))();
  TextColumn get name => text().nullable()();
}

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  TextColumn get medicationName => text()();
  IntColumn get doseId => integer().nullable().references(Doses, #id)();
  TextColumn get frequency => text()();
  TextColumn get days => text().map(const StringListConverter())();
  DateTimeColumn get time => dateTime()();
  TextColumn get name => text().withDefault(const Constant(''))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get notificationId => text().nullable()();
}

class DoseHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get doseId => integer().references(Doses, #id)();
  DateTimeColumn get takenAt => dateTime()();
}

@DriftDatabase(tables: [Medications, Doses, Schedules, DoseHistory])
class AppDatabase extends _$AppDatabase {
  final Logger _logger = Logger('AppDatabase');

  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      _logger.info('Upgrading database from schema version $from to $to');
      if (from < 9) {
        await m.addColumn(doses, doses.medicationName);
        await m.addColumn(doses, doses.time);
        await m.addColumn(doses, doses.taken);
        await m.addColumn(schedules, schedules.medicationId);
        await m.addColumn(schedules, schedules.medicationName);
        await m.addColumn(schedules, schedules.notificationsEnabled);
        _logger.info('Added new columns for Doses and Schedules');
      }
      if (from <= 7) {
        await m.addColumn(schedules, schedules.notificationId);
        _logger.info('Added notificationId column to Schedules table');
      }
      if (from <= 6) {
        await m.deleteTable('ScheduleDoses');
        _logger.info('Ensured ScheduleDoses table is dropped');
      }
      if (from <= 5) {
        await m.deleteTable('ScheduleDoses');
        await m.addColumn(schedules, schedules.name);
        await m.alterTable(TableMigration(schedules));
        _logger.info('Dropped ScheduleDoses table, added name to Schedules, made doseId nullable');
      }
      if (from <= 4) {
        await m.createTable(schedules);
        _logger.info('Created Schedules table');
      }
      if (from <= 3) {
        await m.createTable(doseHistory);
        _logger.info('Created DoseHistory table');
      }
      if (from <= 2) {
        await m.createIndex(Index('medications', 'UNIQUE(name)'));
        _logger.info('Added unique constraint to Medications name');
      }
      if (from <= 1) {
        await m.addColumn(doses, doses.name);
        _logger.info('Added name column to Doses table');
      }
    },
  );

  Future<void> addMedication(MedicationsCompanion med) async {
    _logger.info('Adding medication: $med');
    await into(medications).insert(med);
  }

  Future<void> updateMedication(MedicationsCompanion med) async {
    _logger.info('Updating medication: $med');
    await (update(medications)..where((m) => m.id.equals(med.id.value))).write(med);
  }

  Future<Medication?> getMedicationById(int id) async {
    return await (select(medications)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  Future<void> updateMedicationStock(int id, double newQuantity) async {
    _logger.info('Updating medication stock: id=$id, newQuantity=$newQuantity');
    await (update(medications)..where((m) => m.id.equals(id))).write(
      MedicationsCompanion(stockQuantity: Value(newQuantity)),
    );
  }

  Future<List<Medication>> getMedications() => select(medications).get();

  Future<void> deleteMedication(int id) async {
    final doseIds = await (select(doses)..where((d) => d.medicationId.equals(id)))
        .map((d) => d.id)
        .get();
    await (delete(schedules)..where((s) => s.doseId.isIn(doseIds) | s.doseId.isNull())).go();
    await (delete(doses)..where((d) => d.medicationId.equals(id))).go();
    await (delete(medications)..where((m) => m.id.equals(id))).go();
    await _logDatabase();
  }

  Future<int> addDose(DosesCompanion dose) async {
    _logger.info('Adding dose: $dose');
    final doseId = await into(doses).insert(dose);
    await _logDatabase();
    return doseId;
  }

  Future<List<DoseHistory>> getDoseHistory(int doseId) async {
    return (select(doseHistory)..where((tbl) => tbl.doseId.equals(doseId))).get();
  }

  Future<void> updateDose(int id, DosesCompanion dose) async {
    _logger.info('Updating dose: id=$id, $dose');
    await (update(doses)..where((t) => t.id.equals(id))).write(dose);
    await _logDatabase();
  }

  Future<void> markDoseTaken(int id) async {
    _logger.info('Marking dose as taken: id=$id');
    await (update(doses)..where((t) => t.id.equals(id))).write(
      DosesCompanion(taken: const Value(true)),
    );
    await addDoseHistory(DoseHistoryCompanion(
      doseId: Value(id),
      takenAt: Value(DateTime.now()),
    ));
  }

  Future<void> skipDose(int id) async {
    _logger.info('Skipping dose: id=$id');
    await (delete(doses)..where((t) => t.id.equals(id))).go();
  }

  Future<Dose?> getDoseById(int id) async {
    return await (select(doses)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<List<Dose>> getDoses(int medicationId) async {
    final doseList = await (select(doses)..where((d) => d.medicationId.equals(medicationId))).get();
    _logger.info('Doses fetched for medicationId=$medicationId: $doseList');
    return doseList;
  }

  Future<List<Dose>> getAllDoses() async {
    final doseList = await select(doses).get();
    _logger.info('All doses fetched: $doseList');
    return doseList;
  }

  Future<void> deleteDose(int id) async {
    await (update(schedules)..where((s) => s.doseId.equals(id))).write(SchedulesCompanion(doseId: Value(null)));
    await (delete(doseHistory)..where((h) => h.doseId.equals(id))).go();
    await (delete(doses)..where((d) => d.id.equals(id))).go();
    await _logDatabase();
  }

  Future<int> addSchedule(SchedulesCompanion schedule) async {
    _logger.info('Adding schedule: $schedule');
    final scheduleId = await into(schedules).insert(schedule);
    await _logDatabase();
    return scheduleId;
  }

  Future<void> updateSchedule(int id, SchedulesCompanion schedule) async {
    _logger.info('Updating schedule: id=$id, $schedule');
    await (update(schedules)..where((s) => s.id.equals(id))).write(schedule);
    await _logDatabase();
  }

  Future<Schedule?> getScheduleById(int id) async {
    return await (select(schedules)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<Schedule>> getSchedules(int medicationId) async {
    final scheduleList = await (select(schedules)..where((s) => s.medicationId.equals(medicationId))).get();
    _logger.info('Schedules fetched for medicationId=$medicationId: $scheduleList');
    return scheduleList;
  }

  Future<List<Schedule>> getAllSchedules() async {
    final scheduleList = await select(schedules).get();
    _logger.info('All schedules fetched: $scheduleList');
    return scheduleList;
  }

  Future<void> deleteSchedule(int id) async {
    _logger.info('Deleting schedule: id=$id');
    await (delete(schedules)..where((s) => s.id.equals(id))).go();
    await _logDatabase();
  }

  Future<void> addDoseHistory(DoseHistoryCompanion history) async {
    _logger.info('Adding dose history: $history');
    await into(doseHistory).insert(history);
    await _logDatabase();
  }

  Future<void> copyDatabaseToPublicDirectory() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'medminder.sqlite'));
    final publicDir = Directory('/sdcard/Download');
    final publicFile = File(p.join(publicDir.path, 'medminder.sqlite'));

    if (await dbFile.exists()) {
      try {
        await publicFile.parent.create(recursive: true);
        await dbFile.copy(publicFile.path);
        _logger.info('Database copied to: ${publicFile.path}');
      } catch (e) {
        _logger.severe('Failed to copy database: $e');
      }
    } else {
      _logger.severe('Database file does not exist at: ${dbFile.path}');
    }
  }

  Future<void> _logDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'medminder.sqlite'));
    if (await file.exists()) {
      _logger.info('Database file exists at: ${file.path}');
      final stats = await file.stat();
      _logger.info('Database file size: ${stats.size} bytes, modified: ${stats.modified}');
    } else {
      _logger.severe('Database file does not exist at: ${file.path}');
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'medminder.sqlite'));
    final logger = Logger('AppDatabase');
    logger.info('Opening database at: ${file.path}');
    if (!await file.exists()) {
      logger.info('Database file does not exist, creating new database');
      await file.create(recursive: true);
    } else {
      logger.info('Database exists at: ${file.path}');
    }
    return NativeDatabase.createInBackground(file);
  });
}