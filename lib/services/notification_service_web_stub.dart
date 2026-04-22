/// Web stub for NativeNotificationService.
/// On web, local notifications are not supported — all methods are no-ops.
class NativeNotificationService {
  static final NativeNotificationService _instance =
      NativeNotificationService._internal();
  factory NativeNotificationService() => _instance;
  NativeNotificationService._internal();

  Future<void> initialize() async {}
  Future<bool> requestPermissions() async => false;
  Future<void> scheduleHydrationReminders({
    required int wakeHour,
    required int wakeMinute,
    required int sleepHour,
    required int sleepMinute,
    required int intervalMinutes,
  }) async {}
  Future<void> cancelAll() async {}
  Future<void> showImmediate() async {}
}
