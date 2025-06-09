import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/database.dart';
import 'drift_service.dart'; // Added import
import 'notification_service.dart';

final doseServiceProvider = Provider<DoseService>((ref) => DoseService(ref));

class DoseService {
  final Ref _ref;
  final Logger _logger = Logger('DoseService');

  DoseService(this._ref);

  AppDatabase get _db => _ref.read(driftServiceProvider);

  Future<void> takeDose(int medicationId, int doseId, double amount) async {
    await _db.transaction(() async {
      _logger.info('Taking dose: medId=$medicationId, doseId=$doseId, amount=$amount');
      final med = await (_db.select(_db.medications)..where((m) => m.id.equals(medicationId)))
          .getSingleOrNull();
      if (med == null || med.stockQuantity < amount) {
        _logger.warning('Insufficient stock for medId=$medicationId, required=$amount, available=${med?.stockQuantity}');
        throw Exception('Insufficient stock');
      }
      await _db.updateMedicationStock(medicationId, med.stockQuantity - amount);
      await _db.addDoseHistory(DoseHistoryCompanion(
        doseId: drift.Value(doseId),
        takenAt: drift.Value(DateTime.now()),
      ));
      final schedules = await _db.getSchedules(medicationId);
      final today = _weekdayToString(DateTime.now().weekday);
      for (final schedule in schedules) {
        if (schedule.doseId == doseId && schedule.frequency != 'Daily' && schedule.days.contains(today)) {
          final updatedDays = schedule.days.where((day) => day != today).toList();
          _logger.info('Updating schedule ${schedule.id} to remove $today: $updatedDays');
          await _db.updateSchedule(
              schedule.id, SchedulesCompanion(days: drift.Value(updatedDays)));
        }
      }
    });
  }

  Future<void> snoozeDose(int scheduleId) async {
    _logger.info('Snoozing dose: scheduleId=$scheduleId');
    final schedule = await (_db.select(_db.schedules)..where((s) => s.id.equals(scheduleId)))
        .getSingleOrNull();
    if (schedule != null) {
      final now = tz.TZDateTime.now(tz.local);
      final newTime = now.add(const Duration(hours: 1));
      await _db.updateSchedule(
        scheduleId,
        SchedulesCompanion(
          time: drift.Value(DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute)),
        ),
      );
      if (schedule.notificationId != null) {
        await _ref.read(notificationServiceProvider).scheduleNotification(
          id: schedule.notificationId!,
          title: 'Snoozed Dose: ${schedule.name}',
          body: 'Time to take your dose!',
          scheduledTime: DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute),
          days: schedule.days.isEmpty ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] : schedule.days,
        );
      }
    }
  }

  Future<void> cancelDose(int scheduleId) async {
    _logger.info('Canceling dose: scheduleId=$scheduleId');
    final schedule = await (_db.select(_db.schedules)..where((s) => s.id.equals(scheduleId)))
        .getSingleOrNull();
    if (schedule != null) {
      final today = _weekdayToString(DateTime.now().weekday);
      final updatedDays = schedule.days.where((day) => day != today).toList();
      await _db.updateSchedule(
        scheduleId,
        SchedulesCompanion(days: drift.Value(updatedDays)),
      );
    }
  }

  Future<bool> isDoseAvailableToday(Schedule schedule) async {
    final today = DateTime.now();
    final isToday = schedule.frequency == 'Daily' ||
        schedule.days.contains(_weekdayToString(today.weekday));
    final time = schedule.time;
    final isBefore = today.hour < time.hour || (today.hour == time.hour && today.minute <= time.minute);
    _logger.info('Dose availability for schedule ${schedule.id}: $isToday && $isBefore');
    return isToday && isBefore;
  }

  String _weekdayToString(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}