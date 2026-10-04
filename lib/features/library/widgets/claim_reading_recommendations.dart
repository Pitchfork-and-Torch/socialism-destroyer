import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/book.dart';
import '../../../themes/themes.dart';
import '../providers/library_providers.dart';
import '../utils/library_book_actions.dart';

/// Curated library picks linked directly from a claim detail screen.
class ClaimReadingRecommendations extends ConsumerWidget {
  const ClaimReadingRecommendations({
    super.key,
    required this.claimId,
  });

  final String claimId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(claimReadingLinksProvider(claimId));
    final booksAsync = ref.watch(booksProvider);
    final sd = context.sd;

    return linksAsync.when(
      data: (links) {
        if (links.isEmpty) return const SizedBox.shrink();
        return booksAsync.when(
          data: (books) {
            final byId = {for (final b in books) b.id: b};
            final resolved = links
                .map((l) => (link: l, book: byId[l.bookId]))
                .where((e) => e.book != null)
                .toList();
            if (resolved.isEmpty) return const SizedBox.shrink();

            return SdCard(
              accentColor: sd.accentGold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SdSectionHeader(
                    title: 'Read Next',
                    icon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bundled classics and essential external reading for this debate',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: sd.textLow,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...resolved.map((entry) {
                    final book = entry.book!;
                    final link = entry.link;
                    final chapter = _chapterTitle(book, link.chapterId);
                    final progress =
                        ref.watch(bookReadingStateProvider(book.id)).progress;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: sd.surfaceRaised,
                        borderRadius: AppRadius.card,
                        child: InkWell(
                          borderRadius: AppRadius.card,
                          onTap: () => openLibraryBook(
                            context,
                            book: book,
                            chapterId: link.chapterId,
                            claimId: claimId,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        sd.surfaceBase,
                                        sd.accentGold.withValues(alpha: 0.2),
                                      ],
                                    ),
                                    borderRadius: AppRadius.card,
                                    border: Border.all(
                                      color: sd.accentGold.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Icon(
                                    book.isExternal
                                        ? Icons.open_in_new_rounded
                                        : Icons.auto_stories,
                                    color: sd.accentGold,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style:
                                            Theme.of(context).textTheme.titleSmall,
                                      ),
                                      Text(
                                        book.author,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: sd.textLow),
                                      ),
                                      if (book.isExternal) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Open Library — borrow or buy',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: sd.accentGold),
                                        ),
                                      ] else if (chapter != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Jump to: $chapter',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: sd.accentGold),
                                        ),
                                      ],
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        link.reason,
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                      if (progress != null &&
                                          progress.percentComplete > 0) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: progress.scrollFraction
                                                .clamp(0, 1),
                                            minHeight: 3,
                                            backgroundColor: sd.borderSubtle,
                                            color: sd.accentGold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: sd.textLow),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String? _chapterTitle(Book book, String? chapterId) {
    if (chapterId == null) return null;
    for (final ch in book.chapters) {
      if (ch.id == chapterId) return ch.title;
    }
    return null;
  }
}