import 'package:flutter/material.dart';

import '../../../models/topic.dart';
import '../../../themes/themes.dart';
import '../services/topic_tree_index.dart';

/// Recursively renders a topic and its subtopics as [TreeNode] widgets.
class TopicTreeBranch extends StatelessWidget {
  const TopicTreeBranch({
    super.key,
    required this.topic,
    required this.index,
    required this.filter,
    required this.expandedIds,
    required this.selectedTopicId,
    required this.onToggle,
    required this.onSelect,
    required this.onClaimTap,
    this.depth = 0,
    this.animationIndex = 0,
  });

  final Topic topic;
  final TopicTreeIndex index;
  final String filter;
  final Set<String> expandedIds;
  final String? selectedTopicId;
  final void Function(String topicId) onToggle;
  final void Function(String topicId) onSelect;
  final void Function(String claimId) onClaimTap;
  final int depth;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    if (!index.matchesFilter(topic, filter)) {
      return const SizedBox.shrink();
    }

    final expanded = expandedIds.contains(topic.id);
    final claims = index.claimsFor(topic);

    return Column(
      children: [
        SdFadeIn(
          delayIndex: animationIndex,
          child: TreeNode(
            topic: topic,
            claims: claims,
            filter: filter,
            depth: depth,
            expanded: expanded,
            isSelected: selectedTopicId == topic.id,
            onToggle: () => onToggle(topic.id),
            onSelect: () => onSelect(topic.id),
            onClaimTap: onClaimTap,
          ),
        ),
        if (expanded)
          ...topic.children.asMap().entries.map(
                (e) => TopicTreeBranch(
                  topic: e.value,
                  index: index,
                  filter: filter,
                  expandedIds: expandedIds,
                  selectedTopicId: selectedTopicId,
                  onToggle: onToggle,
                  onSelect: onSelect,
                  onClaimTap: onClaimTap,
                  depth: depth + 1,
                  animationIndex: animationIndex + e.key + 1,
                ),
              ),
      ],
    );
  }
}