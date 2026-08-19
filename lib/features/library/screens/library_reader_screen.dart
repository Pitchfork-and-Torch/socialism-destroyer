import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/book.dart';
import '../../../models/book_reading.dart';
import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../../../services/book_reading_service.dart';
import '../../home/providers/home_providers.dart';
import '../../shared/router/app_router.dart';
import '../../shared/services/share_actions.dart';
import '../providers/library_providers.dart';
import '../widgets/external_book_panel.dart';
import '../widgets/book_highlights_sheet.dart';
import '../widgets/book_reader_content.dart';
import '../widgets/book_search_bar.dart';
import '../widgets/book_toc_panel.dart';
import '../widgets/reader_settings_sheet.dart';
import '../widgets/reading_progress_strip.dart';

class LibraryReaderScreen extends ConsumerStatefulWidget {
  const LibraryReaderScreen({
    super.key,
    required this.bookId,
    this.fromTopicId,
    this.fromClaimId,
    this.initialChapterId,
  });

  final String bookId;
  final String? fromTopicId;
  final String? fromClaimId;
  final String? initialChapterId;

  @override
  ConsumerState<LibraryReaderScreen> createState() =>
      _LibraryReaderScreenState();
}

class _LibraryReaderScreenState extends ConsumerState<LibraryReaderScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _readerKey = GlobalKey<BookReaderContentState>();
  BookReadingService? _readingService;
  Timer? _progressDebounce;
  bool _showSearch = false;
  String _searchQuery = '';
  int _activeMatchIndex = 0;
  String? _activeChapterId;
  double _scrollFraction = 0;
  double _scrollOffset = 0;
  bool _scholarRecorded = false;
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureOfflineCopy());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _activeMatchIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _progressDebounce?.cancel();
    final service = _readingService;
    if (service != null) {
      unawaited(
        service.saveProgress(
          BookReadingProgress(
            bookId: widget.bookId,
            scrollFraction: _scrollFraction,
            scrollOffset: _scrollOffset,
            chapterId: _activeChapterId,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleProgressSave() {
    _progressDebounce?.cancel();
    _progressDebounce = Timer(const Duration(milliseconds: 600), _persistProgress);
  }

  Future<void> _ensureOfflineCopy() async {
    try {
      final book = await ref.read(bookProvider(widget.bookId).future);
      if (book == null || !mounted) return;
      final offline = ref.read(bookOfflineServiceProvider);
      if (await offline.isDownloaded(book.id)) {
        setState(() => _downloaded = true);
        return;
      }
      await ref.read(bookReadingActionsProvider).downloadForOffline(book);
      if (mounted) setState(() => _downloaded = true);
      ref.invalidate(bookContentProvider(widget.bookId));
    } on MissingPluginException {
      // Desktop/widget tests — bundled assets still load via rootBundle.
    } catch (_) {
      // Offline cache is best-effort; reader works from assets.
    }
  }

  int? _initialCharOffset(Book book) {
    final chapterId = widget.initialChapterId;
    if (chapterId == null) return null;
    return book.chapters
        .where((c) => c.id == chapterId)
        .map((c) => c.startOffset)
        .firstOrNull;
  }

  Future<void> _persistProgress() async {
    if (!mounted) return;
    final progress = BookReadingProgress(
      bookId: widget.bookId,
      scrollFraction: _scrollFraction,
      scrollOffset: _scrollOffset,
      chapterId: _activeChapterId,
      updatedAt: DateTime.now(),
    );
    await ref.read(bookReadingActionsProvider).saveProgress(progress);
  }

  Future<void> _onHighlightRequest(int start, int end, String excerpt) async {
    final note = await _promptNote(
      title: 'Add highlight',
      hint: 'Optional note for: "${excerpt.length > 60 ? '${excerpt.substring(0, 60)}…' : excerpt}"',
    );
    await ref.read(bookReadingActionsProvider).addHighlight(
          bookId: widget.bookId,
          start: start,
          end: end,
          note: note,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Highlight saved')),
      );
    }
  }

  Future<String?> _promptNote({required String title, required String hint}) async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result?.isEmpty == true ? null : result;
  }

  void _openHighlightsSheet(List<BookHighlight> highlights) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookHighlightsSheet(
        highlights: highlights,
        onHighlightTap: (h) {
          Navigator.pop(context);
          _readerKey.currentState?.scrollToOffset(h.start);
        },
        onDelete: (h) async {
          await ref
              .read(bookReadingActionsProvider)
              .removeHighlight(widget.bookId, h.id);
        },
        onEditNote: (h) async {
          final note = await _promptNote(
            title: 'Edit note',
            hint: 'Your thoughts on this passage',
          );
          if (note != null) {
            await ref.read(bookReadingActionsProvider).updateHighlightNote(
                  widget.bookId,
                  h,
                  note,
                );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _readingService = ref.read(bookReadingServiceProvider);
    final bookAsync = ref.watch(bookProvider(widget.bookId));
    final contentAsync = ref.watch(bookContentProvider(widget.bookId));
    final readingState = ref.watch(bookReadingStateProvider(widget.bookId));
    final matches = ref.watch(
      bookSearchProvider((bookId: widget.bookId, query: _searchQuery)),
    );
    final useSplit = ResponsiveLayout.useSplitPane(context);
    final readerSettings = ref.watch(readerSettingsProvider);

    return bookAsync.when(
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reader')),
            body: const Center(child: Text('Book not found')),
          );
        }

        final savedProgress = readingState.progress;
        final linkedChapterOffset = _initialCharOffset(book);
        final activeMatch = matches.isNotEmpty && _searchQuery.length >= 2
            ? matches[_activeMatchIndex.clamp(0, matches.length - 1)]
            : null;

        final body = contentAsync.when(
          data: (content) {
            if (content.isEmpty) {
              if (book.isExternal) {
                return ExternalBookPanel(book: book);
              }
              return const Center(child: Text('No text available for this book.'));
            }

            final reader = BookReaderContent(
              key: _readerKey,
              content: content,
              chapters: book.chapters,
              highlights: readingState.highlights,
              scrollController: _scrollController,
              searchQuery: _searchQuery,
              activeSearchMatch: activeMatch,
              initialCharOffset: linkedChapterOffset,
              initialScrollOffset: linkedChapterOffset == null
                  ? (savedProgress?.scrollOffset ?? 0)
                  : 0,
              readerSettings: readerSettings,
              onProgress: (offset, fraction) {
                setState(() {
                  _scrollOffset = offset;
                  _scrollFraction = fraction;
                });
                if (!_scholarRecorded && fraction >= 0.25) {
                  _scholarRecorded = true;
                  ref.read(userProgressProvider.notifier).recordReadingMilestone();
                }
                _scheduleProgressSave();
              },
              onActiveChapter: (id) {
                if (_activeChapterId != id) {
                  setState(() => _activeChapterId = id);
                }
              },
              onHighlightRequest: _onHighlightRequest,
            );

            if (useSplit) {
              return AdaptiveSplitLayout(
                sidebarWidth: 280,
                sidebar: BookTocPanel(
                  chapters: book.chapters,
                  activeChapterId: _activeChapterId,
                  progressFraction: _scrollFraction,
                  onChapterTap: (ch) =>
                      _readerKey.currentState?.scrollToChapter(ch),
                ),
                body: reader,
              );
            }
            return reader;
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Center(child: Text('Error loading book: $e')),
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: widget.fromClaimId != null
                  ? 'Back to claim'
                  : 'Back to library',
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                if (widget.fromClaimId != null) {
                  context.go('/claim/${widget.fromClaimId}');
                  return;
                }
                context.go(AppRoutes.library);
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.author,
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              if (_downloaded)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xxs),
                  child: Icon(
                    Icons.offline_pin,
                    color: context.sd.accentGold,
                    size: 20,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.text_fields),
                tooltip: 'Reader settings',
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (_) => const ReaderSettingsSheet(),
                ),
              ),
              IconButton(
                icon: Icon(_showSearch ? Icons.search_off : Icons.search),
                tooltip: 'Search in book',
                onPressed: () => setState(() => _showSearch = !_showSearch),
              ),
              if (!useSplit)
                IconButton(
                  icon: const Icon(Icons.list_alt),
                  tooltip: 'Table of contents',
                  onPressed: () => _openTocSheet(book),
                ),
              IconButton(
                icon: const Icon(Icons.highlight_outlined),
                tooltip: 'Highlights',
                onPressed: () => _openHighlightsSheet(readingState.highlights),
              ),
              IconButton(
                icon: const Icon(Icons.sticky_note_2_outlined),
                tooltip: 'Book note',
                onPressed: () => _editBookNote(readingState.userNote),
              ),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: 'Share reading',
                onPressed: () => _shareReading(book, readingState.highlights),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.fromTopicId != null || widget.fromClaimId != null)
                Material(
                  color: context.sd.accentGold.withValues(alpha: 0.12),
                  child: InkWell(
                    onTap: widget.fromClaimId != null
                        ? () => context.go('/claim/${widget.fromClaimId}')
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 16, color: context.sd.accentGold),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              widget.fromClaimId != null
                                  ? 'Opened from claim — tap to return to briefing'
                                  : 'Recommended for topic: ${widget.fromTopicId}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          if (widget.fromClaimId != null)
                            Icon(Icons.chevron_right,
                                size: 18, color: context.sd.accentGold),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: ReadingProgressStrip(
                  fraction: _scrollFraction,
                  chapterTitle: book.chapters
                      .where((c) => c.id == _activeChapterId)
                      .map((c) => c.title)
                      .firstOrNull,
                ),
              ),
              if (_showSearch)
                BookSearchBar(
                  controller: _searchController,
                  onQueryChanged: (q) => setState(() {
                    _searchQuery = q;
                    _activeMatchIndex = 0;
                  }),
                  matches: matches,
                  activeMatchIndex: _activeMatchIndex,
                  onNext: () => setState(() {
                    if (matches.isEmpty) return;
                    _activeMatchIndex = (_activeMatchIndex + 1) % matches.length;
                  }),
                  onPrevious: () => setState(() {
                    if (matches.isEmpty) return;
                    _activeMatchIndex = (_activeMatchIndex - 1 + matches.length) %
                        matches.length;
                  }),
                  onClose: () => setState(() {
                    _showSearch = false;
                    _searchController.clear();
                  }),
                ),
              Expanded(child: body),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Reader')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Reader')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  void _openTocSheet(Book book) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => BookTocPanel(
          chapters: book.chapters,
          activeChapterId: _activeChapterId,
          progressFraction: _scrollFraction,
          onChapterTap: (ch) {
            Navigator.pop(ctx);
            _readerKey.currentState?.scrollToChapter(ch);
          },
        ),
      ),
    );
  }

  Future<void> _shareReading(Book book, List<BookHighlight> highlights) async {
    if (highlights.isNotEmpty) {
      await ShareActions.shareHighlights(
        book: book,
        excerpts: highlights
            .map((h) => h.note?.isNotEmpty == true
                ? h.note!
                : 'Passage highlight (${h.start}–${h.end})')
            .toList(),
      );
      return;
    }
    final chapter = book.chapters
        .where((c) => c.id == _activeChapterId)
        .map((c) => c.title)
        .firstOrNull;
    await ShareActions.shareBookExcerpt(
      book: book,
      excerpt: 'Reading ${(_scrollFraction * 100).round()}% through ${book.title}',
      chapterTitle: chapter,
    );
  }

  Future<void> _editBookNote(String? existing) async {
    final controller = TextEditingController(text: existing ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book note'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Your private reading notes are saved on this device…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      await ref.read(bookReadingActionsProvider).saveUserNote(
            widget.bookId,
            controller.text,
          );
    }
    controller.dispose();
  }
}