import 'package:uuid/uuid.dart';

import '../models/book.dart';
import '../models/book_reading.dart';
import 'local_storage_service.dart';

/// Offline-first persistence for book progress, highlights, and notes.
class BookReadingService {
  BookReadingService({LocalStorageService? local})
      : _local = local ?? LocalStorageService();

  final LocalStorageService _local;
  static const _uuid = Uuid();

  static String progressKey(String bookId) => 'book:$bookId';
  static String annotationsKey(String bookId) => 'book:$bookId';

  BookReadingState loadState(String bookId) {
    final progressRaw = _local.readingProgress.get(progressKey(bookId));
    final notesRaw = _local.notes.get(annotationsKey(bookId));
    return BookReadingState.fromMaps(
      bookId: bookId,
      progressMap: progressRaw != null
          ? Map<String, dynamic>.from(progressRaw)
          : null,
      annotationsMap:
          notesRaw != null ? Map<String, dynamic>.from(notesRaw) : null,
    );
  }

  Future<void> saveProgress(BookReadingProgress progress) async {
    await _local.readingProgress.put(
      progressKey(progress.bookId),
      progress.toJson(),
    );
  }

  Future<void> saveHighlight(String bookId, BookHighlight highlight) async {
    final state = loadState(bookId);
    final existing = state.highlights.where((h) => h.id != highlight.id);
    final updated = [...existing, highlight]
      ..sort((a, b) => a.start.compareTo(b.start));
    await _persistAnnotations(
      bookId,
      highlights: updated,
      userNote: state.userNote,
    );
  }

  Future<void> removeHighlight(String bookId, String highlightId) async {
    final state = loadState(bookId);
    final updated =
        state.highlights.where((h) => h.id != highlightId).toList();
    await _persistAnnotations(
      bookId,
      highlights: updated,
      userNote: state.userNote,
    );
  }

  Future<void> saveUserNote(String bookId, String? note) async {
    final state = loadState(bookId);
    await _persistAnnotations(
      bookId,
      highlights: state.highlights,
      userNote: note?.trim().isEmpty == true ? null : note?.trim(),
    );
  }

  Future<BookHighlight> createHighlight({
    required String bookId,
    required int start,
    required int end,
    String? note,
    String colorKey = 'gold',
  }) async {
    final highlight = BookHighlight(
      id: _uuid.v4(),
      start: start,
      end: end,
      note: note,
      colorKey: colorKey,
      createdAt: DateTime.now(),
    );
    await saveHighlight(bookId, highlight);
    return highlight;
  }

  Future<void> _persistAnnotations(
    String bookId, {
    required List<BookHighlight> highlights,
    String? userNote,
  }) async {
    final payload = <String, dynamic>{
      'highlights': highlights.map((h) => h.toJson()).toList(),
      'userNote': ?userNote,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (highlights.isEmpty && userNote == null) {
      await _local.notes.delete(annotationsKey(bookId));
    } else {
      await _local.notes.put(annotationsKey(bookId), payload);
    }
  }

  /// Resolve active chapter from character offset.
  BookChapter? chapterAtOffset(Book book, int offset) {
    if (book.chapters.isEmpty) return null;
    BookChapter active = book.chapters.first;
    for (final chapter in book.chapters) {
      if (chapter.startOffset <= offset) {
        active = chapter;
      } else {
        break;
      }
    }
    return active;
  }

  /// Case-insensitive search across full book text.
  List<BookSearchMatch> searchInText(String content, String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];

    final lower = content.toLowerCase();
    final matches = <BookSearchMatch>[];
    var start = 0;
    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx == -1) break;
      final previewStart = (idx - 40).clamp(0, content.length);
      final previewEnd = (idx + q.length + 40).clamp(0, content.length);
      var preview = content.substring(previewStart, previewEnd).replaceAll('\n', ' ');
      if (previewStart > 0) preview = '…$preview';
      if (previewEnd < content.length) preview = '$preview…';
      matches.add(
        BookSearchMatch(
          index: matches.length,
          start: idx,
          end: idx + q.length,
          preview: preview,
        ),
      );
      start = idx + q.length;
      if (matches.length >= 100) break;
    }
    return matches;
  }
}