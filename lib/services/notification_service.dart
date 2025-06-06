import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class NotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');

  Future<void> init() async {
    _logger.info('Initializing notification service');
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    const channel = AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Notifications for medication reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      await _notifications.initialize(settings);
      _logger.info('Notification service initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize notifications: $e');
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    _logger.info('Requesting permissions');
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final exactAlarm = await androidPlugin?.requestExactAlarmsPermission() ?? true;
      final notifications = await androidPlugin?.requestNotificationsPermission() ?? true;
      _logger.info('Permissions: exactAlarm=$exactAlarm, notifications=$notifications');
      return exactAlarm && notifications;
    } catch (e) {
      _logger.severe('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> scheduleNotification(
      String id,
      String title,
      String body,
      tz.TZDateTime scheduledTime, {
        List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      }) async {
    _logger.info('Scheduling notification: id=$id, time=$scheduledTime, days=$days');
    if (!await _requestPermissions()) {
      _logger.severe('Permissions denied for id=$id');
      throw PlatformException(
        code: 'permissions_denied',
        message: 'Exact alarms or notifications not permitted.',
      );
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      final dayMap = {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7};

      for (final day in days) {
        final targetDay = dayMap[day]!;
        var nextDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );
        while (nextDate.weekday != targetDay || nextDate.isBefore(now.add(const Duration(minutes: 1)))) {
          nextDate = nextDate.add(const Duration(days: 1));
        }
        await _notifications.zonedSchedule(
          (id + day).hashCode,
          title,
          body,
          nextDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel',
              'Medication Reminders',
              channelDescription: 'Notifications for medication reminders',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        _logger.info('Scheduled notification for id=$id, day=$day, time=$nextDate');
      }

      final pending = await _notifications.pendingNotificationRequests();
      final scheduled = days.any((day) => pending.any((req) => req.id == (id + day).hashCode));
      if (!scheduled && days.isNotEmpty) {
        _logger.severe('No notifications scheduled for id=$id');
        throw Exception('Failed to schedule notification');
      }
      _logger.info('Verified pending notifications for id=$id: ${pending.map((req) => req.id).toList()}');
    } catch (e) {
      _logger.severe('Failed to schedule notification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(String id) async {
    _logger.info('Cancelling notification: id=$id');
    try {
      for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        await _notifications.cancel((id + day).hashCode);
        _logger.info('Cancelled notification for id=$id, day=$day');
      }
    } catch (e) {
      _logger.severe('Failed to cancel notification: $e');
    }
  }

  Future<void> testNotification() async {
    _logger.info('Testing immediate notification');
    try {
      await _notifications.show(
        0,
        'Test Notification',
        'This is a test notification',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      _logger.info('Test notification shown successfully');
    } catch (e) {
      _logger.severe('Failed to show test notification: $e');
    }
  }
}