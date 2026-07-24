import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/changelog.dart';
import '../../../themes/themes.dart';
import '../providers/knowledge_sync_providers.dart';

/// Bottom sheet listing versioned knowledge-base changelog entries.
class ChangelogSheet extends ConsumerWidget {
  const ChangelogSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.navyDark,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const ChangelogSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelogAsync = ref.watch(changelogProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return changelogAsync.when(
          data: (doc) => _ChangelogBody(
            document: doc,
            scrollController: scrollController,
          ),
          loading: () => const ColoredBox(
            color: AppColors.navyDark,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Could not load changelog: $e'),
          ),
        );
      },
    );
  }
}

class _ChangelogBody extends StatelessWidget {
  const _ChangelogBody({
    required this.document,
    required this.scrollController,
  });

  final ChangelogDocument document;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Intelligence Changelog',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'v${document.currentVersion} · Updated ${document.lastUpdated}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sd.textLow,
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: document.entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final entry = document.entries[index];
              return _ChangelogEntryCard(entry: entry);
            },
          ),
        ),
      ],
    );
  }
}

class _ChangelogEntryCard extends StatelessWidget {
  const _ChangelogEntryCard({required this.entry});

  final ChangelogEntry entry;

  @override
  Widget build(BuildContext context) {
    return SdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: context.sd.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'v${entry.version}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: context.sd.accentGold,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          if (entry.date.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              entry.date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sd.textLow,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ...entry.changes.map(
            (change) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: context.sd.accentGold.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      change,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}