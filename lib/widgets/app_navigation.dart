import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    if (isTablet) {
      return _TabletRail(currentIndex: currentIndex, onTap: onTap);
    }
    return _PhoneBottomNav(currentIndex: currentIndex, onTap: onTap);
  }
}

class _PhoneBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _PhoneBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.water_drop_outlined,
                activeIcon: Icons.water_drop_rounded,
                label: 'Today',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Reports',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF0EA5E9)
                    : const Color(0xFF94A3B8),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: Color(0xFF0EA5E9),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletRail extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _TabletRail({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(
        color: Color(0xFF0EA5E9),
        size: 22,
      ),
      unselectedIconTheme: const IconThemeData(
        color: Color(0xFF94A3B8),
        size: 22,
      ),
      selectedLabelTextStyle: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0EA5E9),
      ),
      unselectedLabelTextStyle: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF94A3B8),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop_rounded),
          label: Text('Today'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: Text('Reports'),
        ),
      ],
    );
  }
}
