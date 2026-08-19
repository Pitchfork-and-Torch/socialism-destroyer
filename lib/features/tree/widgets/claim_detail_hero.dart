import 'package:flutter/material.dart';

import '../../../models/claim.dart';
import '../../../themes/themes.dart';

/// Scannable hero header for claim detail screens.
class ClaimDetailHero extends StatelessWidget {
  const ClaimDetailHero({
    super.key,
    required this.claim,
    this.topicTitle,
  });

  final Claim claim;
  final String? topicTitle;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyLight,
            sd.isDark ? AppColors.navy : AppColors.offWhite,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: sd.borderSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topicTitle != null) ...[
            Row(
              children: [
                Icon(Icons.folder_outlined, size: 16, color: sd.accentGold),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Text(
                    topicTitle!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: sd.accentGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            claim.title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              ...claim.tags.take(6).map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: sd.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: sd.accentGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(tag, style: theme.textTheme.labelSmall),
                    ),
                  ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: sd.borderSubtle.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${claim.sources.length} sources',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}