import 'package:flutter/material.dart';

import '../app_elevation.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../design_system.dart';

/// Elevated surface card with optional accent stripe and semantic elevation.
class SdCard extends StatelessWidget {
  const SdCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    Widget card = DecoratedBox(
      decoration: AppElevation.cardDecoration(
        isDark: sd.isDark,
        color: sd.surfaceOverlay,
        elevation: elevation ?? AppElevation.mid,
      ).copyWith(
        border: accentColor != null
            ? Border(
                left: BorderSide(color: accentColor!, width: 4),
              )
            : null,
      ),
      child: content,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          hoverColor: sd.accentGold.withValues(alpha: 0.06),
          highlightColor: sd.accentGold.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
          child: card,
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Padding(
        padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
        child: card,
      ),
    );
  }
}