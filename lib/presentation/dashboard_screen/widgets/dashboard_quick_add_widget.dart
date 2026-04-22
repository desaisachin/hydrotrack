import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DashboardQuickAddWidget extends StatelessWidget {
  final Function(int amount, String type, IconData icon, Color color)
  onQuickAdd;

  const DashboardQuickAddWidget({super.key, required this.onQuickAdd});

  static const List<Map<String, dynamic>> _presets = [
    {
      'label': 'Glass',
      'ml': 250,
      'icon': Icons.local_drink_outlined,
      'color': Color(0xFF0EA5E9),
      'type': 'Water',
    },
    {
      'label': 'Mug',
      'ml': 350,
      'icon': Icons.coffee_rounded,
      'color': Color(0xFF8B5CF6),
      'type': 'Tea/Coffee',
    },
    {
      'label': 'Bottle',
      'ml': 500,
      'icon': Icons.water_rounded,
      'color': Color(0xFF10B981),
      'type': 'Water',
    },
    {
      'label': 'Cup',
      'ml': 150,
      'icon': Icons.emoji_food_beverage_outlined,
      'color': Color(0xFFF59E0B),
      'type': 'Other',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Add',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'tap to log instantly',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _presets.map((preset) {
              final color = preset['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: _presets.last == preset ? 0 : 10,
                  ),
                  child: _QuickAddButton(
                    label: preset['label'] as String,
                    ml: preset['ml'] as int,
                    icon: preset['icon'] as IconData,
                    color: color,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onQuickAdd(
                        preset['ml'] as int,
                        preset['type'] as String,
                        preset['icon'] as IconData,
                        color,
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  final String label;
  final int ml;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.ml,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withAlpha(64)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 22, color: widget.color),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${widget.ml} ml',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: widget.color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
