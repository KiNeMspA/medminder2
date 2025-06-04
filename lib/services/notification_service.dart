// lib/services/notification_service.dart
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
    }
  }

  Future<bool> _requestExactAlarmPermission() async {
    _logger.info('Requesting exact alarm permission');
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestExactAlarmsPermission();
        _logger.info('Exact alarm permission granted: $granted');
        return granted ?? false;
      }
      return true;
    } catch (e) {
      _logger.severe('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  Future<bool> _requestNotificationPermission() async {
    _logger.info('Requesting notification permission');
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        _logger.info('Notification permission granted: $granted');
        return granted ?? false;
      }
      return true;
    } catch (e) {
      _logger.severe('Error requesting notification permission: $e');
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
    final hasAlarmPermission = await _requestExactAlarmPermission();
    final hasNotificationPermission = await _requestNotificationPermission();

    if (!hasAlarmPermission) {
      throw PlatformException(
        code: 'exact_alarms_not_permitted',
        message: 'Exact alarms are not permitted.',
      );
    }
    if (!hasNotificationPermission) {
      throw PlatformException(
        code: 'notifications_not_found',
        message: 'Notifications are not permitted.',
      );
    }

    try {
      // Debug notification
      await _notifications.show(
        id.hashCode + 1000,
        'Debug: $title',
        'Debug: $body (Scheduled for $scheduledTime, days=$days)',
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
      _logger.info('Debug notification shown for id=$id');

      // Schedule for each selected day
      final now = tz.TZDateTime.now(tz.local);
      final dayMap = {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7};
      for (final day in days) {
        final targetDay = dayMap[day]!;
        var nextDate = scheduledTime;
        while (nextDate.weekday != targetDay || nextDate.isBefore(now)) {
          nextDate = nextDate.add(const Duration(days: 1));
        }
        await _notifications.zonedSchedule(
          (id + day).hashCode, // Unique ID per day
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
        _logger.info('Notification scheduled for id=$id, day=$day, time=$nextDate');
      }

      // Verify at least one notification is scheduled
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      final scheduled = days.any((day) => pendingNotifications.any((req) => req.id == (id + day).hashCode));
      if (!scheduled && days.isNotEmpty) {
        _logger.severe('No notifications found for id=$id in pending requests');
        throw Exception('Failed to verify scheduled notification');
      } else {
        _logger.info('Verified pending notification: id=$id');
      }
    } catch (e) {
      _logger.severe('Failed to schedule notification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(String id) async {
    _logger.info('Cancelling notification: $id');
    try {
      await _notifications.cancel(id.hashCode);
      // Cancel notifications for each day
      for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        await _notifications.cancel((id + day).hashCode);
      }
      _logger.info('Notification cancelled: id=$id');
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