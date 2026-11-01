import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/book.dart';
import '../../../models/book_reading.dart';
import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/debouncer.dart';
import '../../home/providers/home_providers.dart';
import '../../shared/router/app_router.dart';
import '../../shared/services/share_actions.dart';
import '../providers/library_providers.dart';
import '../utils/library_book_actions.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _ContinueReadingHero extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cont = ref.watch(continueReadingProvider);
    if (cont == null) return const SizedBox.shrink();
    final sd = context.sd;

    return SdCard(
      accentColor: sd.accentGold,
      onTap: () => context.push(AppRoutes.libraryReaderPath(cont.book.id)),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, color: sd.accentGold, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue reading',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: sd.accentGold,
                      ),
                ),
                Text(
                  cont.book.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: cont.progress.scrollFraction.clamp(0, 1),
                    minHeight: 4,
                    backgroundColor: sd.borderSubtle,
                    color: sd.accentGold,
                  ),
                ),
                Text(
                  '${cont.progress.percentComplete}% complete',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: sd.textLow,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _debouncedFilter = '';
  final _debouncer = Debouncer();
  final _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProgressProvider.notifier).recordLibraryVisit();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final progressMap = ref.watch(allBookProgressProvider);
    final offlineIds = ref.watch(offlineBookIdsProvider).valueOrNull ?? {};
    final sd = context.sd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          Icon(Icons.offline_bolt, color: sd.accentGold, size: 20),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          final filtered = _debouncedFilter.isEmpty
              ? books
              : books.where((b) {
                  final q = _debouncedFilter.toLowerCase();
                  return b.title.toLowerCase().contains(q) ||
                      b.author.toLowerCase().contains(q) ||
                      b.description.toLowerCase().contains(q);
                }).toList();

          return ResponsiveContent(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context).copyWith(
                      bottom: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Know the canon — read the opposition',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Public-domain texts bundled offline, plus essential copyrighted works linked via Open Library.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: sd.textMedium,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => context.push(AppRoutes.studyTools),
                            icon: const Icon(Icons.travel_explore_outlined, size: 18),
                            label: const Text('Free study tools — Scholar, Archive.org, Gutenberg'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ContinueReadingHero(),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _filterController,
                          decoration: InputDecoration(
                            hintText: 'Filter library…',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.card,
                            ),
                            isDense: true,
                          ),
                          onChanged: (v) => _debouncer.run(() {
                            if (mounted) {
                              setState(() => _debouncedFilter = v);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                ..._librarySections(
                  context: context,
                  ref: ref,
                  books: filtered,
                  progressMap: progressMap,
                  offlineIds: offlineIds,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

List<Widget> _librarySections({
  required BuildContext context,
  required WidgetRef ref,
  required List<Book> books,
  required Map<String, BookReadingProgress> progressMap,
  required Set<String> offlineIds,
}) {
  final bundled =
      books.where((b) => b.isReadableInApp).toList(growable: false);
  final external = books.where((b) => b.isExternal).toList(growable: false);
  final sd = context.sd;
  final crossCount = ResponsiveLayout.gridCrossAxisCount(context);

  Widget sectionHeader(String title, String subtitle) => Padding(
        padding: ResponsiveLayout.pagePadding(context).copyWith(
          top: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: sd.textLow,
                  ),
            ),
          ],
        ),
      );

  Widget bookSliver(List<Book> sectionBooks, {required bool compact}) {
    if (sectionBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (crossCount == 1) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final book = sectionBooks[i];
            return SdFadeIn(
              delayIndex: i,
              child: _BookCard(
                book: book,
                progress: progressMap[book.id],
                downloaded: offlineIds.contains(book.id),
                onTap: () => openLibraryBook(context, book: book),
                onDownload: book.isReadableInApp
                    ? () => ref
                        .read(bookReadingActionsProvider)
                        .downloadForOffline(book)
                    : null,
              ),
            );
          },
          childCount: sectionBooks.length,
        ),
      );
    }
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisExtent: 220,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final book = sectionBooks[i];
          return SdFadeIn(
            delayIndex: i,
            child: _BookCard(
              book: book,
              compact: true,
              progress: progressMap[book.id],
              downloaded: offlineIds.contains(book.id),
              onTap: () => openLibraryBook(context, book: book),
              onDownload: book.isReadableInApp
                  ? () => ref
                      .read(bookReadingActionsProvider)
                      .downloadForOffline(book)
                  : null,
            ),
          );
        },
        childCount: sectionBooks.length,
      ),
    );
  }

  return [
    SliverToBoxAdapter(
      child: sectionHeader(
        'Bundled classics (public domain)',
        '${bundled.length} full texts — offline highlights, notes, and progress',
      ),
    ),
    bookSliver(bundled, compact: crossCount > 1),
    if (external.isNotEmpty) ...[
      SliverToBoxAdapter(
        child: sectionHeader(
          'Essential reading (copyrighted)',
          '${external.length} works — Open Library links to borrow or buy',
        ),
      ),
      bookSliver(external, compact: crossCount > 1),
    ],
  ];
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.onTap,
    this.compact = false,
    this.progress,
    this.downloaded = false,
    this.onDownload,
  });

  final Book book;
  final VoidCallback onTap;
  final bool compact;
  final BookReadingProgress? progress;
  final bool downloaded;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final hasFullText = book.fullTextPath != null && book.fullTextPath!.isNotEmpty;
    final pct = progress?.percentComplete ?? 0;

    return SdCard(
      onTap: onTap,
      accentColor: sd.accentGold,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  sd.surfaceBase,
                  sd.accentGold.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: AppRadius.card,
              border: Border.all(color: sd.accentGold.withValues(alpha: 0.45)),
            ),
            child: Icon(Icons.menu_book_rounded, color: sd.accentGold, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (book.isExternal)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sd.surfaceRaised,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: sd.borderSubtle),
                        ),
                        child: Text(
                          'EXT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: sd.textMedium,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      )
                    else if (book.pdStatus == PdStatus.publicDomain)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sd.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PD',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: sd.accentGold,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                  ],
                ),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: sd.textLow,
                      ),
                ),
                if (!compact) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    book.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      book.isExternal
                          ? Icons.open_in_new_rounded
                          : hasFullText
                              ? Icons.check_circle_outline
                              : Icons.short_text,
                      size: 14,
                      color: book.isExternal
                          ? sd.textMedium
                          : hasFullText
                              ? sd.accentGold
                              : sd.textLow,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        book.isExternal
                            ? 'Open Library link'
                            : downloaded
                                ? 'Downloaded · ${book.chapters.length} ch.'
                                : hasFullText
                                    ? 'Full text · ${book.chapters.length} ch.'
                                    : 'Excerpt',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: downloaded ? sd.accentGold : sd.textLow,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!downloaded && onDownload != null && !compact)
                      IconButton(
                        icon: const Icon(Icons.download_outlined, size: 18),
                        tooltip: 'Download for offline',
                        visualDensity: VisualDensity.compact,
                        onPressed: onDownload,
                      ),
                    if (pct > 0)
                      Text(
                        '$pct%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: sd.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    if (!compact)
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        tooltip: 'Share book',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => ShareActions.shareBook(book),
                      ),
                  ],
                ),
                if (pct > 0) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (progress?.scrollFraction ?? 0).clamp(0, 1),
                      minHeight: 3,
                      backgroundColor: sd.borderSubtle,
                      color: sd.accentGold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}