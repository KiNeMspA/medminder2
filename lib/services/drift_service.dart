import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'notification_service.dart';
import 'package:logging/logging.dart';

final driftServiceProvider = Provider<DriftService>((ref) => DriftService.instance);
final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  return ref.watch(driftServiceProvider).getMedications();
});
final dosesProvider = FutureProvider.family<List<Dose>, int>((ref, medId) async {
  return ref.watch(driftServiceProvider).getDoses(medId);
});
final allDosesProvider = FutureProvider<List<Dose>>((ref) async {
  return ref.watch(driftServiceProvider).getAllDoses();
});

class DriftService {
  static final DriftService instance = DriftService._internal();
  DriftService._internal();
  final AppDatabase _db = AppDatabase();
  final Logger _logger = Logger('DriftService');

  Future<void> init() async {
    // Drift initializes automatically
  }

  Future<void> addMedication(MedicationsCompanion med) async {
    _logger.info('Adding medication: $med');
    await _db.addMedication(med);
  }

  Future<void> updateMedicationStock(int id, double newQuantity) async {
    _logger.info('Updating medication stock: id=$id, newQuantity=$newQuantity');
    await _db.updateMedicationStock(id, newQuantity);
  }

  Future<List<Medication>> getMedications() => _db.getMedications();

  Future<void> deleteMedication(int id) async {
    _logger.info('Deleting medication: id=$id');
    await _db.deleteMedication(id);
  }

  Future<int> addDose(DosesCompanion dose) async {
    _logger.info('Adding dose: $dose');
    return await _db.addDose(dose);
  }

  Future<void> updateDose(int id, DosesCompanion dose) async {
    _logger.info('Updating dose: id=$id, $dose');
    await _db.updateDose(id, dose);
  }

  Future<List<Dose>> getDoses(int medicationId) => _db.getDoses(medicationId);

  Future<List<Dose>> getAllDoses() async {
    final doseList = await _db.select(_db.doses).get();
    _logger.info('Retrieved all doses: $doseList');
    return doseList;
  }

  Future<void> deleteDose(int id) async {
    _logger.info('Deleting dose: id=$id');
    await _db.deleteDose(id);
  }

  Future<int> addSchedule(SchedulesCompanion schedule) async {
    _logger.info('Adding schedule: $schedule');
    final scheduleId = await _db.addSchedule(schedule);
    await _db.updateSchedule(scheduleId, SchedulesCompanion(notificationId: Value('schedule_$scheduleId')));
    return scheduleId;
  }

  Future<List<Schedule>> getSchedules(int medicationId) => _db.getSchedules(medicationId);

  Future<void> updateSchedule(int id, SchedulesCompanion schedule) async {
    _logger.info('Updating schedule: id=$id, $schedule');
    await _db.updateSchedule(id, schedule);
  }

  Future<void> deleteSchedule(int id) async {
    _logger.info('Deleting schedule: id=$id');
    final schedule = await (_db.select(_db.schedules)..where((s) => s.id.equals(id))).getSingleOrNull();
    if (schedule != null && schedule.notificationId != null) {
      await NotificationService().cancelNotification(schedule.notificationId!);
    }
    await _db.deleteSchedule(id);
  }

  Future<void> addDoseHistory(DoseHistoryCompanion history) async {
    _logger.info('Adding dose history: $history');
    await _db.addDoseHistory(history);
  }

  Future<void> copyDatabaseToPublicDirectory() async {
    await _db.copyDatabaseToPublicDirectory();
  }

  Future<void> saveEntity<T extends Insertable<T>>(TableInfo table, T entity) async {
    _logger.info('Saving entity: $entity to table ${table.actualTableName}');
    await _db.into(table).insert(entity, mode: InsertMode.insertOrReplace);
  }
}