import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ReportsWeeklyChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyData;

  const ReportsWeeklyChartWidget({super.key, required this.weeklyData});

  @override
  State<ReportsWeeklyChartWidget> createState() =>
      _ReportsWeeklyChartWidgetState();
}

class _ReportsWeeklyChartWidgetState extends State<ReportsWeeklyChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    final goalMl = (widget.weeklyData.first['goal'] as double);

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
                  'Daily Intake — Last 7 Days',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 2, color: AppTheme.error),
                      const SizedBox(width: 4),
                      Text(
                        'Goal',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                return SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 3200,
                      minY: 0,
                      barTouchData: BarTouchData(
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                barTouchResponse.spot!.touchedBarGroupIndex;
                          });
                        },
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: const Color(0xFF0F172A),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final day =
                                widget.weeklyData[groupIndex]['day'] as String;
                            final intake =
                                widget.weeklyData[groupIndex]['intake']
                                    as double;
                            final isGoalMet = intake >= goalMl;
                            return BarTooltipItem(
                              '$day\n',
                              GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${(intake / 1000).toStringAsFixed(1)} L',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isGoalMet
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
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
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= widget.weeklyData.length) {
                                return const SizedBox.shrink();
                              }
                              final day = widget.weeklyData[i]['day'] as String;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  day,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: i == _touchedIndex
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: i == _touchedIndex
                                        ? AppTheme.primary
                                        : AppTheme.muted,
                                  ),
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
                            color: AppTheme.error.withAlpha(128),
                            strokeWidth: 1.5,
                            dashArray: [6, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(
                                right: 4,
                                bottom: 2,
                              ),
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.error,
                              ),
                              labelResolver: (_) => 'Goal',
                            ),
                          ),
                        ],
                      ),
                      barGroups: List.generate(widget.weeklyData.length, (i) {
                        final intake = widget.weeklyData[i]['intake'] as double;
                        final isGoalMet = intake >= goalMl;
                        final isTouched = i == _touchedIndex;
                        final animatedIntake = intake * _animation.value;

                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: animatedIntake,
                              width: isTouched ? 22 : 18,
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: isGoalMet
                                    ? [
                                        const Color(0xFF10B981).withAlpha(179),
                                        const Color(0xFF10B981),
                                      ]
                                    : [
                                        AppTheme.primary.withAlpha(153),
                                        AppTheme.primary,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
