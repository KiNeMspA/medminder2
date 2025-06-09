import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');

  Future<void> init() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _logger.info('NotificationService initialized');
  }

  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required List<String> days,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    for (final day in days) {
      final dayIndex = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].indexOf(day);
      if (dayIndex == -1) continue;
      final nextDay = now.add(Duration(days: (dayIndex - now.weekday + 7) % 7));
      final scheduled = tz.TZDateTime(
        tz.local,
        nextDay.year,
        nextDay.month,
        nextDay.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails('medminder', 'MedMinder Notifications'),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      ).then((_) {
        _logger.info('Successfully scheduled notification: ID=$id, Title=$title, Time=$scheduled, Days=$days');
      }).catchError((e) {
        _logger.severe('Failed to schedule notification: ID=$id, Error=$e');
      });
    }
  }

  Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
    _logger.info('Cancelled notification: $id');
  }
}