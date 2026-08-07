import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'design_system.dart';

/// Material [ThemeData] builders for Socialism Destroyer.
///
/// Dark mode is the primary experience; light mode mirrors the same hierarchy
/// with inverted surfaces. Both meet WCAG 2.1 AA for body text pairings.
abstract final class AppTheme {
  static const String tagline =
      'The ultimate claim-vs-counterclaim engine for individual liberty, '
      'free markets, and American exceptionalism. Fully sourced. Always updated. Built for truth.';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final sd = isDark ? SdTheme.dark : SdTheme.light;
    final scheme = _colorScheme(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [sd],
      scaffoldBackgroundColor: sd.surfaceBase,
      dividerColor: sd.borderSubtle,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: AppTypography.build(isDark: isDark),
      appBarTheme: _appBarTheme(isDark),
      cardTheme: _cardTheme(isDark),
      elevatedButtonTheme: _elevatedButtonTheme(isDark),
      filledButtonTheme: _filledButtonTheme(isDark),
      outlinedButtonTheme: _outlinedButtonTheme(isDark),
      textButtonTheme: _textButtonTheme(isDark),
      iconButtonTheme: _iconButtonTheme(isDark),
      chipTheme: _chipTheme(isDark),
      inputDecorationTheme: _inputTheme(isDark),
      navigationBarTheme: _navBarTheme(isDark),
      listTileTheme: _listTileTheme(isDark),
      dividerTheme: DividerThemeData(
        color: sd.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: sd.accentGold,
        linearTrackColor: sd.borderSubtle,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.navyLight : AppColors.navy,
        contentTextStyle: AppFonts.inter(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: AppRadius.button,
          border: Border.all(color: AppColors.divider),
        ),
        textStyle: AppFonts.inter(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.navyDark,
        modalBackgroundColor: AppColors.navyDark,
        dragHandleColor: AppColors.textMuted,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ColorScheme _colorScheme(bool isDark) => ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.gold,
        onPrimary: AppColors.navy,
        primaryContainer: isDark ? AppColors.navyLight : AppColors.offWhite,
        onPrimaryContainer:
            isDark ? AppColors.goldLight : AppColors.goldMuted,
        secondary: isDark ? AppColors.navyLight : AppColors.dividerLight,
        onSecondary: isDark ? AppColors.textPrimary : AppColors.textOnLight,
        secondaryContainer: isDark ? AppColors.cardSurface : AppColors.white,
        onSecondaryContainer:
            isDark ? AppColors.textSecondary : AppColors.textOnLightSecondary,
        tertiary: AppColors.danger,
        onTertiary: AppColors.white,
        error: AppColors.danger,
        onError: AppColors.white,
        surface: isDark ? AppColors.cardSurface : AppColors.white,
        onSurface: isDark ? AppColors.textPrimary : AppColors.textOnLight,
        onSurfaceVariant:
            isDark ? AppColors.textSecondary : AppColors.textOnLightSecondary,
        outline: isDark ? AppColors.divider : AppColors.dividerLight,
        outlineVariant: isDark ? AppColors.navyMid : AppColors.dividerLight,
        shadow: AppColors.navyDark,
        surfaceTint: AppColors.gold,
      );

  static AppBarTheme _appBarTheme(bool isDark) => AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.goldLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppFonts.libreBaskerville(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.goldLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight, size: 22),
      );

  static CardThemeData _cardTheme(bool isDark) => CardThemeData(
        color: isDark ? AppColors.cardSurface : AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(
            color: isDark ? AppColors.divider : AppColors.dividerLight,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      );

  static ButtonStyle _primaryButtonStyle(bool isDark) => FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.35),
        disabledForegroundColor: AppColors.navy.withValues(alpha: 0.5),
        minimumSize: const Size(0, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(bool isDark) =>
      ElevatedButtonThemeData(style: _primaryButtonStyle(isDark));

  static FilledButtonThemeData _filledButtonTheme(bool isDark) =>
      FilledButtonThemeData(style: _primaryButtonStyle(isDark));

  static OutlinedButtonThemeData _outlinedButtonTheme(bool isDark) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.goldLight : AppColors.goldMuted,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          side: BorderSide(
            color: isDark ? AppColors.gold : AppColors.goldMuted,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppFonts.inter(fontWeight: FontWeight.w600),
        ),
      );

  static TextButtonThemeData _textButtonTheme(bool isDark) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.goldLight : AppColors.goldMuted,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          textStyle: AppFonts.inter(fontWeight: FontWeight.w600),
        ),
      );

  static IconButtonThemeData _iconButtonTheme(bool isDark) =>
      IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.goldLight : AppColors.goldMuted,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          splashFactory: NoSplash.splashFactory,
          hoverColor: AppColors.gold.withValues(alpha: isDark ? 0.1 : 0.08),
          highlightColor: AppColors.gold.withValues(alpha: isDark ? 0.16 : 0.12),
        ),
      );

  static ChipThemeData _chipTheme(bool isDark) => ChipThemeData(
        backgroundColor: isDark
            ? AppColors.dangerSubtle
            : AppColors.danger.withValues(alpha: 0.08),
        labelStyle: AppFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimary : AppColors.dangerMuted,
        ),
        side: BorderSide(
          color: AppColors.danger.withValues(alpha: isDark ? 0.6 : 0.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
      );

  static InputDecorationTheme _inputTheme(bool isDark) => InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.navyLight : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: isDark ? AppColors.divider : AppColors.dividerLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: isDark ? AppColors.divider : AppColors.dividerLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.focusRing, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: AppFonts.inter(
          color: isDark ? AppColors.textMuted : AppColors.textOnLightMuted,
          fontSize: 14,
        ),
        labelStyle: AppFonts.inter(
          color: isDark ? AppColors.textSecondary : AppColors.textOnLightSecondary,
        ),
      );

  static NavigationBarThemeData _navBarTheme(bool isDark) =>
      NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.navy,
        indicatorColor: AppColors.gold.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.goldLight : AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.goldLight : AppColors.textMuted,
            size: 22,
          );
        }),
      );

  static ListTileThemeData _listTileTheme(bool isDark) => ListTileThemeData(
        iconColor: isDark ? AppColors.goldLight : AppColors.goldMuted,
        textColor: isDark ? AppColors.textPrimary : AppColors.textOnLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        minVerticalPadding: AppSpacing.xs,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );
}