import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_progress_widget.dart';
import './widgets/step_goal_reveal_widget.dart';
import './widgets/step_presets_widget.dart';
import './widgets/step_profile_widget.dart';
import './widgets/step_reminders_widget.dart';
import './widgets/step_schedule_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod for production
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Profile data
  String _name = '';
  String _gender = 'male';
  double _age = 28;
  double _weight = 70;
  String _weightUnit = 'kg';
  double _height = 170;
  String _heightUnit = 'cm';
  double _activityLevel = 1.3; // multiplier

  // Schedule data
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 30);

  // Calculated goal
  double _dailyGoalMl = 0;

  // Reminder data
  int _reminderIntervalMinutes = 60;
  bool _reminderEnabled = true;

  final int _totalSteps = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    _checkOnboardingComplete();
  }

  Future<void> _checkOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    if (completed && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateDailyGoal() {
    // WHO / Mayo Clinic formula using weight, height, age (Mifflin-St Jeor inspired)
    double weightKg = _weightUnit == 'lbs' ? _weight * 0.453592 : _weight;
    double heightCm = _heightUnit == 'in' ? _height * 2.54 : _height;
    // Base: weight(kg) × 35ml × activity multiplier
    double base = weightKg * 35 * _activityLevel;
    // Height bonus: taller people need more water
    base += (heightCm - 170) * 5;
    // Age adjustment: over 55 → +10%
    if (_age > 55) base *= 1.1;
    // Gender adjustment: male → +15%
    if (_gender == 'male') base *= 1.15;
    return base.clamp(1500, 4500);
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep == 1) {
      // Calculate goal before showing reveal
      setState(() {
        _dailyGoalMl = _calculateDailyGoal();
      });
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // TODO: Persist to local DB / Riverpod for production
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
    await prefs.setString('gender', _gender);
    await prefs.setDouble('age', _age);
    await prefs.setDouble('height', _height);
    await prefs.setString('height_unit', _heightUnit);
    await prefs.setDouble('weight', _weight);
    await prefs.setString('weight_unit', _weightUnit);
    await prefs.setDouble('daily_goal_ml', _dailyGoalMl);
    await prefs.setInt('wake_hour', _wakeTime.hour);
    await prefs.setInt('wake_minute', _wakeTime.minute);
    await prefs.setInt('sleep_hour', _sleepTime.hour);
    await prefs.setInt('sleep_minute', _sleepTime.minute);
    await prefs.setInt('reminder_interval', _reminderIntervalMinutes);
    await prefs.setBool('reminder_enabled', _reminderEnabled);
    await prefs.setBool('onboarding_complete', true);

    // Schedule local notifications if reminders are enabled
    if (_reminderEnabled) {
      final notifService = NotificationService();
      await notifService.initialize();
      await notifService.requestPermissions();
      await notifService.scheduleHydrationReminders(
        wakeHour: _wakeTime.hour,
        wakeMinute: _wakeTime.minute,
        sleepHour: _sleepTime.hour,
        sleepMinute: _sleepTime.minute,
        intervalMinutes: _reminderIntervalMinutes,
      );
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 520 : double.infinity,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo + brand
                  _buildHeader(),
                  const SizedBox(height: 20),
                  // Progress indicator
                  OnboardingProgressWidget(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                  ),
                  const SizedBox(height: 8),
                  // Page view
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                       StepProfileWidget(
                          name: _name,
                          gender: _gender,
                          age: _age,
                          weight: _weight,
                          weightUnit: _weightUnit,
                          height: _height,
                          heightUnit: _heightUnit,
                          activityLevel: _activityLevel,
                          onNameChanged: (v) => setState(() => _name = v),
                          onGenderChanged: (v) => setState(() => _gender = v),
                          onAgeChanged: (v) => setState(() => _age = v),
                          onWeightChanged: (v) => setState(() => _weight = v),
                          onWeightUnitChanged: (v) =>
                              setState(() => _weightUnit = v),
                          onHeightChanged: (v) => setState(() => _height = v),
                          onHeightUnitChanged: (v) =>
                              setState(() => _heightUnit = v),
                          onActivityChanged: (v) =>
                              setState(() => _activityLevel = v),
                        ),
                        StepScheduleWidget(
                          wakeTime: _wakeTime,
                          sleepTime: _sleepTime,
                          onWakeTimeChanged: (v) =>
                              setState(() => _wakeTime = v),
                          onSleepTimeChanged: (v) =>
                              setState(() => _sleepTime = v),
                        ),
                        StepGoalRevealWidget(
                          dailyGoalMl: _dailyGoalMl,
                          gender: _gender,
                          weight: _weight,
                          weightUnit: _weightUnit,
                          activityLevel: _activityLevel,
                        ),
                        StepRemindersWidget(
                          reminderEnabled: _reminderEnabled,
                          intervalMinutes: _reminderIntervalMinutes,
                          wakeTime: _wakeTime,
                          sleepTime: _sleepTime,
                          onEnabledChanged: (v) =>
                              setState(() => _reminderEnabled = v),
                          onIntervalChanged: (v) =>
                              setState(() => _reminderIntervalMinutes = v),
                        ),
                        StepPresetsWidget(onContinue: _nextStep),
                      ],
                    ),
                  ),
                  // Navigation buttons
                  _buildNavButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'HydroTrack',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButtons() {
    final isLastStep = _currentStep == _totalSteps - 1;
    // Step 4 (presets) handles its own continue button
    if (_currentStep == 4) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(
                isLastStep ? 'Get Started!' : 'Continue',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
