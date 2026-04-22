import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';

class DashboardProgressRingWidget extends StatefulWidget {
  final double progress;
  final double intakeMl;
  final double goalMl;
  final double remainingMl;
  final bool isLoading;

  const DashboardProgressRingWidget({
    super.key,
    required this.progress,
    required this.intakeMl,
    required this.goalMl,
    required this.remainingMl,
    required this.isLoading,
  });

  @override
  State<DashboardProgressRingWidget> createState() =>
      _DashboardProgressRingWidgetState();
}

class _DashboardProgressRingWidgetState
    extends State<DashboardProgressRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (!widget.isLoading) _controller.forward();
  }

  @override
  void didUpdateWidget(DashboardProgressRingWidget old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _progressAnimation =
          Tween<double>(begin: _previousProgress, end: widget.progress).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _previousProgress = widget.progress;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  HydrationStatus get _status {
    final p = widget.progress;
    final hour = DateTime.now().hour;
    final expectedPace = (hour / 16).clamp(0.0, 1.0);
    if (p >= 1.0) return HydrationStatus.goalMet;
    if (p > 1.0) return HydrationStatus.exceeded;
    if (p >= expectedPace) return HydrationStatus.onTrack;
    if (p >= expectedPace * 0.7) return HydrationStatus.inProgress;
    if (p == 0) return HydrationStatus.notStarted;
    return HydrationStatus.warning;
  }

  @override
  Widget build(BuildContext context) {
    final intakeLiters = (widget.intakeMl / 1000).toStringAsFixed(1);
    final goalLiters = (widget.goalMl / 1000).toStringAsFixed(1);
    final remainingMl = widget.remainingMl.round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Progress",
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                StatusBadgeWidget(status: _status),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (_, __) {
                return SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _ProgressRingPainter(
                      progress: _progressAnimation.value,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$intakeLiters L',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            'of $goalLiters L goal',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_progressAnimation.value * 100).round()}%',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Remaining indicator
            if (widget.progress < 1.0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_drink_outlined,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$remainingMl ml remaining to reach your goal',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Daily goal achieved! Great work 🎉',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;

  _ProgressRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;
    const strokeWidth = 18.0;

    // Background ring
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F9FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Tick marks at 25%, 50%, 75%
    final tickPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 1; i < 4; i++) {
      final angle = -3.14159 / 2 + 2 * 3.14159 * (i / 4);
      final x1 = center.dx + (radius - 10) * cos(angle);
      final y1 = center.dy + (radius - 10) * sin(angle);
      final x2 = center.dx + (radius + 10) * cos(angle);
      final y2 = center.dy + (radius + 10) * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Progress arc with gradient
    if (progress > 0) {
      final sweepAngle = 2 * 3.14159 * progress.clamp(0.0, 1.0);
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -3.14159 / 2,
        endAngle: -3.14159 / 2 + sweepAngle,
        colors: progress >= 1.0
            ? [const Color(0xFF10B981), const Color(0xFF06B6D4)]
            : [const Color(0xFF0EA5E9), const Color(0xFF06B6D4)],
      );
      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -3.14159 / 2, sweepAngle, false, progressPaint);
    }
  }

  double cos(double radians) => _cos(radians);
  double sin(double radians) => _sin(radians);

  double _cos(double r) {
    // Simple approximation using dart:math conceptually
    // In production: import dart:math and use math.cos
    return _mathCos(r);
  }

  double _sin(double r) {
    return _mathSin(r);
  }

  double _mathCos(double x) {
    // Taylor series approximation for cos
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _mathSin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}
