import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification(Reminder reminder) async {
    // Cancel previous notification to avoid duplicates on update
    await cancelNotification(reminder.id);

    // Don't schedule past, non-recurring events
    if (reminder.eventDate.isBefore(DateTime.now()) &&
        reminder.recurrence == RecurrenceType.none) {
      return;
    }

    DateTimeComponents? matchDateTimeComponents;
    switch (reminder.recurrence) {
      case RecurrenceType.daily:
        matchDateTimeComponents = DateTimeComponents.time;
        break;
      case RecurrenceType.weekly:
        matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
      case RecurrenceType.monthly:
        matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
        break;

      case RecurrenceType.none:
      default: // Handle yearly or any future additions gracefully
        break;
    }
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id,
      reminder.title,
      reminder.description ?? '',
      tz.TZDateTime.from(reminder.eventDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ingatin_channel_id',
          'Ingat.in Channel',
          channelDescription: 'Channel for Ingat.in reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
