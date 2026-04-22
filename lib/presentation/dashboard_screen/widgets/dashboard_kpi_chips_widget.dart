import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DashboardKpiChipsWidget extends StatelessWidget {
  final int streakDays;
  final int hydrationScore;
  final double remainingMl;
  final double goalMl;
  final double intakeMl;

  const DashboardKpiChipsWidget({
    super.key,
    required this.streakDays,
    required this.hydrationScore,
    required this.remainingMl,
    required this.goalMl,
    required this.intakeMl,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = hydrationScore >= 80
        ? AppTheme.success
        : hydrationScore >= 60
        ? const Color(0xFFF59E0B)
        : AppTheme.error;

    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _KpiChip(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
            label: '$streakDays day streak',
            sub: 'Keep it up!',
          ),
          const SizedBox(width: 10),
          _KpiChip(
            icon: Icons.favorite_rounded,
            iconColor: scoreColor,
            iconBg: scoreColor.withAlpha(26),
            label: '$hydrationScore / 100',
            sub: 'Hydration Score',
          ),
          const SizedBox(width: 10),
          _KpiChip(
            icon: Icons.timer_outlined,
            iconColor: AppTheme.accent,
            iconBg: const Color(0xFFECFEFF),
            label: '${remainingMl.round()} ml',
            sub: 'Still needed',
          ),
          const SizedBox(width: 10),
          _KpiChip(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF5F3FF),
            label: '${(intakeMl / goalMl * 100).round()}%',
            sub: 'of daily goal',
          ),
        ],
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String sub;

  const _KpiChip({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
