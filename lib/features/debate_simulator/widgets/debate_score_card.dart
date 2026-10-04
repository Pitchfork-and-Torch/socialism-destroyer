import 'package:flutter/material.dart';

import '../../../models/debate_session.dart';
import '../../../themes/themes.dart';

class DebateScoreCard extends StatelessWidget {
  const DebateScoreCard({super.key, required this.feedback});

  final TurnFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final score = feedback.overallScore;
    final color = score >= 70
        ? sd.accentGold
        : (score >= 45 ? theme.colorScheme.tertiary : sd.accentRed);

    return SdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                ),
                child: Text(
                  '$score',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.gradeLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                      ),
                    ),
                    if (feedback.summary != null)
                      Text(
                        feedback.summary!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: sd.textMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricBar(
            label: 'Evidence',
            value: feedback.evidenceScore,
            color: sd.accentGold,
          ),
          _MetricBar(
            label: 'Specificity',
            value: feedback.specificityScore,
            color: sd.accentGold.withValues(alpha: 0.75),
          ),
          _MetricBar(
            label: 'Fallacy discipline',
            value: feedback.fallacyAwarenessScore,
            color: sd.accentGold.withValues(alpha: 0.55),
          ),
          if (feedback.strengths.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Strengths', style: theme.textTheme.labelLarge),
            ...feedback.strengths.map(
              (s) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: sd.accentGold),
                    const SizedBox(width: 6),
                    Expanded(child: Text(s, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ),
          ],
          if (feedback.improvements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Improve next', style: theme.textTheme.labelLarge),
            ...feedback.improvements.map(
              (s) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: sd.textMedium),
                    const SizedBox(width: 6),
                    Expanded(child: Text(s, style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.labelSmall)),
              Text('$value', style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: context.sd.borderSubtle,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
