import 'package:flutter/material.dart';

import '../../../models/claim.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';

/// Tweet-ready Battle Brief card. Logical 480x252 at 2.5x is 1200x630.
class BattleBriefShareCard extends StatelessWidget {
  const BattleBriefShareCard({super.key, required this.claim});

  final Claim claim;

  static const double logicalWidth = 480;
  static const double logicalHeight = 252;
  static const double capturePixelRatio = 2.5;

  @override
  Widget build(BuildContext context) {
    const navy = AppColors.navy;
    const gold = AppColors.gold;

    return SizedBox(
      width: logicalWidth,
      height: logicalHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: gold.withValues(alpha: 0.55), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_moon_outlined, color: gold, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  const Text(
                    'BATTLE BRIEF',
                    style: TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Socialism Destroyer',
                    style: TextStyle(
                      color: gold.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                claim.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'STEELMAN',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                claim.socialistClaimText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'REBUTTAL',
                style: TextStyle(
                  color: gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  claim.executiveSummary,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    height: 1.28,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${claim.sources.length} sources',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'destroyer.jonbailey.xyz/claim/${claim.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: gold.withValues(alpha: 0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
