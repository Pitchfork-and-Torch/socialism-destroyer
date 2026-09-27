import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';

/// Subtle navy field with gold star accents — professional, never cartoonish.
class OnboardingPatrioticBackdrop extends StatelessWidget {
  const OnboardingPatrioticBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDark, AppColors.navy, AppColors.navyLight],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: _StarFieldPainter()),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldMuted, AppColors.gold, AppColors.goldMuted],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final rng = math.Random(42);
    for (var i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 1.2 + rng.nextDouble() * 2.2;
      _drawStar(canvas, Offset(x, y), r, paint);
    }

    final ring = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 80, ring);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.78), 120, ring);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}