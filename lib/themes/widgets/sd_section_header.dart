import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../design_system.dart';

/// Section title with optional gold accent bar — used inside [SdCard].
class SdSectionHeader extends StatelessWidget {
  const SdSectionHeader({
    super.key,
    required this.title,
    this.accentColor,
    this.icon,
  });

  final String title;
  final Color? accentColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final accent = accentColor ?? sd.accentGold;

    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        if (icon != null) ...[
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}