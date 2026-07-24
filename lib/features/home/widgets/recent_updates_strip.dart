import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/sync/providers/knowledge_sync_providers.dart';
import '../../../features/sync/widgets/changelog_sheet.dart';
import '../../../themes/themes.dart';

/// Surfaces the latest knowledge-base release so the app feels routinely updated.
class RecentUpdatesStrip extends ConsumerWidget {
  const RecentUpdatesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changelogAsync = ref.watch(changelogProvider);
    final syncAsync = ref.watch(knowledgeSyncStateProvider);

    return changelogAsync.when(
      data: (doc) {
        final latest = doc.entries.isNotEmpty ? doc.entries.first : null;
        if (latest == null) return const SizedBox.shrink();

        final kbVersion = syncAsync.maybeWhen(
          data: (s) => s.effectiveKbVersion,
          orElse: () => doc.currentVersion,
        );

        final headline = latest.changes.isNotEmpty
            ? latest.changes.first
            : latest.title;

        return SdFadeIn(
          child: SdCard(
            onTap: () => ChangelogSheet.show(context),
            semanticLabel: 'Open intelligence changelog',
            child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.sd.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.sd.accentGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'v$kbVersion',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: context.sd.accentGold,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest intelligence',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            headline,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${latest.title} · ${latest.date}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: context.sd.accentGold,
                    ),
                  ],
                ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}