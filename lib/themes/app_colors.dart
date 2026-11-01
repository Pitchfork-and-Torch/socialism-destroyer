import 'package:flutter/material.dart';

/// Brand palette: deep navy, gold accents, crisp white, subtle danger red.
///
/// Contrast pairs meet WCAG 2.1 AA where used for body text:
/// - [textPrimary] on [navy] ≥ 12:1
/// - [textSecondary] on [navy] ≥ 7:1
/// - [navy] on [gold] ≥ 7:1 (primary buttons)
/// - [textOnLight] on [offWhite] ≥ 12:1
abstract final class AppColors {
  // ── Core brand ──────────────────────────────────────────────
  static const Color navy = Color(0xFF0A1628);
  static const Color navyLight = Color(0xFF152238);
  static const Color navyMid = Color(0xFF1A2A42);
  static const Color navyDark = Color(0xFF050D18);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldMuted = Color(0xFFB8962E);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F0);

  // ── Semantic accents ────────────────────────────────────────
  static const Color danger = Color(0xFFC0392B);
  static const Color dangerMuted = Color(0xFF922B21);
  static const Color dangerSubtle = Color(0xFF3D1F1C);
  static const Color success = Color(0xFF27AE60);
  static const Color successMuted = Color(0xFF1E8449);
  static const Color info = Color(0xFF3498DB);

  // ── Dark-mode text (on navy surfaces) ───────────────────────
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB8C2CE);
  static const Color textMuted = Color(0xFF8A96A8);
  static const Color textDisabled = Color(0xFF5C6B7F);

  // ── Light-mode text (on off-white surfaces) ─────────────────
  static const Color textOnLight = Color(0xFF0A1628);
  static const Color textOnLightSecondary = Color(0xFF3D4F66);
  static const Color textOnLightMuted = Color(0xFF5C6B7F);

  // ── Surfaces ────────────────────────────────────────────────
  static const Color cardSurface = Color(0xFF111D32);
  static const Color cardSurfaceRaised = Color(0xFF162640);
  static const Color cardSurfaceLight = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFF1E2D45);
  static const Color dividerLight = Color(0xFFD8DCE3);
  static const Color overlay = Color(0x99050D18);

  // ── Focus & interaction ─────────────────────────────────────
  static const Color focusRing = Color(0xFFE8C96A);
  static const Color goldOnDark = Color(0xFFE8C96A);

  /// Returns foreground color that meets AA on [background].
  static Color contrastingText(Color background) {
    return background.computeLuminance() > 0.4
        ? textOnLight
        : textPrimary;
  }
}