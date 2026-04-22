import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import './widgets/reports_header_widget.dart';
import './widgets/reports_monthly_heatmap_widget.dart';
import './widgets/reports_period_toggle_widget.dart';
import './widgets/reports_stats_row_widget.dart';
import './widgets/reports_trend_chart_widget.dart';
import './widgets/reports_weekly_chart_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod for production
  int _navIndex = 1;
  bool _isWeekView = true;
  late AnimationController _switchController;
  late Animation<double> _switchFade;

  // Mock weekly data (last 7 days, ml)
  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Mon', 'intake': 2100.0, 'goal': 2500.0},
    {'day': 'Tue', 'intake': 2650.0, 'goal': 2500.0},
    {'day': 'Wed', 'intake': 1800.0, 'goal': 2500.0},
    {'day': 'Thu', 'intake': 2500.0, 'goal': 2500.0},
    {'day': 'Fri', 'intake': 2900.0, 'goal': 2500.0},
    {'day': 'Sat', 'intake': 1400.0, 'goal': 2500.0},
    {'day': 'Sun', 'intake': 1550.0, 'goal': 2500.0},
  ];

  // Mock monthly data (April 2026, achievement %)
  late final List<double> _monthlyData;

  // Mock 30-day trend
  final List<double> _trendData = [
    1800,
    2100,
    2400,
    2200,
    1900,
    2500,
    2700,
    2300,
    2100,
    2600,
    2450,
    2200,
    1750,
    2300,
    2500,
    2800,
    2600,
    2100,
    2400,
    2700,
    2500,
    2200,
    2600,
    2800,
    2400,
    1900,
    2100,
    2500,
    2650,
    1550,
  ];

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _switchFade = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeOut,
    );
    _switchController.forward();

    // Generate monthly data
    _monthlyData = List.generate(30, (i) {
      final values = [
        0.84,
        1.06,
        0.72,
        1.0,
        1.16,
        0.56,
        0.62,
        0.88,
        0.96,
        1.04,
        0.78,
        0.92,
        0.70,
        0.94,
        1.0,
        1.12,
        1.04,
        0.84,
        0.96,
        1.08,
        1.0,
        0.88,
        1.04,
        1.12,
        0.96,
        0.76,
        0.84,
        1.0,
        1.06,
        0.62,
      ];
      return values[i % values.length];
    });
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
    }
  }

  void _togglePeriod(bool isWeek) {
    if (_isWeekView == isWeek) return;
    _switchController.reset();
    setState(() => _isWeekView = isWeek);
    _switchController.forward();
  }

  // Derived stats
  double get _avgIntake {
    final sum = _weeklyData.fold(0.0, (s, d) => s + (d['intake'] as double));
    return sum / _weeklyData.length;
  }

  double get _bestDay {
    return _weeklyData
        .map((d) => d['intake'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  String get _bestDayName {
    return _weeklyData.firstWhere((d) => d['intake'] == _bestDay)['day']
        as String;
  }

  int get _goalHitCount {
    return _weeklyData
        .where((d) => (d['intake'] as double) >= (d['goal'] as double))
        .length;
  }

  double get _monthlyAvg {
    return _trendData.reduce((a, b) => a + b) / _trendData.length;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
      bottomNavigationBar: AppNavigationWidget(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        color: AppTheme.background,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Hydration Reports',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              // Export button
              InkWell(
                onTap: _showExportSheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.ios_share_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Export',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 8),
              ReportsHeaderWidget(
                avgIntake: _avgIntake,
                goalHitCount: _goalHitCount,
                totalDays: _weeklyData.length,
              ),
              const SizedBox(height: 16),
              ReportsPeriodToggleWidget(
                isWeekView: _isWeekView,
                onToggle: _togglePeriod,
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _switchFade,
                child: _isWeekView
                    ? ReportsWeeklyChartWidget(weeklyData: _weeklyData)
                    : ReportsMonthlyHeatmapWidget(
                        monthlyData: _monthlyData,
                        month: 'April 2026',
                      ),
              ),
              const SizedBox(height: 16),
              ReportsStatsRowWidget(
                avgIntake: _avgIntake,
                bestDay: _bestDay,
                bestDayName: _bestDayName,
                goalHitCount: _goalHitCount,
                totalDays: _weeklyData.length,
                monthlyAvg: _monthlyAvg,
              ),
              const SizedBox(height: 16),
              ReportsTrendChartWidget(trendData: _trendData),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 10, 120),
            child: Column(
              children: [
                ReportsHeaderWidget(
                  avgIntake: _avgIntake,
                  goalHitCount: _goalHitCount,
                  totalDays: _weeklyData.length,
                ),
                const SizedBox(height: 16),
                ReportsWeeklyChartWidget(weeklyData: _weeklyData),
                const SizedBox(height: 16),
                ReportsTrendChartWidget(trendData: _trendData),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 8, 20, 120),
            child: Column(
              children: [
                ReportsMonthlyHeatmapWidget(
                  monthlyData: _monthlyData,
                  month: 'April 2026',
                ),
                const SizedBox(height: 16),
                ReportsStatsRowWidget(
                  avgIntake: _avgIntake,
                  bestDay: _bestDay,
                  bestDayName: _bestDayName,
                  goalHitCount: _goalHitCount,
                  totalDays: _weeklyData.length,
                  monthlyAvg: _monthlyAvg,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Text(
              'Export Report',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _ExportOption(
              icon: Icons.picture_as_pdf_outlined,
              color: const Color(0xFFEF4444),
              label: 'Export as PDF',
              sub: 'Weekly or monthly summary report',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.table_chart_outlined,
              color: const Color(0xFF10B981),
              label: 'Export as CSV',
              sub: 'Raw data for spreadsheet analysis',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.share_outlined,
              color: AppTheme.primary,
              label: 'Share Summary',
              sub: 'Share your hydration progress',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withAlpha(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.muted,
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
