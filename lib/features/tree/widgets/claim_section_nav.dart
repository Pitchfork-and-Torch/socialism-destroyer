import 'package:flutter/material.dart';

import '../../../themes/themes.dart';

/// Section jump list for split-view claim detail on tablet/desktop.
class ClaimSectionNav extends StatelessWidget {
  const ClaimSectionNav({
    super.key,
    required this.sections,
    required this.activeId,
    required this.onSectionTap,
    this.relatedClaims = const [],
    this.onRelatedTap,
  });

  final List<ClaimSection> sections;
  final String activeId;
  final ValueChanged<String> onSectionTap;
  final List<({String id, String title})> relatedClaims;
  final void Function(String claimId)? onRelatedTap;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return Material(
      color: sd.surfaceBase,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        children: [
          Text(
            'On this page',
            style: theme.textTheme.labelLarge?.copyWith(color: sd.accentGold),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sections.map((s) {
            final selected = s.id == activeId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Material(
                color: selected
                    ? sd.accentGold.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onSectionTap(s.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(s.icon, size: 18, color: sd.accentGold),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            s.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? sd.accentGold : sd.textHigh,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (relatedClaims.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Related',
              style: theme.textTheme.labelLarge?.copyWith(color: sd.accentGold),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...relatedClaims.map(
              (r) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.link_rounded, size: 18, color: sd.textLow),
                title: Text(
                  r.title,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: onRelatedTap == null ? null : () => onRelatedTap!(r.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ClaimSection {
  const ClaimSection({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const kClaimSections = [
  ClaimSection(
    id: 'claim',
    label: 'Their Argument',
    icon: Icons.warning_amber_rounded,
  ),
  ClaimSection(
    id: 'counter',
    label: 'Counter-Argument',
    icon: Icons.shield_outlined,
  ),
  ClaimSection(
    id: 'evidence',
    label: 'Why It Holds Up',
    icon: Icons.fact_check_outlined,
  ),
  ClaimSection(
    id: 'research',
    label: 'Research Tools',
    icon: Icons.travel_explore_outlined,
  ),
  ClaimSection(
    id: 'fallacies',
    label: 'Fallacies',
    icon: Icons.psychology_alt_outlined,
  ),
  ClaimSection(
    id: 'sources',
    label: 'Sources',
    icon: Icons.library_books_outlined,
  ),
  ClaimSection(
    id: 'america',
    label: 'Why It Matters',
    icon: Icons.flag_outlined,
  ),
  ClaimSection(
    id: 'reading',
    label: 'Library Reading',
    icon: Icons.menu_book_rounded,
  ),
  ClaimSection(
    id: 'related',
    label: 'See Also',
    icon: Icons.link_rounded,
  ),
];