import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsHeaderWidget extends StatelessWidget {
  final double avgIntake;
  final int goalHitCount;
  final int totalDays;

  const ReportsHeaderWidget({
    super.key,
    required this.avgIntake,
    required this.goalHitCount,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final goalHitRate = ((goalHitCount / totalDays) * 100).round();
    final avgLiters = (avgIntake / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$avgLiters L avg/day',
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$goalHitRate% goal hit rate',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$goalHitCount/$totalDays',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'days on goal',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
