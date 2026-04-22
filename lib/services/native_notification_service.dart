import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Native (non-web) implementation of hydration notification scheduling.
/// This file is only imported on non-web platforms.
class NativeNotificationService {
  static final NativeNotificationService _instance =
      NativeNotificationService._internal();
  factory NativeNotificationService() => _instance;
  NativeNotificationService._internal();

  static const String _channelId = 'hydrotrack_reminders';
  static const String _channelName = 'Hydration Reminders';
  static const String _channelDesc =
      'Scheduled reminders to drink water throughout the day';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const List<String> _messages = [
    'Time to hydrate! 💧 Your body will thank you.',
    'Water break! Stay sharp and energized. 🌊',
    'Sip by sip, you\'re crushing your goal! 🏆',
    'Your cells are thirsty — give them some love! 💙',
    'Hydration = energy + focus + glowing skin! ✨',
    'A glass of water now keeps the headache away! 🧠',
    'You\'re doing amazing! Keep up the hydration streak! 🔥',
    'Water is life — drink up! 🌿',
    'Small sips, big results. Drink some water now! 💪',
    'Stay cool, stay hydrated! 🧊',
    'Your future self thanks you for drinking water now! 🙏',
    'Hydration check! How\'s your water intake going? 💦',
    'Feeling tired? Water might be the fix! ⚡',
    'Every drop counts toward your daily goal! 🎯',
    'Drink water like it\'s your superpower — because it is! 🦸',
  ];

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleHydrationReminders({
    required int wakeHour,
    required int wakeMinute,
    required int sleepHour,
    required int sleepMinute,
    required int intervalMinutes,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);

    int wakeTotal = wakeHour * 60 + wakeMinute;
    int sleepTotal = sleepHour * 60 + sleepMinute;
    if (sleepTotal <= wakeTotal) sleepTotal += 24 * 60;

    int notifId = 0;
    int currentMinute = wakeTotal;

    while (currentMinute < sleepTotal) {
      final hour = (currentMinute ~/ 60) % 24;
      final minute = currentMinute % 60;

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final message = _messages[notifId % _messages.length];

      await _plugin.zonedSchedule(
        notifId,
        'HydroTrack 💧',
        message,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF0EA5E9),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      notifId++;
      currentMinute += intervalMinutes;
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  Future<void> showImmediate() async {
    if (!_initialized) await initialize();
    final message = _messages[DateTime.now().millisecond % _messages.length];
    await _plugin.show(
      9999,
      'HydroTrack 💧',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF0EA5E9),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}