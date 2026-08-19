import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Elevation and shadow tokens for layered surfaces.
abstract final class AppElevation {
  static const double none = 0;
  static const double low = 1;
  static const double mid = 2;
  static const double high = 4;
  static const double overlay = 8;

  static List<BoxShadow> shadow(bool isDark, {double level = mid}) {
    final opacity = isDark ? 0.35 : 0.12;
    final blur = level * 4;
    final y = level * 2;
    return [
      BoxShadow(
        color: AppColors.navyDark.withValues(alpha: opacity),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
    ];
  }

  static BoxDecoration cardDecoration({
    required bool isDark,
    Color? color,
    Color? borderColor,
    double elevation = mid,
  }) =>
      BoxDecoration(
        color: color ?? (isDark ? AppColors.cardSurface : AppColors.white),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: borderColor ??
              (isDark ? AppColors.divider : AppColors.dividerLight),
        ),
        boxShadow: elevation > 0 ? shadow(isDark, level: elevation) : null,
      );
}