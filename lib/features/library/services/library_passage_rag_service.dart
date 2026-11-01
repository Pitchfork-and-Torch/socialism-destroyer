import 'package:flutter/services.dart';

import '../../../models/book.dart';
import '../../../models/claim_reading_link.dart';
import '../../../models/library_passage.dart';
import '../../../services/claim_reading_service.dart';
import '../../../services/knowledge_service.dart';

/// Offline passage-level library RAG for debate evidence sidebars.
///
/// Strategy (no network):
/// 1. Prefer curated [ClaimReadingLink]s for matched claim IDs.
/// 2. Load book asset text (capped) and extract overlapping windows.
/// 3. Fall back to book description + title token match for topical books.
class LibraryPassageRagService {
  LibraryPassageRagService({
    KnowledgeService? knowledge,
    ClaimReadingService? links,
  })  : _knowledge = knowledge ?? KnowledgeService(),
        _links = links ?? ClaimReadingService();

  final KnowledgeService _knowledge;
  final ClaimReadingService _links;

  final Map<String, String> _textCache = {};
  static const _maxAssetChars = 48000;
  static const _windowChars = 420;

  /// Rank library passages for a debate query + matched claim IDs.
  Future<List<LibraryPassageHit>> retrieve({
    required String query,
    List<String> claimIds = const [],
    int limit = 6,
  }) async {
    final terms = _tokenize(query);
    final books = await _knowledge.getBooks();
    final bookMap = {for (final b in books) b.id: b};
    final hits = <LibraryPassageHit>[];
    final seen = <String>{};

    // 1) Curated claim → book links (highest trust).
    final allLinks = await _links.getAllLinks();
    final claimSet = claimIds.toSet();
    final curated = allLinks
        .where((l) => claimSet.isEmpty || claimSet.contains(l.claimId))
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final link in curated.take(12)) {
      final book = bookMap[link.bookId];
      if (book == null) continue;
      final passage = await _passageForLink(book, link, terms);
      if (passage == null) continue;
      final key = '${passage.bookId}|${passage.snippet.hashCode}';
      if (!seen.add(key)) continue;
      hits.add(passage);
    }

    // 2) Topical books by recommendation topic / description overlap.
    if (hits.length < limit) {
      final topical = _rankBooksByQuery(books, terms).take(8);
      for (final book in topical) {
        if (hits.length >= limit * 2) break;
        final passage = await _bestWindow(book, terms, reason: 'Topical match');
        if (passage == null) continue;
        final key = '${passage.bookId}|${passage.snippet.hashCode}';
        if (!seen.add(key)) continue;
        hits.add(passage);
      }
    }

    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(limit).toList();
  }

  Future<LibraryPassageHit?> _passageForLink(
    Book book,
    ClaimReadingLink link,
    Set<String> terms,
  ) async {
    final text = await _loadBookText(book);
    if (text == null || text.isEmpty) {
      return LibraryPassageHit(
        bookId: book.id,
        bookTitle: book.title,
        author: book.author,
        snippet: book.description,
        score: 0.55,
        chapterId: link.chapterId,
        reason: link.reason,
        claimId: link.claimId,
      );
    }

    String snippet;
    var score = 0.7;
    if (link.chapterId != null && book.chapters.isNotEmpty) {
      BookChapter? chapter;
      for (final c in book.chapters) {
        if (c.id == link.chapterId) {
          chapter = c;
          break;
        }
      }
      if (chapter != null) {
        // Prefer windows near chapter title mention when possible.
        final idx = text.toLowerCase().indexOf(chapter.title.toLowerCase());
        if (idx >= 0) {
          snippet = _windowAt(text, idx);
          score = 0.92;
        } else {
          snippet = _bestWindowFromText(text, terms) ??
              text.substring(0, text.length.clamp(0, _windowChars));
          score = 0.8;
        }
        return LibraryPassageHit(
          bookId: book.id,
          bookTitle: book.title,
          author: book.author,
          snippet: snippet.trim(),
          score: score + _termBoost(snippet, terms),
          chapterId: chapter.id,
          chapterTitle: chapter.title,
          reason: link.reason,
          claimId: link.claimId,
        );
      }
    }

    snippet = _bestWindowFromText(text, terms) ??
        text.substring(0, text.length.clamp(0, _windowChars));
    return LibraryPassageHit(
      bookId: book.id,
      bookTitle: book.title,
      author: book.author,
      snippet: snippet.trim(),
      score: 0.78 + _termBoost(snippet, terms),
      chapterId: link.chapterId,
      reason: link.reason,
      claimId: link.claimId,
    );
  }

  Future<LibraryPassageHit?> _bestWindow(
    Book book,
    Set<String> terms, {
    String? reason,
  }) async {
    final text = await _loadBookText(book);
    if (text == null || text.isEmpty) {
      final descScore = _termBoost(book.description, terms) +
          _termBoost('${book.title} ${book.author}', terms);
      if (descScore <= 0) return null;
      return LibraryPassageHit(
        bookId: book.id,
        bookTitle: book.title,
        author: book.author,
        snippet: book.description,
        score: 0.35 + descScore,
        reason: reason,
      );
    }
    final snippet = _bestWindowFromText(text, terms);
    if (snippet == null) return null;
    return LibraryPassageHit(
      bookId: book.id,
      bookTitle: book.title,
      author: book.author,
      snippet: snippet.trim(),
      score: 0.45 + _termBoost(snippet, terms),
      reason: reason,
    );
  }

  List<Book> _rankBooksByQuery(List<Book> books, Set<String> terms) {
    if (terms.isEmpty) return books.take(5).toList();
    final scored = <({Book book, double score})>[];
    for (final b in books) {
      final corpus =
          '${b.title} ${b.author} ${b.description} ${b.recommendedTopicIds.join(' ')}';
      final s = _termBoost(corpus, terms);
      if (s > 0) scored.add((book: b, score: s));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.book).toList();
  }

  Future<String?> _loadBookText(Book book) async {
    final path = book.fullTextPath ?? book.excerptPath ?? book.assetPath;
    if (path.isEmpty) return null;
    if (_textCache.containsKey(path)) return _textCache[path];
    try {
      var raw = await rootBundle.loadString(path);
      if (raw.length > _maxAssetChars) {
        raw = raw.substring(0, _maxAssetChars);
      }
      _textCache[path] = raw;
      return raw;
    } catch (_) {
      return null;
    }
  }

  String? _bestWindowFromText(String text, Set<String> terms) {
    if (terms.isEmpty) {
      return text.substring(0, text.length.clamp(0, _windowChars));
    }
    final lower = text.toLowerCase();
    var bestIdx = -1;
    var bestHits = 0;
    // Sample stride for large texts.
    final step = text.length > 20000 ? 280 : 160;
    for (var i = 0; i < text.length; i += step) {
      final end = (i + _windowChars).clamp(0, text.length);
      final window = lower.substring(i, end);
      var hits = 0;
      for (final t in terms) {
        if (window.contains(t)) hits++;
      }
      if (hits > bestHits) {
        bestHits = hits;
        bestIdx = i;
      }
    }
    if (bestIdx < 0 || bestHits == 0) return null;
    return _windowAt(text, bestIdx);
  }

  String _windowAt(String text, int idx) {
    if (text.isEmpty) return '';
    final start = idx.clamp(0, text.length);
    var end = start + _windowChars;
    if (end > text.length) end = text.length;
    if (start >= end) {
      final back = (text.length - _windowChars).clamp(0, text.length);
      return text.substring(back).trim();
    }
    var slice = text.substring(start, end).trim();
    // Snap to word boundaries when possible.
    final firstSpace = slice.indexOf(' ');
    final lastSpace = slice.lastIndexOf(' ');
    if (firstSpace > 0 && firstSpace < 40 && firstSpace < slice.length - 1) {
      slice = slice.substring(firstSpace + 1);
    }
    if (lastSpace > 80 && lastSpace < slice.length) {
      slice = slice.substring(0, lastSpace);
    }
    return slice;
  }

  double _termBoost(String text, Set<String> terms) {
    if (terms.isEmpty) return 0;
    final lower = text.toLowerCase();
    var hits = 0;
    for (final t in terms) {
      if (lower.contains(t)) hits++;
    }
    return (hits / terms.length).clamp(0, 1) * 0.35;
  }

  Set<String> _tokenize(String text) {
    const stop = {
      'the',
      'and',
      'for',
      'that',
      'with',
      'this',
      'from',
      'are',
      'was',
      'were',
      'have',
      'has',
      'not',
      'but',
      'you',
      'your',
      'they',
      'their',
      'what',
      'when',
      'who',
      'how',
      'all',
      'any',
      'can',
      'will',
      'just',
      'about',
    };
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 3 && !stop.contains(t))
        .toSet();
  }
}
