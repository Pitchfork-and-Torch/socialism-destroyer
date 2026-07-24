import 'package:flutter/material.dart';

import '../../../themes/themes.dart';

/// Large tap targets for Tree and Library on tablet/desktop layouts.
class HubNavCards extends StatelessWidget {
  const HubNavCards({
    super.key,
    required this.onTree,
    required this.onLibrary,
    required this.onStudyTools,
    this.onDebate,
  });

  final VoidCallback onTree;
  final VoidCallback onLibrary;
  final VoidCallback onStudyTools;
  final VoidCallback? onDebate;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useGrid = width >= 600;
    final compact = width < 600;

    final tree = _HubCard(
      icon: Icons.account_tree_rounded,
      title: 'Topic Tree',
      subtitle: compact
          ? '100+ sourced claims'
          : '10 categories · 100+ sourced claims',
      onTap: onTree,
      compact: compact,
    );
    final library = _HubCard(
      icon: Icons.menu_book_rounded,
      title: 'Public Library',
      subtitle: compact
          ? '111 PD full texts'
          : '111 full texts · Bastiat, Spencer, Spooner, Founders…',
      onTap: onLibrary,
      compact: compact,
    );
    final debate = _HubCard(
      icon: Icons.forum_rounded,
      title: 'Debate Simulator',
      subtitle: compact
          ? 'Multi-turn spar & score'
          : 'Spar multi-turn · Challenge mode · live evidence',
      onTap: onDebate ?? onStudyTools,
      compact: compact,
    );
    final study = _HubCard(
      icon: Icons.travel_explore_rounded,
      title: 'Free Study Tools',
      subtitle: compact
          ? 'Scholar, Archive & more'
          : 'Scholar, Archive.org, Gutenberg & more',
      onTap: onStudyTools,
      compact: compact,
    );

    if (!useGrid) {
      return Column(
        children: [
          tree,
          const SizedBox(height: AppSpacing.xs),
          library,
          const SizedBox(height: AppSpacing.xs),
          debate,
          const SizedBox(height: AppSpacing.xs),
          study,
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tree),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: library),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: debate),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: study),
          ],
        ),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    final iconSize = compact ? 22.0 : 28.0;
    final iconPad = compact ? AppSpacing.xs : AppSpacing.sm;

    return SdCard(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 2 : 0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPad),
              decoration: BoxDecoration(
                color: sd.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(compact ? 10 : 12),
              ),
              child: Icon(icon, color: sd.accentGold, size: iconSize),
            ),
            SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: compact
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.titleMedium,
                  ),
                  if (!compact) const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: compact ? 12 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: sd.accentGold,
              size: compact ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }
}