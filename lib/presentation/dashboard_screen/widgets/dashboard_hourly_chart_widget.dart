import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DashboardHourlyChartWidget extends StatelessWidget {
  final List<double> hourlyData;
  final double goalMl;

  const DashboardHourlyChartWidget({
    super.key,
    required this.hourlyData,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    // Only show waking hours 6 AM - 10 PM (indices 6–22)
    final wakingData = hourlyData.sublist(6, 23);
    final maxVal = wakingData
        .reduce((a, b) => a > b ? a : b)
        .clamp(100.0, 600.0);

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
                  "Today's Intake by Hour",
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Last updated now',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal + 100,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: const Color(0xFF0F172A),
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY == 0) return null;
                        return BarTooltipItem(
                          '${rod.toY.round()} ml',
                          GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final hour = value.toInt() + 6;
                          if (hour % 4 != 0) {
                            return const SizedBox.shrink();
                          }
                          final label = hour == 12
                              ? '12P'
                              : hour > 12
                              ? '${hour - 12}P'
                              : '${hour}A';
                          return Text(
                            label,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.muted,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: const Color(0xFFF1F5F9),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(wakingData.length, (i) {
                    final val = wakingData[i];
                    final hour = i + 6;
                    final isCurrentHour = hour == DateTime.now().hour;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                          gradient: val > 0
                              ? LinearGradient(
                                  colors: isCurrentHour
                                      ? [
                                          const Color(0xFF06B6D4),
                                          const Color(0xFF0EA5E9),
                                        ]
                                      : [
                                          const Color(
                                            0xFF0EA5E9,
                                          ).withAlpha(179),
                                          const Color(0xFF0EA5E9),
                                        ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : LinearGradient(
                                  colors: [
                                    const Color(0xFFF1F5F9),
                                    const Color(0xFFE2E8F0),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Legend(color: AppTheme.primary, label: 'Intake recorded'),
                const SizedBox(width: 16),
                _Legend(color: const Color(0xFFE2E8F0), label: 'No intake'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppTheme.muted,
          ),
        ),
      ],
    );
  }
}
