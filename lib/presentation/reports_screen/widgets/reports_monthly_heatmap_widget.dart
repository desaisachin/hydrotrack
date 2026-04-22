import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReportsMonthlyHeatmapWidget extends StatelessWidget {
  final List<double> monthlyData;
  final String month;

  const ReportsMonthlyHeatmapWidget({
    super.key,
    required this.monthlyData,
    required this.month,
  });

  Color _cellColor(double achievement) {
    if (achievement == 0) return const Color(0xFFF1F5F9);
    if (achievement < 0.5) return const Color(0xFFFEE2E2);
    if (achievement < 0.75) return const Color(0xFFFED7AA);
    if (achievement < 1.0) return const Color(0xFFBAE6FD);
    return const Color(0xFF0EA5E9);
  }

  Color _textColor(double achievement) {
    if (achievement >= 1.0) return Colors.white;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    // April 2026 starts on Wednesday (index 2 in Mon-first week)
    const startOffset = 2;
    const daysInMonth = 30;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  month,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Hydration Achievement',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Day headers
            Row(
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.muted,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemCount: daysInMonth + startOffset,
              itemBuilder: (_, index) {
                if (index < startOffset) {
                  return const SizedBox.shrink();
                }
                final dayIndex = index - startOffset;
                final day = dayIndex + 1;
                final achievement = monthlyData[dayIndex];
                final isToday = day == 22; // April 22, 2026

                return AnimatedContainer(
                  duration: Duration(milliseconds: 200 + dayIndex * 15),
                  decoration: BoxDecoration(
                    color: _cellColor(achievement),
                    borderRadius: BorderRadius.circular(6),
                    border: isToday
                        ? Border.all(color: AppTheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: _textColor(achievement),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeatLegend(color: const Color(0xFFFEE2E2), label: '<50%'),
                const SizedBox(width: 8),
                _HeatLegend(color: const Color(0xFFFED7AA), label: '50–75%'),
                const SizedBox(width: 8),
                _HeatLegend(color: const Color(0xFFBAE6FD), label: '75–99%'),
                const SizedBox(width: 8),
                _HeatLegend(color: const Color(0xFF0EA5E9), label: '≥100%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _HeatLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.muted,
          ),
        ),
      ],
    );
  }
}
