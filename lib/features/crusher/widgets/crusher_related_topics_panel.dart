import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/crusher_result.dart';
import '../../../themes/themes.dart';
import '../../shared/router/app_router.dart';

class CrusherRelatedTopicsPanel extends StatelessWidget {
  const CrusherRelatedTopicsPanel({super.key, required this.topics});

  final List<RelatedTopicRef> topics;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    final sd = context.sd;

    return SdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SdSectionHeader(
            title: 'Related Topics',
            icon: Icons.account_tree_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: topics.map((t) {
              return ActionChip(
                avatar: Icon(Icons.topic, size: 16, color: sd.accentGold),
                label: Text(t.title),
                onPressed: () => context.push(
                  '${AppRoutes.tree}?category=${t.id}',
                ),
                tooltip: t.description,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}