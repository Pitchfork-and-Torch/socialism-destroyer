import 'package:flutter/material.dart';

import '../../../models/claim.dart';
import '../../../models/topic.dart';
import '../../../themes/themes.dart';
import '../../library/widgets/topic_reading_recommendations.dart';

/// Right-hand (or inline) panel listing claims for a selected topic.
class TopicClaimsPanel extends StatelessWidget {
  const TopicClaimsPanel({
    super.key,
    required this.topic,
    required this.claims,
    required this.onClaimTap,
    this.filter = '',
  });

  final Topic? topic;
  final List<Claim> claims;
  final void Function(String claimId) onClaimTap;
  final String filter;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    if (topic == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_tree_outlined, size: 48, color: sd.textLow),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Select a topic',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose a category from the tree to browse sourced counter-arguments.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(topic!.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(topic!.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${claims.length} claim${claims.length == 1 ? '' : 's'}'
          '${filter.isNotEmpty ? ' matching "$filter"' : ''}',
          style: theme.textTheme.labelMedium?.copyWith(color: sd.accentGold),
        ),
        const SizedBox(height: AppSpacing.md),
        TopicReadingRecommendations(topicId: topic!.id),
        const SizedBox(height: AppSpacing.md),
        if (claims.isEmpty)
          SdCard(
            child: Text(
              'No claims match your filter in this topic.',
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          ...claims.asMap().entries.map(
                (e) => SdFadeIn(
                  delayIndex: e.key,
                  child: ClaimCard(
                    claim: e.value,
                    variant: ClaimCardVariant.featured,
                    showTags: true,
                    onTap: () => onClaimTap(e.value.id),
                  ),
                ),
              ),
      ],
    );
  }
}

/// Compact mobile prompt after selecting a topic.
class TopicClaimsPreviewBanner extends StatelessWidget {
  const TopicClaimsPreviewBanner({
    super.key,
    required this.topic,
    required this.claimCount,
    required this.onViewClaims,
  });

  final Topic topic;
  final int claimCount;
  final VoidCallback onViewClaims;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sd.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$claimCount claims in ${topic.title}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SdButton(
              label: 'View',
              variant: SdButtonVariant.secondary,
              onPressed: onViewClaims,
            ),
          ],
        ),
      ),
    );
  }
}