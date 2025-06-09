import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.cancelAllNotifications());
  service.initialize();
  return service;
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');
  late tz.Location _local;

  NotificationService();

  Future<void> initialize() async {
    _logger.info('Initializing notification service');
    try {
      tz.initializeTimeZones();
      _local = tz.getLocation('Australia/Sydney'); // Hardcoded AEST for now
      _logger.info('Timezone initialized: ${_local.name}');
    } catch (e) {
      _logger.severe('Failed to initialize timezone: $e');
      rethrow;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _flutterLocalNotificationsPlugin.initialize(settings);

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final notificationGranted = await androidPlugin?.requestNotificationsPermission();
    if (notificationGranted != true) {
      _logger.warning('Notification permission not granted');
      throw Exception('Notification permission denied');
    }

    final alarmGranted = await androidPlugin?.requestExactAlarmsPermission();
    if (alarmGranted != true) {
      _logger.warning('Exact alarm permission not granted');
      throw Exception('Exact alarm permission denied');
    }

    _logger.info('Notification and exact alarm permissions granted');
  }

  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required List<String> days,
  }) async {
    try {
      final now = tz.TZDateTime.now(_local);
      final validDays = days.where((day) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].contains(day)).toList();
      if (validDays.isEmpty) {
        _logger.warning('No valid days provided for notification: $days');
        throw Exception('No valid days for scheduling notification');
      }

      for (final day in validDays) {
        final dayIndex = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].indexOf(day);
        final daysUntilNext = (dayIndex - now.weekday + 7) % 7;
        final nextDay = now.add(Duration(days: daysUntilNext == 0 && scheduledTime.isBefore(now) ? 7 : daysUntilNext));
        var scheduled = tz.TZDateTime(
          _local,
          nextDay.year,
          nextDay.month,
          nextDay.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );

        _logger.fine('Scheduling notification: ID=$id, Title=$title, Time=$scheduled, Day=$day');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id.hashCode,
          title,
          body,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medminder',
              'MedMinder Notifications',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        _logger.info('Successfully scheduled notification: ID=$id, Title=$title, Time=$scheduled, Day=$day');
      }
      await logPendingNotifications();
    } catch (e, stack) {
      _logger.severe('Failed to schedule notification: ID=$id, Error=$e, Stack=$stack');
      rethrow;
    }
  }

  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
    _logger.info('Cancelled notification: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    _logger.info('Cancelled all notifications');
  }

  int _weekdayToIndex(String day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.indexOf(day) + 1;
  }

  Future<void> logPendingNotifications() async {
    try {
      final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      _logger.info('Pending notifications: ${pending.length}');
      for (var notification in pending) {
        _logger.fine('Notification ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }
    } catch (e, stack) {
      _logger.severe('Failed to retrieve pending notifications: $e, Stack=$stack');
    }
  }

  Future<Map<String, bool>> checkPermissionStatus() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final notificationGranted = await androidPlugin?.requestNotificationsPermission() ?? false;
    final alarmGranted = await androidPlugin?.requestExactAlarmsPermission() ?? false;
    _logger.info('Permission status: Notifications=$notificationGranted, ExactAlarm=$alarmGranted');
    return {
      'notifications': notificationGranted,
      'exactAlarm': alarmGranted,
    };
  }
}