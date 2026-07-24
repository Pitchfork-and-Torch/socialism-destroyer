import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Subtle decorative U.S. flag for site chrome — non-interactive accent.
class AmericanFlagBadge extends StatelessWidget {
  const AmericanFlagBadge({
    super.key,
    this.height = 28,
    this.opacity = 0.42,
  });

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final width = height * 1.9;

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: _AmericanFlagPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmericanFlagPainter extends CustomPainter {
  static const _red = Color(0xFFB22234);
  static const _blue = Color(0xFF3C3B6E);
  static const _white = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    const stripeCount = 13;
    final stripeH = size.height / stripeCount;

    for (var i = 0; i < stripeCount; i++) {
      final paint = Paint()..color = i.isEven ? _red : _white;
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeH, size.width, stripeH),
        paint,
      );
    }

    final cantonW = size.width * 0.4;
    final cantonH = stripeH * 7;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cantonW, cantonH),
      Paint()..color = _blue,
    );

    final starPaint = Paint()..color = _white;
    const cols = 6;
    const rows = 5;
    final starR = stripeH * 0.16;
    final xStep = cantonW / (cols + 1);
    final yStep = cantonH / (rows + 1);

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final offsetX = (row.isOdd ? xStep * 0.5 : 0) + (col + 1) * xStep;
        final offsetY = (row + 1) * yStep;
        _drawStar(canvas, Offset(offsetX, offsetY), starR, starPaint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.38;
      final angle = (i * 3.14159265 / points) - 3.14159265 / 2;
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