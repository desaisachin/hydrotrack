import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StepProfileWidget extends StatelessWidget {
  final String gender;
  final double age;
  final double weight;
  final String weightUnit;
  final double activityLevel;
  final Function(String) onGenderChanged;
  final Function(double) onAgeChanged;
  final Function(double) onWeightChanged;
  final Function(String) onWeightUnitChanged;
  final Function(double) onActivityChanged;

  const StepProfileWidget({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.weightUnit,
    required this.activityLevel,
    required this.onGenderChanged,
    required this.onAgeChanged,
    required this.onWeightChanged,
    required this.onWeightUnitChanged,
    required this.onActivityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Tell us about\nyourself',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll calculate your personalized daily hydration goal',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Gender selector
          Text(
            'Gender',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _GenderCard(
                label: 'Male',
                icon: Icons.male_rounded,
                isSelected: gender == 'male',
                onTap: () => onGenderChanged('male'),
              ),
              const SizedBox(width: 12),
              _GenderCard(
                label: 'Female',
                icon: Icons.female_rounded,
                isSelected: gender == 'female',
                onTap: () => onGenderChanged('female'),
              ),
              const SizedBox(width: 12),
              _GenderCard(
                label: 'Other',
                icon: Icons.person_outline_rounded,
                isSelected: gender == 'other',
                onTap: () => onGenderChanged('other'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Age slider
          _SliderField(
            label: 'Age',
            value: age,
            min: 10,
            max: 90,
            displayValue: '${age.round()} yrs',
            onChanged: onAgeChanged,
          ),
          const SizedBox(height: 24),

          // Weight slider + unit toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SliderField(
                  label: 'Weight',
                  value: weight,
                  min: weightUnit == 'kg' ? 30 : 66,
                  max: weightUnit == 'kg' ? 200 : 440,
                  displayValue: '${weight.round()} $weightUnit',
                  onChanged: onWeightChanged,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _UnitToggle(
                    selected: weightUnit,
                    options: const ['kg', 'lbs'],
                    onChanged: onWeightUnitChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Activity level
          Text(
            'Activity Level',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _ActivitySelector(value: activityLevel, onChanged: onActivityChanged),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0EA5E9).withAlpha(20)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFF0EA5E9)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final Function(double) onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              displayValue,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: AppTheme.primary,
            overlayColor: AppTheme.primary.withAlpha(31),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final String selected;
  final List<String> options;
  final Function(String) onChanged;

  const _UnitToggle({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((o) {
          final isSelected = o == selected;
          return GestureDetector(
            onTap: () => onChanged(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                o,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActivitySelector extends StatelessWidget {
  final double value;
  final Function(double) onChanged;

  const _ActivitySelector({required this.value, required this.onChanged});

  static const List<Map<String, dynamic>> _levels = [
    {
      'label': 'Sedentary',
      'sub': 'Little/no exercise',
      'icon': Icons.weekend_outlined,
      'value': 1.2,
    },
    {
      'label': 'Light',
      'sub': '1–3 days/week',
      'icon': Icons.directions_walk_rounded,
      'value': 1.3,
    },
    {
      'label': 'Moderate',
      'sub': '3–5 days/week',
      'icon': Icons.directions_run_rounded,
      'value': 1.5,
    },
    {
      'label': 'Active',
      'sub': '6–7 days/week',
      'icon': Icons.fitness_center_rounded,
      'value': 1.7,
    },
    {
      'label': 'Athlete',
      'sub': 'Twice daily',
      'icon': Icons.sports_rounded,
      'value': 1.9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _levels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final level = _levels[i];
          final isSelected = (value - (level['value'] as double)).abs() < 0.05;
          return GestureDetector(
            onTap: () => onChanged(level['value'] as double),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 90,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withAlpha(20)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    level['icon'] as IconData,
                    size: 22,
                    color: isSelected ? AppTheme.primary : AppTheme.muted,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    level['label'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    level['sub'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.muted,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
