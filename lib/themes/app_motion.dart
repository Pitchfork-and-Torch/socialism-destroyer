import 'package:flutter/material.dart';

/// Motion design tokens and animation guidelines.
///
/// **Tree expansion:** use [treeExpandCurve] or [treeSpring] for organic feel.
/// **Content reveal:** use [fadeInDuration] + [fadeInCurve] for page sections.
/// **Micro-interactions:** use [quickDuration] for toggles and chips.
abstract final class AppMotion {
  // ── Durations ───────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration fadeInDuration = Duration(milliseconds: 400);
  static const Duration treeExpandDuration = Duration(milliseconds: 380);

  // ── Curves ──────────────────────────────────────────────────
  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve fadeInCurve = Curves.easeOut;
  static const Curve treeExpandCurve = Curves.easeOutBack;

  /// Spring for tree node expand/collapse (mass, stiffness, damping).
  static SpringDescription get treeSpring => const SpringDescription(
        mass: 0.8,
        stiffness: 380,
        damping: 22,
      );

  /// Spring for subtle card press feedback.
  static SpringDescription get cardSpring => const SpringDescription(
        mass: 0.5,
        stiffness: 500,
        damping: 28,
      );

  /// Stagger delay between list item fade-ins.
  static Duration stagger(int index) =>
      Duration(milliseconds: 60 * index.clamp(0, 8));
}