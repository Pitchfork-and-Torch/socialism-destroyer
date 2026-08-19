import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../design_system.dart';
import 'sd_card.dart';
import 'sd_section_header.dart';

/// Bulleted evidence panel with gold markers.
class EvidenceListBox extends StatelessWidget {
  const EvidenceListBox({
    super.key,
    required this.bullets,
    this.title = 'Key Evidence',
  });

  final List<String> bullets;
  final String title;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return SdCard(
      accentColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SdSectionHeader(
            title: title,
            accentColor: AppColors.success,
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: sd.accentGold,
                      semanticLabel: 'Evidence point',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(b, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}