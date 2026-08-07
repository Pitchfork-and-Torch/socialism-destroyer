import 'package:flutter/material.dart';

import '../../../models/crusher_result.dart';
import '../../../themes/themes.dart';

class CrusherInputAnalysisCard extends StatelessWidget {
  const CrusherInputAnalysisCard({
    super.key,
    required this.analysis,
    required this.modeLabel,
  });

  final InputAnalysis analysis;
  final String modeLabel;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return SdCard(
      accentColor: sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 18, color: sd.accentGold),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Input analysis',
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sd.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    modeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: sd.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (analysis.intentLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.psychology_outlined, size: 16, color: sd.textMedium),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Text(
                    'Intent: ${analysis.intentLabel}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: sd.textHigh,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Match confidence: ${(analysis.matchConfidence * 100).round()}%',
            style: theme.textTheme.labelMedium?.copyWith(color: sd.textMedium),
          ),
          if (analysis.detectedTopicIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Topics: ${analysis.detectedTopicIds.join(', ')}',
              style: theme.textTheme.labelSmall?.copyWith(color: sd.textLow),
            ),
          ],
          if (analysis.keyPhrases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: analysis.keyPhrases
                  .map(
                    (p) => Chip(
                      label: Text(p, style: theme.textTheme.labelSmall),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: sd.surfaceRaised,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (analysis.suspectedFallacies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Detected fallacy signals',
              style: theme.textTheme.labelSmall?.copyWith(color: sd.textLow),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Wrap(
              spacing: AppSpacing.xs,
              children: analysis.suspectedFallacies
                  .map(
                    (f) => Chip(
                      avatar: Icon(Icons.warning_amber_rounded,
                          size: 14, color: sd.accentRed),
                      label: Text(f, style: theme.textTheme.labelSmall),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}