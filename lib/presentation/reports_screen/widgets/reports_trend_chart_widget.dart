import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReportsTrendChartWidget extends StatefulWidget {
  final List<double> trendData;

  const ReportsTrendChartWidget({super.key, required this.trendData});

  @override
  State<ReportsTrendChartWidget> createState() =>
      _ReportsTrendChartWidgetState();
}

class _ReportsTrendChartWidgetState extends State<ReportsTrendChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goalMl = 2500.0;
    final spots = widget.trendData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    // Calculate 7-day moving average
    final movingAvg = <FlSpot>[];
    for (int i = 6; i < widget.trendData.length; i++) {
      final avg =
          widget.trendData.sublist(i - 6, i + 1).reduce((a, b) => a + b) / 7;
      movingAvg.add(FlSpot(i.toDouble(), avg));
    }

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
                  '30-Day Trend',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    _TrendLegend(color: AppTheme.primary, label: 'Daily'),
                    const SizedBox(width: 10),
                    _TrendLegend(
                      color: const Color(0xFF10B981),
                      label: '7-day avg',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                final animatedSpots = spots
                    .map((s) => FlSpot(s.x, s.y * _animation.value))
                    .toList();
                final animatedAvg = movingAvg
                    .map((s) => FlSpot(s.x, s.y * _animation.value))
                    .toList();

                return SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minY: 1000,
                      maxY: 3500,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: const Color(0xFF0F172A),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (spots) {
                            return spots.map((spot) {
                              return LineTooltipItem(
                                '${(spot.y / 1000).toStringAsFixed(1)} L',
                                GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: spot.bar.color ?? Colors.white,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            interval: 800,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(1)}L',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.muted,
                                ),
                              );
                            },
                          ),
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
                            interval: 7,
                            getTitlesWidget: (value, meta) {
                              final day = value.toInt() + 1;
                              if (day % 7 != 1 && day != 30) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                'D$day',
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
                        horizontalInterval: 800,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: const Color(0xFFF1F5F9),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: goalMl,
                            color: AppTheme.error.withAlpha(102),
                            strokeWidth: 1,
                            dashArray: [6, 4],
                          ),
                        ],
                      ),
                      lineBarsData: [
                        // Daily intake line
                        LineChartBarData(
                          spots: animatedSpots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: AppTheme.primary,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 2,
                                color: AppTheme.primary,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withAlpha(31),
                                AppTheme.primary.withAlpha(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // 7-day moving average
                        LineChartBarData(
                          spots: animatedAvg,
                          isCurved: true,
                          curveSmoothness: 0.4,
                          color: const Color(0xFF10B981),
                          barWidth: 2,
                          dashArray: [6, 3],
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _TrendLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
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
