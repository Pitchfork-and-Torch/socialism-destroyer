import 'package:flutter/material.dart';

import '../../../themes/themes.dart';
import '../providers/home_providers.dart';

/// Horizontally scrollable quick-launch chips for top topic categories.
class QuickCategoryChips extends StatelessWidget {
  const QuickCategoryChips({
    super.key,
    required this.onCategoryTap,
  });

  final void Function(QuickCategory category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: homeQuickCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final cat = homeQuickCategories[i];
          return ActionChip(
            avatar: Icon(_iconFor(cat.icon), size: 18, color: sd.accentGold),
            label: Text(cat.title),
            onPressed: () => onCategoryTap(cat),
            backgroundColor: sd.surfaceRaised,
            side: BorderSide(color: sd.borderSubtle),
            labelStyle: Theme.of(context).textTheme.labelLarge,
          );
        },
      ),
    );
  }

  IconData _iconFor(String name) => switch (name) {
        'trending_up' => Icons.trending_up_rounded,
        'history_edu' => Icons.history_edu_rounded,
        'public' => Icons.public_rounded,
        'insights' => Icons.insights_rounded,
        'flag' => Icons.flag_rounded,
        _ => Icons.folder_outlined,
      };
}