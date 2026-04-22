import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum HydrationStatus {
  notStarted,
  inProgress,
  onTrack,
  goalMet,
  exceeded,
  warning,
}

class StatusBadgeWidget extends StatelessWidget {
  final HydrationStatus status;
  final String? customLabel;

  const StatusBadgeWidget({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1.withAlpha(31),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.$1.withAlpha(77)),
      ),
      child: Text(
        customLabel ?? config.$2,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.$1,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color, String) _config(HydrationStatus s) {
    return switch (s) {
      HydrationStatus.notStarted => (const Color(0xFF94A3B8), 'Not Started'),
      HydrationStatus.inProgress => (const Color(0xFF0EA5E9), 'In Progress'),
      HydrationStatus.onTrack => (const Color(0xFF10B981), 'On Track'),
      HydrationStatus.goalMet => (const Color(0xFF10B981), 'Goal Met ✓'),
      HydrationStatus.exceeded => (const Color(0xFF06B6D4), 'Exceeded!'),
      HydrationStatus.warning => (const Color(0xFFF59E0B), 'Falling Behind'),
    };
  }
}
