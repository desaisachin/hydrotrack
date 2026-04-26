import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/dashboard_hourly_chart_widget.dart';
import './widgets/dashboard_kpi_chips_widget.dart';
import './widgets/dashboard_log_list_widget.dart';
import './widgets/dashboard_progress_ring_widget.dart';
import './widgets/dashboard_quick_add_widget.dart';
import './widgets/log_drink_sheet_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod for production
  int _navIndex = 0;
  double _dailyGoalMl = 2500;
  double _todayIntakeMl = 0;
  final int _streakDays = 7;
  String _userName = 'Alex';
  bool _isLoading = true;

  // Log entries for today - starts empty
  final List<Map<String, dynamic>> _logEntries = [];

  // Hourly data (24h, 0=midnight) - starts empty
  final List<double> _hourlyIntake = List.filled(24, 0.0);


  late AnimationController _fabPulseController;

  static const List<String> _motivationalMessages = [
    '💧 Every sip counts toward a healthier you!',
    '🌊 Water is the driving force of all nature.',
    '✨ Stay hydrated, stay energized!',
    '🏃 Your body is 60% water — keep it topped up!',
    '🌿 Hydration is the foundation of wellbeing.',
    '⚡ Feeling tired? You might just need water!',
    '🎯 You\'re doing great — keep going!',
  ];

  String get _currentMessage {
    final hour = DateTime.now().hour;
    return _motivationalMessages[hour % _motivationalMessages.length];
  }

  @override
  void initState() {
    super.initState();
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadUserData();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderEnabled = prefs.getBool('reminder_enabled') ?? true;
    if (!reminderEnabled) return;

    final notifService = NotificationService();
    await notifService.initialize();

    final wakeHour = prefs.getInt('wake_hour') ?? 7;
    final wakeMinute = prefs.getInt('wake_minute') ?? 0;
    final sleepHour = prefs.getInt('sleep_hour') ?? 22;
    final sleepMinute = prefs.getInt('sleep_minute') ?? 30;
    final intervalMinutes = prefs.getInt('reminder_interval') ?? 60;

    // Refresh reminders daily — this cancels any leftover
    // notifications from previous days and reschedules only
    // between wake and sleep time for today
    await notifService.refreshDailyReminders(
      wakeHour: wakeHour,
      wakeMinute: wakeMinute,
      sleepHour: sleepHour,
      sleepMinute: sleepMinute,
      intervalMinutes: intervalMinutes,
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 400));

    // Load today's logs from storage
    final today = _todayKey();
    final savedLogs = prefs.getStringList('logs_$today') ?? [];
    final List<Map<String, dynamic>> loadedEntries = [];
    final List<double> loadedHourly = List.filled(24, 0.0);
    double totalIntake = 0.0;

    for (final raw in savedLogs) {
      final parts = raw.split('|');
      if (parts.length < 3) continue;
      final time = parts[0];
      final amount = int.tryParse(parts[1]) ?? 0;
      final type = parts[2];
      final hour = int.tryParse(parts.length > 3 ? parts[3] : '0') ?? 0;

      final iconAndColor = _iconColorForType(type);
      loadedEntries.add({
        'time': time,
        'amount': amount,
        'type': type,
        'icon': iconAndColor.$1,
        'color': iconAndColor.$2,
      });
      totalIntake += amount;
      if (hour >= 0 && hour < 24) {
        loadedHourly[hour] += amount;
      }
    }

    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'there';
        _dailyGoalMl = prefs.getDouble('daily_goal_ml') ?? 2500;
        _logEntries.clear();
        _logEntries.addAll(loadedEntries);
        for (int i = 0; i < 24; i++) {
          _hourlyIntake[i] = loadedHourly[i];
        }
        _todayIntakeMl = totalIntake;
        _isLoading = false;
      });
    }
  }

  // Returns today's date as a storage key e.g. "2026-04-26"
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Save all of today's logs to SharedPreferences
  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final List<String> encoded = _logEntries.map((e) {
      final hour = DateTime.now().hour;
      return '${e['time']}|${e['amount']}|${e['type']}|$hour';
    }).toList();
    await prefs.setStringList('logs_$today', encoded);

    // Also save daily summary for reports
    await prefs.setDouble('intake_$today', _todayIntakeMl);
    await prefs.setDouble('goal_$today', _dailyGoalMl);
  }

  // Returns icon and color for a drink type
  (IconData, Color) _iconColorForType(String type) {
    switch (type) {
      case 'Tea':
        return (Icons.emoji_food_beverage_outlined, const Color(0xFF10B981));
      case 'Coffee':
        return (Icons.coffee_rounded, const Color(0xFF8B5CF6));
      case 'Juice':
        return (Icons.local_bar_outlined, const Color(0xFFF59E0B));
      case 'Smoothie':
        return (Icons.blender_outlined, const Color(0xFFEC4899));
      case 'Sports':
        return (Icons.sports_rounded, const Color(0xFF06B6D4));
      case 'Milk':
        return (Icons.water_drop_outlined, const Color(0xFF94A3B8));
      default:
        return (Icons.local_drink_outlined, const Color(0xFF0EA5E9));
    }
  }

  void _onNavTap(int index) {
    // TODO: Replace with Riverpod for production
    setState(() => _navIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.reportsScreen);
    }
  }

  void _showLogDrinkSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogDrinkSheetWidget(
        onLog: (amount, type, icon, color) {
          HapticFeedback.lightImpact();
          final now = TimeOfDay.now();
          final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
          final minute = now.minute.toString().padLeft(2, '0');
          final period = now.period == DayPeriod.am ? 'AM' : 'PM';
          setState(() {
              _logEntries.insert(0, {
                'time': '$hour:$minute $period',
                'amount': amount,
                'type': type,
                'icon': icon,
                'color': color,
              });
              _todayIntakeMl += amount;
              if (DateTime.now().hour < 24) {
                _hourlyIntake[DateTime.now().hour] += amount;
              }
            });
            _saveLogs();
        },
      ),
    );
  }

  void _onQuickAdd(int amount, String type, IconData icon, Color color) {
    HapticFeedback.lightImpact();
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    setState(() {
      _logEntries.insert(0, {
        'time': '$hour:$minute $period',
        'amount': amount,
        'type': type,
        'icon': icon,
        'color': color,
      });
      _todayIntakeMl += amount;
      if (DateTime.now().hour < 24) {
        _hourlyIntake[DateTime.now().hour] += amount.toDouble();
      }
    });
    _saveLogs();
  }

  double get _progressPercent =>
      (_todayIntakeMl / _dailyGoalMl).clamp(0.0, 1.0);

  int get _hydrationScore {
    final percent = _progressPercent;
    final hour = DateTime.now().hour;
    final expectedByNow = (hour / 16).clamp(0.0, 1.0); // 16 waking hours
    if (percent >= expectedByNow) {
      return (85 + (percent * 15)).round().clamp(0, 100);
    }
    return ((percent / expectedByNow) * 80).round().clamp(0, 100);
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final remaining = (_dailyGoalMl - _todayIntakeMl).clamp(0.0, _dailyGoalMl);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: isTablet
            ? _buildTabletLayout(remaining)
            : _buildPhoneLayout(remaining),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: AppNavigationWidget(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildPhoneLayout(double remaining) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              DashboardHeaderWidget(
                userName: _userName,
                message: _currentMessage,
                streakDays: _streakDays,
              ),
              const SizedBox(height: 8),
              DashboardProgressRingWidget(
                progress: _progressPercent,
                intakeMl: _todayIntakeMl,
                goalMl: _dailyGoalMl,
                remainingMl: remaining,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              DashboardKpiChipsWidget(
                streakDays: _streakDays,
                hydrationScore: _hydrationScore,
                remainingMl: remaining,
                goalMl: _dailyGoalMl,
                intakeMl: _todayIntakeMl,
              ),
              const SizedBox(height: 20),
              DashboardQuickAddWidget(onQuickAdd: _onQuickAdd),
              const SizedBox(height: 20),
              DashboardHourlyChartWidget(
                hourlyData: _hourlyIntake,
                goalMl: _dailyGoalMl,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 120),
          sliver: DashboardLogListWidget(
            entries: _logEntries,
            onDelete: (index) {
              setState(() {
                _todayIntakeMl -= (_logEntries[index]['amount'] as int);
                _logEntries.removeAt(index);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(double remaining) {
    return Row(
      children: [
        // Left: ring + chart
        Expanded(
          flex: 6,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    DashboardHeaderWidget(
                      userName: _userName,
                      message: _currentMessage,
                      streakDays: _streakDays,
                    ),
                    DashboardProgressRingWidget(
                      progress: _progressPercent,
                      intakeMl: _todayIntakeMl,
                      goalMl: _dailyGoalMl,
                      remainingMl: remaining,
                      isLoading: _isLoading,
                    ),
                    DashboardKpiChipsWidget(
                      streakDays: _streakDays,
                      hydrationScore: _hydrationScore,
                      remainingMl: remaining,
                      goalMl: _dailyGoalMl,
                      intakeMl: _todayIntakeMl,
                    ),
                    const SizedBox(height: 16),
                    DashboardHourlyChartWidget(
                      hourlyData: _hourlyIntake,
                      goalMl: _dailyGoalMl,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: AppTheme.border),
        // Right: quick add + log list
        Expanded(
          flex: 4,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DashboardQuickAddWidget(onQuickAdd: _onQuickAdd),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: DashboardLogListWidget(
                  entries: _logEntries,
                  onDelete: (index) {
                    setState(() {
                      _todayIntakeMl -= (_logEntries[index]['amount'] as int);
                      _logEntries.removeAt(index);
                    });
                    _saveLogs();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: FloatingActionButton.extended(
        onPressed: _showLogDrinkSheet,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Log Drink',
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
