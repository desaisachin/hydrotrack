import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _navIndex = 1;
  bool _isWeekView = true;
  bool _isLoading = true;
  late AnimationController _switchController;
  late Animation<double> _switchFade;

  // Real data from storage
  List<Map<String, dynamic>> _weeklyData = [];
  List<double> _monthlyData = [];
  List<double> _trendData = [];
  double _dailyGoalMl = 2500;

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
    _loadReportData();
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  // Build a date key string from a DateTime
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadReportData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoalMl = prefs.getDouble('daily_goal_ml') ?? 2500;

    final now = DateTime.now();

    // --- Weekly data (last 7 days) ---
    final List<Map<String, dynamic>> weekly = [];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final intake = prefs.getDouble('intake_$key') ?? 0.0;
      final goal = prefs.getDouble('goal_$key') ?? _dailyGoalMl;
      weekly.add({
        'day': dayNames[date.weekday - 1],
        'date': key,
        'intake': intake,
        'goal': goal,
      });
    }

    // --- Monthly heatmap (last 30 days) ---
    final List<double> monthly = [];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final intake = prefs.getDouble('intake_$key') ?? 0.0;
      final goal = prefs.getDouble('goal_$key') ?? _dailyGoalMl;
      final achievement = goal > 0 ? intake / goal : 0.0;
      monthly.add(achievement);
    }

    // --- 30-day trend ---
    final List<double> trend = [];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final intake = prefs.getDouble('intake_$key') ?? 0.0;
      trend.add(intake);
    }

    if (mounted) {
      setState(() {
        _weeklyData = weekly;
        _monthlyData = monthly;
        _trendData = trend;
        _isLoading = false;
      });
    }
  }

  // Check if there is any real logged data at all
  bool get _hasAnyData {
    return _weeklyData.any((d) => (d['intake'] as double) > 0) ||
        _trendData.any((v) => v > 0);
  }

  // Check if this week has any data
  bool get _hasWeeklyData {
    return _weeklyData.any((d) => (d['intake'] as double) > 0);
  }

  // Check if month has any data
  bool get _hasMonthlyData {
    return _monthlyData.any((v) => v > 0);
  }

  // Check if trend has enough data (at least 7 days)
  bool get _hasTrendData {
    return _trendData.where((v) => v > 0).length >= 2;
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

  double get _avgIntake {
    if (!_hasWeeklyData) return 0;
    final daysWithData =
        _weeklyData.where((d) => (d['intake'] as double) > 0).toList();
    if (daysWithData.isEmpty) return 0;
    final sum =
        daysWithData.fold(0.0, (s, d) => s + (d['intake'] as double));
    return sum / daysWithData.length;
  }

  double get _bestDay {
    if (!_hasWeeklyData) return 0;
    return _weeklyData
        .map((d) => d['intake'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  String get _bestDayName {
    if (!_hasWeeklyData) return '-';
    return _weeklyData.firstWhere(
            (d) => d['intake'] == _bestDay,
            orElse: () => {'day': '-'})['day'] as String;
  }

  int get _goalHitCount {
    return _weeklyData
        .where((d) => (d['intake'] as double) >= (d['goal'] as double) &&
            (d['intake'] as double) > 0)
        .length;
  }

  double get _monthlyAvg {
    final daysWithData = _trendData.where((v) => v > 0).toList();
    if (daysWithData.isEmpty) return 0;
    return daysWithData.reduce((a, b) => a + b) / daysWithData.length;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
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
              if (_hasAnyData)
                InkWell(
                  onTap: _showExportSheet,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.ios_share_rounded,
                            size: 16, color: AppTheme.primary),
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
    // Show full empty state if no data at all
    if (!_hasAnyData) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadReportData,
      color: AppTheme.primary,
      child: CustomScrollView(
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
                      ? (_hasWeeklyData
                          ? ReportsWeeklyChartWidget(
                              weeklyData: _weeklyData)
                          : _buildSectionEmpty(
                              'No data this week yet',
                              'Start logging drinks on the Today tab',
                              Icons.water_drop_outlined,
                            ))
                      : (_hasMonthlyData
                          ? ReportsMonthlyHeatmapWidget(
                              monthlyData: _monthlyData,
                              month: _currentMonthLabel(),
                            )
                          : _buildSectionEmpty(
                              'No monthly data yet',
                              'Keep logging daily and your heatmap will fill up',
                              Icons.calendar_month_outlined,
                            )),
                ),
                const SizedBox(height: 16),
                _hasWeeklyData
                    ? ReportsStatsRowWidget(
                        avgIntake: _avgIntake,
                        bestDay: _bestDay,
                        bestDayName: _bestDayName,
                        goalHitCount: _goalHitCount,
                        totalDays: _weeklyData
                            .where((d) => (d['intake'] as double) > 0)
                            .length,
                        monthlyAvg: _monthlyAvg,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 16),
                _hasTrendData
                    ? ReportsTrendChartWidget(trendData: _trendData)
                    : _buildSectionEmpty(
                        'Not enough data for trend',
                        'Log water for at least 2 days to see your trend',
                        Icons.show_chart_rounded,
                      ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    if (!_hasAnyData) return _buildEmptyState();

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
                _hasWeeklyData
                    ? ReportsWeeklyChartWidget(weeklyData: _weeklyData)
                    : _buildSectionEmpty(
                        'No data this week yet',
                        'Start logging drinks on the Today tab',
                        Icons.water_drop_outlined,
                      ),
                const SizedBox(height: 16),
                _hasTrendData
                    ? ReportsTrendChartWidget(trendData: _trendData)
                    : _buildSectionEmpty(
                        'Not enough data for trend',
                        'Log water for at least 2 days to see your trend',
                        Icons.show_chart_rounded,
                      ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 8, 20, 120),
            child: Column(
              children: [
                _hasMonthlyData
                    ? ReportsMonthlyHeatmapWidget(
                        monthlyData: _monthlyData,
                        month: _currentMonthLabel(),
                      )
                    : _buildSectionEmpty(
                        'No monthly data yet',
                        'Keep logging daily and your heatmap will fill up',
                        Icons.calendar_month_outlined,
                      ),
                const SizedBox(height: 16),
                if (_hasWeeklyData)
                  ReportsStatsRowWidget(
                    avgIntake: _avgIntake,
                    bestDay: _bestDay,
                    bestDayName: _bestDayName,
                    goalHitCount: _goalHitCount,
                    totalDays: _weeklyData
                        .where((d) => (d['intake'] as double) > 0)
                        .length,
                    monthlyAvg: _monthlyAvg,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Full screen empty state — shown when user has zero data
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.water_drop_outlined,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Not enough data yet',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Drink enough water, log it and I\'ll tell you how you are doing.',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Tips card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to get started',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _tipRow('1', 'Go to the Today tab'),
                  const SizedBox(height: 8),
                  _tipRow('2', 'Tap Log Drink or use Quick Add'),
                  const SizedBox(height: 8),
                  _tipRow('3', 'Come back here after logging'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.dashboardScreen),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Go Log a Drink',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small empty state card for individual chart sections
  Widget _buildSectionEmpty(
      String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppTheme.muted),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  String _currentMonthLabel() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
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
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.muted, size: 20),
          ],
        ),
      ),
    );
  }
}
