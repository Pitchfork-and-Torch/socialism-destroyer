import 'package:flutter/material.dart';

import '../../../models/debate_session.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_spacing.dart';

/// Branded multi-turn debate summary card for PNG export / social share.
class DebateShareCard extends StatelessWidget {
  const DebateShareCard({super.key, required this.session});

  final DebateSession session;

  @override
  Widget build(BuildContext context) {
    const navy = AppColors.navy;
    const gold = AppColors.gold;
    final avg = session.averageUserScore;
    final engine = session.latestEngineTurn;
    final summary = engine?.crusherResult?.executiveSummary ??
        engine?.text ??
        'Multi-turn liberty debate practice.';
    final opponent = session.turns
        .where((t) => t.role == DebateRole.user)
        .map((t) => t.text)
        .toList();
    final lastUser = opponent.isNotEmpty ? opponent.last : session.seedArgument;

    return Container(
      width: 420,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_rounded, color: gold, size: 22),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'Debate Simulator',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                session.mode.name.toUpperCase(),
                style: TextStyle(
                  color: gold.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          if (lastUser != null && lastUser.trim().isNotEmpty) ...[
            Text(
              'OPPONENT / YOUR MOVE',
              style: TextStyle(
                color: AppColors.danger.withValues(alpha: 0.95),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lastUser,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: gold, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ENGINE COUNTER',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                  ),
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _stat('Turns', '${session.turnCount}'),
              const SizedBox(width: AppSpacing.sm),
              _stat(
                'Sources',
                '${session.allSources.length}',
              ),
              if (avg != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _stat('Avg score', '${avg.round()}'),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'destroyer.jonbailey.xyz · Fully sourced · Offline-first',
            style: TextStyle(
              color: gold.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
