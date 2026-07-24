import 'package:flutter/material.dart';

import '../../models/claim.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../design_system.dart';
import 'sd_card.dart';

enum ClaimCardVariant { compact, standard, featured }

/// Reusable claim preview card for tree lists, search, and home feeds.
class ClaimCard extends StatelessWidget {
  const ClaimCard({
    super.key,
    required this.claim,
    required this.onTap,
    this.variant = ClaimCardVariant.standard,
    this.showTags = false,
  });

  final Claim claim;
  final VoidCallback onTap;
  final ClaimCardVariant variant;
  final bool showTags;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    if (variant == ClaimCardVariant.compact) {
      return Semantics(
        label: 'Claim: ${claim.title}',
        button: true,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            leading: Icon(
              Icons.article_outlined,
              size: 20,
              color: sd.textLow,
            ),
            title: Text(
              claim.title,
              style: theme.textTheme.titleSmall?.copyWith(color: sd.textHigh),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              claim.executiveSummary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            trailing: Icon(Icons.chevron_right, size: 18, color: sd.accentGold),
            onTap: onTap,
          ),
        ),
      );
    }

    return SdCard(
      onTap: onTap,
      accentColor: variant == ClaimCardVariant.featured ? sd.accentGold : null,
      semanticLabel: 'Claim: ${claim.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: sd.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  size: 18,
                  color: sd.accentGold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      claim.socialistClaimText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.danger.withValues(alpha: 0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: sd.accentGold, size: 20),
            ],
          ),
          if (variant == ClaimCardVariant.featured) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              claim.executiveSummary,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showTags && claim.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: claim.tags.take(4).map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: sd.borderSubtle.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(t, style: theme.textTheme.labelSmall),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.source_outlined, size: 14, color: sd.textLow),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${claim.sources.length} sources',
                style: theme.textTheme.labelSmall,
              ),
              if (claim.chartData != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.bar_chart_rounded, size: 14, color: sd.accentGold),
                const SizedBox(width: 2),
                Text('Chart', style: theme.textTheme.labelSmall),
              ],
              if (claim.claimQuote != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.format_quote_rounded, size: 14, color: sd.accentGold),
                const SizedBox(width: 2),
                Text('PD quote', style: theme.textTheme.labelSmall),
              ],
            ],
          ),
        ],
      ),
    );
  }
}