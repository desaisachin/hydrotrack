import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StepPresetsWidget extends StatefulWidget {
  final VoidCallback onContinue;

  const StepPresetsWidget({super.key, required this.onContinue});

  @override
  State<StepPresetsWidget> createState() => _StepPresetsWidgetState();
}

class _StepPresetsWidgetState extends State<StepPresetsWidget> {
  // TODO: Replace with Riverpod for production
  final List<Map<String, dynamic>> _presets = [
    {
      'label': 'Small Cup',
      'ml': 150,
      'icon': Icons.coffee_outlined,
      'color': const Color(0xFFF59E0B),
      'enabled': true,
    },
    {
      'label': 'Glass',
      'ml': 250,
      'icon': Icons.local_drink_outlined,
      'color': const Color(0xFF0EA5E9),
      'enabled': true,
    },
    {
      'label': 'Mug',
      'ml': 350,
      'icon': Icons.coffee_rounded,
      'color': const Color(0xFF8B5CF6),
      'enabled': true,
    },
    {
      'label': 'Bottle',
      'ml': 500,
      'icon': Icons.water_rounded,
      'color': const Color(0xFF10B981),
      'enabled': true,
    },
    {
      'label': 'Large Bottle',
      'ml': 750,
      'icon': Icons.sports_bar_outlined,
      'color': const Color(0xFF06B6D4),
      'enabled': false,
    },
    {
      'label': 'Litre Bottle',
      'ml': 1000,
      'icon': Icons.local_bar_outlined,
      'color': const Color(0xFFEF4444),
      'enabled': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Quick-log\npresets',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your common drink sizes for one-tap logging',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: _presets.length,
            itemBuilder: (_, i) {
              final preset = _presets[i];
              final enabled = preset['enabled'] as bool;
              final color = preset['color'] as Color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _presets[i]['enabled'] = !enabled;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: enabled ? color.withAlpha(20) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: enabled ? color : AppTheme.border,
                      width: enabled ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        preset['icon'] as IconData,
                        size: 28,
                        color: enabled ? color : AppTheme.muted,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preset['label'] as String,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? AppTheme.textPrimary
                              : AppTheme.muted,
                        ),
                      ),
                      Text(
                        '${preset['ml']} ml',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: enabled ? color : AppTheme.muted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (enabled)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Start Tracking 🎉',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
