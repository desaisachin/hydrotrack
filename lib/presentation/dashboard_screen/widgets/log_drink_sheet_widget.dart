import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class LogDrinkSheetWidget extends StatefulWidget {
  final Function(int amount, String type, IconData icon, Color color) onLog;

  const LogDrinkSheetWidget({super.key, required this.onLog});

  @override
  State<LogDrinkSheetWidget> createState() => _LogDrinkSheetWidgetState();
}

class _LogDrinkSheetWidgetState extends State<LogDrinkSheetWidget> {
  // TODO: Replace with Riverpod for production
  int _selectedAmount = 250;
  int _customAmount = 250;
  String _selectedType = 'Water';
  IconData _selectedIcon = Icons.local_drink_outlined;
  Color _selectedColor = AppTheme.primary;
  bool _useCustom = false;

  final TextEditingController _customController = TextEditingController(
    text: '250',
  );

  static const List<Map<String, dynamic>> _drinkTypes = [
    {
      'type': 'Water',
      'icon': Icons.local_drink_outlined,
      'color': Color(0xFF0EA5E9),
    },
    {
      'type': 'Tea',
      'icon': Icons.emoji_food_beverage_outlined,
      'color': Color(0xFF10B981),
    },
    {
      'type': 'Coffee',
      'icon': Icons.coffee_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'type': 'Juice',
      'icon': Icons.local_bar_outlined,
      'color': Color(0xFFF59E0B),
    },
    {
      'type': 'Smoothie',
      'icon': Icons.blender_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'type': 'Sports',
      'icon': Icons.sports_rounded,
      'color': Color(0xFF06B6D4),
    },
    {
      'type': 'Milk',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFF94A3B8),
    },
    {
      'type': 'Other',
      'icon': Icons.local_cafe_outlined,
      'color': Color(0xFFF59E0B),
    },
  ];

  static const List<int> _amounts = [150, 200, 250, 350, 500, 750];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'Log a Drink',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'What did you drink and how much?',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Drink type selector
            Text(
              'Type',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _drinkTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final dt = _drinkTypes[i];
                  final isSelected = _selectedType == dt['type'];
                  final color = dt['color'] as Color;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedType = dt['type'] as String;
                        _selectedIcon = dt['icon'] as IconData;
                        _selectedColor = color;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 70,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withAlpha(26)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : AppTheme.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            dt['icon'] as IconData,
                            size: 22,
                            color: isSelected ? color : AppTheme.muted,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dt['type'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? color
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Amount selector
            Text(
              'Amount',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._amounts.map((amt) {
                  final isSelected = !_useCustom && _selectedAmount == amt;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedAmount = amt;
                        _useCustom = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withAlpha(26)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? _selectedColor : AppTheme.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '$amt ml',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? _selectedColor
                              : AppTheme.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  );
                }),
                // Custom amount
                GestureDetector(
                  onTap: () => setState(() => _useCustom = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _useCustom
                          ? _selectedColor.withAlpha(26)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _useCustom ? _selectedColor : AppTheme.border,
                        width: _useCustom ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      'Custom',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _useCustom
                            ? _selectedColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_useCustom) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _customController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom amount (ml)',
                  suffixText: 'ml',
                  suffixStyle: GoogleFonts.manrope(
                    color: AppTheme.muted,
                    fontSize: 13,
                  ),
                ),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null && parsed > 0) {
                    setState(() => _customAmount = parsed);
                  }
                },
              ),
            ],
            const SizedBox(height: 28),

            // Summary chip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedColor.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(_selectedIcon, color: _selectedColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '$_selectedType — ${_useCustom ? _customAmount : _selectedAmount} ml',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(((_useCustom ? _customAmount : _selectedAmount)) * 0.033814).toStringAsFixed(1)} oz',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Log button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final amount = _useCustom ? _customAmount : _selectedAmount;
                  widget.onLog(
                    amount,
                    _selectedType,
                    _selectedIcon,
                    _selectedColor,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  'Log ${_useCustom ? _customAmount : _selectedAmount} ml of $_selectedType',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
