import 'package:flutter/material.dart';

import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/reports_screen/reports_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String onboardingScreen = '/onboarding-screen';
  static const String dashboardScreen = '/dashboard-screen';
  static const String reportsScreen = '/reports-screen';
  static const String settingsScreen = '/settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingScreen(),
    onboardingScreen: (context) => const OnboardingScreen(),
    dashboardScreen: (context) => const DashboardScreen(),
    reportsScreen: (context) => const ReportsScreen(),
    settingsScreen: (context) => const SettingsScreen(),
  };
}
