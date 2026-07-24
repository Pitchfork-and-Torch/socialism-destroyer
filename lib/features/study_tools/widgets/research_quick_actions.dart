import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../themes/themes.dart';
import '../../../utils/research_links.dart';
import '../../shared/router/app_router.dart';

/// One-tap links to free research tools when verifying a debate claim.
class ResearchQuickActions extends StatelessWidget {
  const ResearchQuickActions({
    super.key,
    required this.query,
    this.compact = false,
  });

  final String query;
  final bool compact;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final q = query.trim().isEmpty ? 'economic freedom' : query.trim();

    final actions = [
      _Action(
        icon: Icons.school_outlined,
        label: 'Google Scholar',
        onTap: () => _open(ResearchLinks.googleScholar(q)),
      ),
      _Action(
        icon: Icons.history_edu_outlined,
        label: 'Wayback',
        tooltip: 'Search Internet Archive',
        onTap: () => _open(
          'https://web.archive.org/web/*/${Uri.encodeComponent('https://en.wikipedia.org/wiki/Special:Search?search=$q')}',
        ),
      ),
      _Action(
        icon: Icons.menu_book_outlined,
        label: 'Gutenberg',
        onTap: () => _open(ResearchLinks.projectGutenbergSearch(q)),
      ),
      _Action(
        icon: Icons.biotech_outlined,
        label: 'Semantic Scholar',
        onTap: () => _open(ResearchLinks.semanticScholar(q)),
      ),
      _Action(
        icon: Icons.grid_view_rounded,
        label: 'All tools',
        onTap: () => context.push(AppRoutes.studyTools),
      ),
    ];

    if (compact) {
      return Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: actions
            .map(
              (a) => ActionChip(
                avatar: Icon(a.icon, size: 16, color: sd.accentGold),
                label: Text(a.label),
                onPressed: a.onTap,
              ),
            )
            .toList(),
      );
    }

    return SdCard(
      accentColor: sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SdSectionHeader(
            title: 'Verify & Research',
            icon: Icons.travel_explore_rounded,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Free tools to fact-check sources and dig deeper',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: sd.textMedium,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actions
                .map(
                  (a) => OutlinedButton.icon(
                    onPressed: a.onTap,
                    icon: Icon(a.icon, size: 18),
                    label: Text(a.label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Action {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? tooltip;
}