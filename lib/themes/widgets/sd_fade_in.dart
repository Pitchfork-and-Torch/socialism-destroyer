import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../app_motion.dart';

/// Fade-and-slide entrance for list items and page sections.
///
/// Apply stagger via [delayIndex] for cascading reveals.
class SdFadeIn extends StatelessWidget {
  const SdFadeIn({
    super.key,
    required this.child,
    this.delayIndex = 0,
    this.offsetY = 12,
    this.animate = true,
  });

  final Widget child;
  final int delayIndex;
  final double offsetY;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate || MediaQuery.disableAnimationsOf(context)) {
      return RepaintBoundary(child: child);
    }

    return RepaintBoundary(
      child: child
          .animate()
          .fadeIn(
            duration: AppMotion.fadeInDuration,
            curve: AppMotion.fadeInCurve,
            delay: AppMotion.stagger(delayIndex),
          )
          .slideY(
            begin: offsetY / 100,
            end: 0,
            duration: AppMotion.fadeInDuration,
            curve: AppMotion.fadeInCurve,
            delay: AppMotion.stagger(delayIndex),
          ),
    );
  }
}