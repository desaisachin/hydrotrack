import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StepScheduleWidget extends StatelessWidget {
  final TimeOfDay wakeTime;
  final TimeOfDay sleepTime;
  final Function(TimeOfDay) onWakeTimeChanged;
  final Function(TimeOfDay) onSleepTimeChanged;

  const StepScheduleWidget({
    super.key,
    required this.wakeTime,
    required this.sleepTime,
    required this.onWakeTimeChanged,
    required this.onSleepTimeChanged,
  });

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    Function(TimeOfDay) onChanged,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  int _getAwakeHours() {
    int wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
    int sleepMinutes = sleepTime.hour * 60 + sleepTime.minute;
    if (sleepMinutes < wakeMinutes) sleepMinutes += 24 * 60;
    return ((sleepMinutes - wakeMinutes) / 60).round();
  }

  @override
  Widget build(BuildContext context) {
    final awakeHours = _getAwakeHours();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Your daily\nschedule',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll space your reminders perfectly across your day',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 36),

          // Wake time
          _TimePickerCard(
            label: 'Wake Up Time',
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
            time: _formatTime(wakeTime),
            onTap: () => _pickTime(context, wakeTime, onWakeTimeChanged),
          ),
          const SizedBox(height: 16),

          // Sleep time
          _TimePickerCard(
            label: 'Bedtime',
            icon: Icons.bedtime_outlined,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF5F3FF),
            time: _formatTime(sleepTime),
            onTap: () => _pickTime(context, sleepTime, onSleepTimeChanged),
          ),
          const SizedBox(height: 28),

          // Awake hours summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withAlpha(51)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You\'re awake for $awakeHours hours',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Reminders will be distributed across this window',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
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

class _TimePickerCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String time;
  final VoidCallback onTap;

  const _TimePickerCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppTheme.primary.withAlpha(15),
      child: Container(
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
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.muted, size: 20),
          ],
        ),
      ),
    );
  }
}
