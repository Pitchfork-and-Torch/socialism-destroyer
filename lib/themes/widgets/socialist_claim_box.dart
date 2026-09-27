import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../design_system.dart';
import 'sd_card.dart';
import 'sd_section_header.dart';

/// Red-accented panel presenting the socialist claim being countered.
class SocialistClaimBox extends StatelessWidget {
  const SocialistClaimBox({
    super.key,
    required this.claimText,
    this.quote,
    this.quoteAttribution,
    this.title = 'The Socialist Claim',
  });

  final String claimText;
  final String? quote;
  final String? quoteAttribution;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sd = context.sd;

    return SdCard(
      accentColor: AppColors.dangerMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SdSectionHeader(
            title: title,
            accentColor: AppColors.danger,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            claimText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: sd.textHigh,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (quote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.dangerSubtle.withValues(
                  alpha: sd.isDark ? 0.6 : 0.08,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$quote"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (quoteAttribution != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '— $quoteAttribution',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: sd.accentGold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}