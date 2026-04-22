import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StepGoalRevealWidget extends StatefulWidget {
  final double dailyGoalMl;
  final String gender;
  final double weight;
  final String weightUnit;
  final double activityLevel;

  const StepGoalRevealWidget({
    super.key,
    required this.dailyGoalMl,
    required this.gender,
    required this.weight,
    required this.weightUnit,
    required this.activityLevel,
  });

  @override
  State<StepGoalRevealWidget> createState() => _StepGoalRevealWidgetState();
}

class _StepGoalRevealWidgetState extends State<StepGoalRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ringAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ringAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _controller.forward(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _activityLabel() {
    if (widget.activityLevel <= 1.2) return 'sedentary lifestyle';
    if (widget.activityLevel <= 1.3) return 'light activity';
    if (widget.activityLevel <= 1.5) return 'moderate activity';
    if (widget.activityLevel <= 1.7) return 'active lifestyle';
    return 'athletic training';
  }

  @override
  Widget build(BuildContext context) {
    final goalLiters = (widget.dailyGoalMl / 1000).toStringAsFixed(1);
    final goalOz = (widget.dailyGoalMl * 0.033814).toStringAsFixed(0);
    final glasses = (widget.dailyGoalMl / 250).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            'Your personal\nhydration goal',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Animated ring reveal
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _GoalRingPainter(progress: _ringAnimation.value),
                      child: Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$goalLiters L',
                                style: GoogleFonts.manrope(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              Text(
                                '$goalOz oz',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Stats row
                        Row(
                          children: [
                            _StatChip(
                              icon: Icons.local_drink_outlined,
                              label: '$glasses glasses',
                              sub: '250ml each',
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Icons.science_outlined,
                              label: _activityLabel(),
                              sub: 'Activity basis',
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Based on your ${widget.gender} profile, '
                                  '${widget.weight.round()} ${widget.weightUnit} body weight, '
                                  'and ${_activityLabel()}. '
                                  'You can adjust this anytime.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  final double progress;

  _GoalRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 16.0;

    // Background ring
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final gradient = SweepGradient(
      startAngle: -3.14159 / 2,
      endAngle: -3.14159 / 2 + 2 * 3.14159 * progress,
      colors: const [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_GoalRingPainter old) => old.progress != progress;
}
