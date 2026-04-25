import 'package:flutter/foundation.dart';

import './native_notification_service.dart';


/// Platform-agnostic notification service.
/// On web: all methods are no-ops.
/// On iOS/Android: delegates to NativeNotificationService.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const List<String> motivationalMessages = [
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
    if (kIsWeb) return;
    await NativeNotificationService().initialize();
  }

  /// Call this on every app launch to refresh today's notifications
  Future<void> refreshDailyReminders({
    required int wakeHour,
    required int wakeMinute,
    required int sleepHour,
    required int sleepMinute,
    required int intervalMinutes,
  }) async {
    if (kIsWeb) return;
    await scheduleHydrationReminders(
      wakeHour: wakeHour,
      wakeMinute: wakeMinute,
      sleepHour: sleepHour,
      sleepMinute: sleepMinute,
      intervalMinutes: intervalMinutes,
    );
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    return NativeNotificationService().requestPermissions();
  }

  Future<void> scheduleHydrationReminders({
    required int wakeHour,
    required int wakeMinute,
    required int sleepHour,
    required int sleepMinute,
    required int intervalMinutes,
  }) async {
    if (kIsWeb) return;
    await NativeNotificationService().scheduleHydrationReminders(
      wakeHour: wakeHour,
      wakeMinute: wakeMinute,
      sleepHour: sleepHour,
      sleepMinute: sleepMinute,
      intervalMinutes: intervalMinutes,
    );
  }

  Future<void> cancelAllReminders() async {
    if (kIsWeb) return;
    await NativeNotificationService().cancelAll();
  }

  Future<void> showImmediateReminder() async {
    if (kIsWeb) return;
    await NativeNotificationService().showImmediate();
  }
}
