import 'package:flutter/material.dart';

import '../../../models/topic.dart';
import '../../../themes/themes.dart';

/// Horizontally scrollable category filter chips for top-level topics.
class TopicCategoryChips extends StatelessWidget {
  const TopicCategoryChips({
    super.key,
    required this.topics,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Topic> topics;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;

    return Semantics(
      container: true,
      label: 'Topic category filters',
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Semantics(
                button: true,
                selected: selectedId == null,
                label: 'Show all topic categories',
                child: FilterChip(
                  label: const Text('All'),
                  selected: selectedId == null,
                  onSelected: (_) => onSelected(null),
                  selectedColor: sd.accentGold.withValues(alpha: 0.2),
                  checkmarkColor: sd.accentGold,
                ),
              ),
            ),
            ...topics.map(
              (t) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Semantics(
                  button: true,
                  selected: selectedId == t.id,
                  label: 'Filter by ${t.title}',
                  child: FilterChip(
                    label: Text(t.title, overflow: TextOverflow.ellipsis),
                    selected: selectedId == t.id,
                    onSelected: (_) => onSelected(t.id),
                    selectedColor: sd.accentGold.withValues(alpha: 0.2),
                    checkmarkColor: sd.accentGold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}