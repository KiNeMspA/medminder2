import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.cancelAllNotifications());
  return service..initialize();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');
  late tz.Location _local;

  Future<void> initialize() async {
    _logger.info('Initializing notification service');
    tz.initializeTimeZones();
    try {
      _local = tz.getLocation('Australia/Sydney'); // Set to AEST
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
    await androidPlugin?.requestNotificationsPermission();
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
      for (final day in days) {
        final dayIndex = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].indexOf(day);
        if (dayIndex == -1) {
          _logger.warning('Invalid day: $day');
          continue;
        }
        final nextDay = now.add(Duration(days: (dayIndex - now.weekday + 7) % 7));
        final scheduled = tz.TZDateTime(
          _local,
          nextDay.year,
          nextDay.month,
          nextDay.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );
        _logger.fine('Scheduling notification: ID=$id, Title=$title, Time=$scheduled, Days=$days');
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
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        _logger.info('Successfully scheduled notification: ID=$id, Title=$title, Time=$scheduled, Days=$days');
      }
    } catch (e) {
      _logger.severe('Failed to schedule notification: ID=$id, Error=$e');
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
}