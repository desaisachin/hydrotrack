import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StepRemindersWidget extends StatelessWidget {
  final bool reminderEnabled;
  final int intervalMinutes;
  final TimeOfDay wakeTime;
  final TimeOfDay sleepTime;
  final Function(bool) onEnabledChanged;
  final Function(int) onIntervalChanged;

  const StepRemindersWidget({
    super.key,
    required this.reminderEnabled,
    required this.intervalMinutes,
    required this.wakeTime,
    required this.sleepTime,
    required this.onEnabledChanged,
    required this.onIntervalChanged,
  });

  static const List<Map<String, dynamic>> _intervals = [
    {'label': '30 min', 'value': 30, 'sub': 'Frequent'},
    {'label': '45 min', 'value': 45, 'sub': 'Regular'},
    {'label': '1 hour', 'value': 60, 'sub': 'Balanced'},
    {'label': '90 min', 'value': 90, 'sub': 'Relaxed'},
    {'label': '2 hours', 'value': 120, 'sub': 'Minimal'},
  ];

  int _estimateReminders() {
    int wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
    int sleepMinutes = sleepTime.hour * 60 + sleepTime.minute;
    if (sleepMinutes < wakeMinutes) sleepMinutes += 24 * 60;
    final awakeMinutes = sleepMinutes - wakeMinutes;
    return (awakeMinutes / intervalMinutes).floor();
  }

  @override
  Widget build(BuildContext context) {
    final remindersCount = _estimateReminders();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Smart reminders',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll nudge you at the right times so you never forget',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Enable toggle
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Reminders',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Get notified on iPhone & Apple Watch',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminderEnabled,
                  onChanged: onEnabledChanged,
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (reminderEnabled) ...[
            Text(
              'Reminder Frequency',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _intervals.map((item) {
                final isSelected = intervalMinutes == item['value'];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: _intervals.last == item ? 0 : 6,
                    ),
                    child: GestureDetector(
                      onTap: () => onIntervalChanged(item['value'] as int),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withAlpha(20)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['label'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              item['sub'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                color: AppTheme.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Estimated count
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'You\'ll receive ~$remindersCount reminders today',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Apple Watch note
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8B5CF6).withAlpha(77)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.watch_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Apple Watch companion app will sync reminders and allow quick logging from your wrist',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
