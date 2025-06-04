// lib/services/drift_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
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

  Future<void> addSchedule(SchedulesCompanion schedule) async {
    _logger.info('Adding schedule: $schedule');
    await _db.addSchedule(schedule);
  }

  Future<List<Schedule>> getSchedules(int doseId) => _db.getSchedules(doseId);

  Future<void> deleteSchedule(int id) async {
    _logger.info('Deleting schedule: id=$id');
    await _db.deleteSchedule(id);
  }

  Future<void> copyDatabaseToPublicDirectory() async {
    await _db.copyDatabaseToPublicDirectory();
  }
}