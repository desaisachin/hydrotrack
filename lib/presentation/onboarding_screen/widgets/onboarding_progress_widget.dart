import 'package:flutter/material.dart';

class OnboardingProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i == currentStep;
          final isCompleted = i < currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isCompleted || isActive
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
