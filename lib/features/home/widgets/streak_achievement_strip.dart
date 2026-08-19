import 'package:flutter/material.dart';

import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../models/user_progress.dart';

/// Horizontal streak counter + unlocked achievement badges.
class StreakAchievementStrip extends StatelessWidget {
  const StreakAchievementStrip({
    super.key,
    required this.progress,
  });

  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final unlocked = progress.achievements
        .map(Achievements.byId)
        .whereType<AchievementDef>()
        .toList();

    final compact = ResponsiveLayout.isCompact(context);
    final nextHint = compact ? null : _nextBadgeHint(progress);

    final badges = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final a in unlocked)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Tooltip(
                message: a.description,
                child: Chip(
                  avatar: Icon(_iconFor(a.icon), size: 16, color: sd.accentGold),
                  label: Text(a.label, style: theme.textTheme.labelSmall),
                  backgroundColor: sd.accentGold.withValues(alpha: 0.1),
                  side: BorderSide(color: sd.accentGold.withValues(alpha: 0.3)),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          if (unlocked.isEmpty)
            Text(
              'Earn badges by crushing arguments',
              style: theme.textTheme.labelSmall,
            ),
        ],
      ),
    );

    return Semantics(
      label:
          'Streak ${progress.streakDays} days, ${progress.totalCrushes} arguments crushed, '
          '${unlocked.length} badges unlocked',
      child: SdCard(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: sd.accentGold,
                label: 'Streak',
                value:
                    '${progress.streakDays} day${progress.streakDays == 1 ? '' : 's'}',
              ),
              Container(
                width: 1,
                height: 44,
                color: sd.borderSubtle,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              _StatTile(
                icon: Icons.bolt_rounded,
                iconColor: sd.accentGold,
                label: 'Crushed',
                value: '${progress.totalCrushes}',
              ),
            ],
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          if (!compact || unlocked.isNotEmpty) badges,
          if (nextHint != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              nextHint,
              style: theme.textTheme.labelSmall?.copyWith(
                color: sd.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  String? _nextBadgeHint(UserProgress progress) {
    if (!progress.achievements.contains(Achievements.firstCrush.id)) {
      return 'Next: crush an argument in the Crusher';
    }
    if (!progress.achievements.contains(Achievements.explorer.id)) {
      return 'Next: explore the topic tree';
    }
    if (progress.streakDays < 3) {
      return 'Next: ${3 - progress.streakDays} day(s) to 3-Day Streak';
    }
    if (!progress.achievements.contains(Achievements.bibliophile.id)) {
      return 'Next: open the public-domain library';
    }
    if (!progress.achievements.contains(Achievements.scholar.id)) {
      return 'Next: read 25% of a classic';
    }
    if (progress.streakDays < 7) {
      return 'Next: ${7 - progress.streakDays} day(s) to Week Warrior';
    }
    return null;
  }

  IconData _iconFor(String name) => switch (name) {
        'flag' => Icons.flag_rounded,
        'local_fire_department' => Icons.local_fire_department_rounded,
        'military_tech' => Icons.military_tech_rounded,
        'bolt' => Icons.bolt_rounded,
        'account_tree' => Icons.account_tree_rounded,
        'menu_book' => Icons.menu_book_rounded,
        'auto_stories' => Icons.auto_stories_rounded,
        _ => Icons.emoji_events_outlined,
      };
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ],
    );
  }
}