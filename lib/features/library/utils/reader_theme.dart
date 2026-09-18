import 'package:flutter/material.dart';

import '../../../models/reader_settings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_fonts.dart';

class ReaderThemeColors {
  const ReaderThemeColors({
    required this.background,
    required this.textHigh,
    required this.textMedium,
    required this.accent,
  });

  final Color background;
  final Color textHigh;
  final Color textMedium;
  final Color accent;

  static ReaderThemeColors forMode(ReaderThemeMode mode) => switch (mode) {
        ReaderThemeMode.navy => const ReaderThemeColors(
            background: AppColors.navy,
            textHigh: AppColors.textPrimary,
            textMedium: AppColors.textSecondary,
            accent: AppColors.gold,
          ),
        ReaderThemeMode.sepia => const ReaderThemeColors(
            background: Color(0xFF2A2118),
            textHigh: Color(0xFFF4E8D0),
            textMedium: Color(0xFFC9B896),
            accent: Color(0xFFD4AF37),
          ),
        ReaderThemeMode.paper => const ReaderThemeColors(
            background: Color(0xFFF5F0E6),
            textHigh: Color(0xFF1A1A1A),
            textMedium: Color(0xFF4A4A4A),
            accent: Color(0xFF8B6914),
          ),
      };

  TextStyle bodyStyle(ReaderSettings settings) {
    final base = settings.fontFamily == ReaderFontFamily.serif
        ? AppFonts.lora()
        : AppFonts.inter();
    return base.copyWith(
      fontSize: 17 * settings.fontScale,
      height: settings.lineHeight,
      color: textHigh,
    );
  }

  TextStyle headerStyle(ReaderSettings settings, {int level = 1}) {
    final scale = settings.fontScale;
    final base = settings.fontFamily == ReaderFontFamily.serif
        ? AppFonts.playfairDisplay()
        : AppFonts.inter();
    return switch (level) {
      1 => base.copyWith(
          fontSize: 26 * scale,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      2 => base.copyWith(
          fontSize: 20 * scale,
          fontWeight: FontWeight.w600,
          color: textHigh,
        ),
      _ => base.copyWith(
          fontSize: 16 * scale,
          fontStyle: FontStyle.italic,
          color: textMedium,
        ),
    };
  }
}