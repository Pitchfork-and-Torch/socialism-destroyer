import 'package:flutter/material.dart';

import '../../../models/crusher_result.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';

/// Compact branded card for PNG export — fits one shareable viewport.
class CrusherShareCard extends StatelessWidget {
  const CrusherShareCard({super.key, required this.result});

  final CrusherResult result;

  @override
  Widget build(BuildContext context) {
    const navy = AppColors.navy;
    const gold = AppColors.gold;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: gold, size: 22),
              const SizedBox(width: AppSpacing.xs),
              const Text(
                'Socialism Destroyer',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                result.modeLabel,
                style: TextStyle(
                  color: gold.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: gold, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COUNTER-ARGUMENT',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (result.primaryClaimTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    result.primaryClaimTitle!,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  result.executiveSummary,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'THEIR CLAIM',
            style: TextStyle(
              color: AppColors.danger.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.inputText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (result.evidenceBullets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'WHY THIS HOLDS UP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...result.evidenceBullets.take(3).map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: gold, fontSize: 11)),
                        Expanded(
                          child: Text(
                            b,
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          if (result.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'SOURCES (${result.sources.length})',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...result.sources.take(3).map(
                  (s) => Text(
                    '• ${s.title}',
                    style: const TextStyle(color: Colors.white54, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          ],
          if (result.fallacies.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: result.fallacies.take(4).map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: AppColors.danger.withValues(alpha: 0.9),
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ).toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'destroyer.jonbailey.xyz · ${(result.analysis.matchConfidence * 100).round()}% match',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 8),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}