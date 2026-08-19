import 'package:flutter/material.dart';

import 'app_colors.dart';
/// Theme extension exposing design-system tokens via [BuildContext].
///
/// ```dart
/// final sd = context.sd;
/// padding: EdgeInsets.all(AppSpacing.md),
/// ```
@immutable
class SdTheme extends ThemeExtension<SdTheme> {
  const SdTheme({
    required this.isDark,
    required this.accentGold,
    required this.accentRed,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.borderSubtle,
    required this.textHigh,
    required this.textMedium,
    required this.textLow,
  });

  final bool isDark;
  final Color accentGold;
  final Color accentRed;
  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceOverlay;
  final Color borderSubtle;
  final Color textHigh;
  final Color textMedium;
  final Color textLow;

  static SdTheme of(BuildContext context) {
    return Theme.of(context).extension<SdTheme>() ??
        SdTheme.dark;
  }

  static const SdTheme dark = SdTheme(
    isDark: true,
    accentGold: AppColors.goldLight,
    accentRed: AppColors.danger,
    surfaceBase: AppColors.navy,
    surfaceRaised: AppColors.cardSurfaceRaised,
    surfaceOverlay: AppColors.cardSurface,
    borderSubtle: AppColors.divider,
    textHigh: AppColors.textPrimary,
    textMedium: AppColors.textSecondary,
    textLow: AppColors.textMuted,
  );

  static const SdTheme light = SdTheme(
    isDark: false,
    accentGold: AppColors.goldMuted,
    accentRed: AppColors.danger,
    surfaceBase: AppColors.offWhite,
    surfaceRaised: AppColors.white,
    surfaceOverlay: AppColors.white,
    borderSubtle: AppColors.dividerLight,
    textHigh: AppColors.textOnLight,
    textMedium: AppColors.textOnLightSecondary,
    textLow: AppColors.textOnLightMuted,
  );

  @override
  SdTheme copyWith({
    bool? isDark,
    Color? accentGold,
    Color? accentRed,
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceOverlay,
    Color? borderSubtle,
    Color? textHigh,
    Color? textMedium,
    Color? textLow,
  }) =>
      SdTheme(
        isDark: isDark ?? this.isDark,
        accentGold: accentGold ?? this.accentGold,
        accentRed: accentRed ?? this.accentRed,
        surfaceBase: surfaceBase ?? this.surfaceBase,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
        borderSubtle: borderSubtle ?? this.borderSubtle,
        textHigh: textHigh ?? this.textHigh,
        textMedium: textMedium ?? this.textMedium,
        textLow: textLow ?? this.textLow,
      );

  @override
  SdTheme lerp(ThemeExtension<SdTheme>? other, double t) {
    if (other is! SdTheme) return this;
    return SdTheme(
      isDark: t < 0.5 ? isDark : other.isDark,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textHigh: Color.lerp(textHigh, other.textHigh, t)!,
      textMedium: Color.lerp(textMedium, other.textMedium, t)!,
      textLow: Color.lerp(textLow, other.textLow, t)!,
    );
  }
}

extension SdThemeContext on BuildContext {
  SdTheme get sd => SdTheme.of(this);
}