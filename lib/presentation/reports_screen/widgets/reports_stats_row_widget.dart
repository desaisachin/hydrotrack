import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReportsStatsRowWidget extends StatelessWidget {
  final double avgIntake;
  final double bestDay;
  final String bestDayName;
  final int goalHitCount;
  final int totalDays;
  final double monthlyAvg;

  const ReportsStatsRowWidget({
    super.key,
    required this.avgIntake,
    required this.bestDay,
    required this.bestDayName,
    required this.goalHitCount,
    required this.totalDays,
    required this.monthlyAvg,
  });

  @override
  Widget build(BuildContext context) {
    final goalRate = ((goalHitCount / totalDays) * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats Summary',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.show_chart_rounded,
                  iconColor: AppTheme.primary,
                  iconBg: const Color(0xFFF0F9FF),
                  label: 'Weekly Avg',
                  value: '${(avgIntake / 1000).toStringAsFixed(1)} L',
                  sub: 'per day',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFFFBEB),
                  label: 'Best Day',
                  value: '${(bestDay / 1000).toStringAsFixed(1)} L',
                  sub: bestDayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.track_changes_rounded,
                  iconColor: goalRate >= 70
                      ? AppTheme.success
                      : const Color(0xFFF59E0B),
                  iconBg: goalRate >= 70
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFFFBEB),
                  label: 'Goal Hit Rate',
                  value: '$goalRate%',
                  sub: '$goalHitCount of $totalDays days',
                  isWarning: goalRate < 50,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF5F3FF),
                  label: '30-Day Avg',
                  value: '${(monthlyAvg / 1000).toStringAsFixed(1)} L',
                  sub: 'rolling average',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String sub;
  final bool isWarning;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.sub,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFEF2F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning ? AppTheme.error.withAlpha(77) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              if (isWarning)
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppTheme.warning,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isWarning ? AppTheme.error : AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
