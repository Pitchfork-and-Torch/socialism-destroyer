import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../themes/themes.dart';
import '../providers/library_providers.dart';
import '../utils/library_book_actions.dart';

/// Smart reading picks linked from the topic tree.
class TopicReadingRecommendations extends ConsumerWidget {
  const TopicReadingRecommendations({
    super.key,
    required this.topicId,
    this.compact = false,
  });

  final String topicId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksForTopicProvider(topicId));
    final sd = context.sd;

    return booksAsync.when(
      data: (books) {
        if (books.isEmpty) return const SizedBox.shrink();

        final header = Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 18, color: sd.accentGold),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Recommended reading',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: sd.accentGold,
                  ),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: books.map((book) {
                  final rec = book.recommendations
                      .where((r) => r.topicId == topicId)
                      .firstOrNull;
                  return ActionChip(
                    avatar: Icon(Icons.auto_stories, size: 16, color: sd.accentGold),
                    label: Text(book.title),
                    onPressed: () => openLibraryBook(
                      context,
                      book: book,
                      topicId: topicId,
                    ),
                    tooltip: rec?.reason,
                  );
                }).toList(),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: AppSpacing.sm),
            ...books.map((book) {
              final rec = book.recommendations
                  .where((r) => r.topicId == topicId)
                  .firstOrNull;
              final progress =
                  ref.watch(bookReadingStateProvider(book.id)).progress;
              return SdCard(
                accentColor: sd.accentGold,
                onTap: () => openLibraryBook(
                  context,
                  book: book,
                  topicId: topicId,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 56,
                      decoration: BoxDecoration(
                        color: sd.surfaceBase,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: sd.accentGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(Icons.menu_book, color: sd.accentGold),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            book.author,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: sd.textLow,
                                ),
                          ),
                          if (rec != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              rec.reason,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (progress != null && progress.percentComplete > 0) ...[
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress.scrollFraction.clamp(0, 1),
                                minHeight: 3,
                                backgroundColor: sd.borderSubtle,
                                color: sd.accentGold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 24,
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}