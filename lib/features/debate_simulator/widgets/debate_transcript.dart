import 'package:flutter/material.dart';

import '../../../models/debate_session.dart';
import '../../../themes/themes.dart';
import 'debate_score_card.dart';

class DebateTranscript extends StatelessWidget {
  const DebateTranscript({
    super.key,
    required this.session,
    this.scrollController,
  });

  final DebateSession session;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: session.turns.length,
      itemBuilder: (context, index) {
        final turn = session.turns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _TurnBubble(turn: turn, index: index),
        );
      },
    );
  }
}

class _TurnBubble extends StatelessWidget {
  const _TurnBubble({required this.turn, required this.index});

  final DebateTurn turn;
  final int index;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    final isUser = turn.role == DebateRole.user;
    final isSystem = turn.role == DebateRole.system;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isSystem
        ? sd.surfaceOverlay.withValues(alpha: 0.6)
        : (isUser
            ? sd.accentRed.withValues(alpha: 0.12)
            : sd.accentGold.withValues(alpha: 0.10));
    final border = isSystem
        ? sd.borderSubtle
        : (isUser ? sd.accentRed.withValues(alpha: 0.45) : sd.accentGold);
    final who = switch (turn.role) {
      DebateRole.user => 'You',
      DebateRole.engine => 'Engine',
      DebateRole.system => 'System',
    };

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. $who',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isUser ? sd.accentRed : sd.accentGold,
              ),
            ),
            if (turn.label != null) ...[
              Text(' · ', style: theme.textTheme.labelSmall),
              Text(
                turn.label!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: sd.textLow,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border, width: 1),
          ),
          child: SelectableText(
            turn.text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        if (turn.feedback != null) ...[
          const SizedBox(height: AppSpacing.sm),
          DebateScoreCard(feedback: turn.feedback!),
        ],
      ],
    );
  }
}
