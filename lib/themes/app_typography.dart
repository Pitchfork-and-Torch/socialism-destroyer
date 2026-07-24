import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Type scale: Inter for UI/body, Libre Baskerville for display authority.
abstract final class AppTypography {
  static TextTheme build({required bool isDark}) {
    final primary = isDark ? AppColors.textPrimary : AppColors.textOnLight;
    final secondary =
        isDark ? AppColors.textSecondary : AppColors.textOnLightSecondary;
    final muted = isDark ? AppColors.textMuted : AppColors.textOnLightMuted;
    final display = isDark ? AppColors.goldLight : AppColors.goldMuted;

    return TextTheme(
      displayLarge: AppFonts.libreBaskerville(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: display,
      ),
      displayMedium: AppFonts.libreBaskerville(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: display,
      ),
      headlineLarge: AppFonts.libreBaskerville(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      headlineMedium: AppFonts.libreBaskerville(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),
      headlineSmall: AppFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      ),
      titleLarge: AppFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      ),
      titleMedium: AppFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: primary,
      ),
      titleSmall: AppFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: secondary,
      ),
      bodyLarge: AppFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: primary,
      ),
      bodyMedium: AppFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: secondary,
      ),
      bodySmall: AppFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: muted,
      ),
      labelLarge: AppFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.3,
        color: isDark ? AppColors.goldLight : AppColors.goldMuted,
      ),
      labelMedium: AppFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.5,
        color: muted,
      ),
      labelSmall: AppFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.6,
        color: muted,
      ),
    );
  }
}