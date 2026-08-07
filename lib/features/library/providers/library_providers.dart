import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/book.dart';
import '../../../models/book_reading.dart';
import '../../../models/claim_reading_link.dart';
import '../../../models/reader_settings.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../services/book_offline_service.dart';
import '../../../services/book_reading_service.dart';
import '../../../services/claim_reading_service.dart';
import '../../../services/local_storage_service.dart';

const _readerSettingsKey = 'reader_settings';

final bookReadingServiceProvider = Provider<BookReadingService>(
  (ref) => BookReadingService(local: ref.watch(localStorageProvider)),
);

final bookOfflineServiceProvider = Provider<BookOfflineService>(
  (ref) => BookOfflineService(),
);

final claimReadingServiceProvider = Provider<ClaimReadingService>(
  (ref) => ClaimReadingService(),
);

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(knowledgeServiceProvider).getBooks();
  return [...books]..sort((a, b) => a.title.compareTo(b.title));
});

final bookProvider = FutureProvider.family<Book?, String>((ref, bookId) async {
  final books = await ref.watch(booksProvider.future);
  try {
    return books.firstWhere((b) => b.id == bookId);
  } catch (_) {
    return null;
  }
});

final offlineBookIdsProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(offlineRevisionProvider);
  return ref.watch(bookOfflineServiceProvider).downloadedBookIds();
});

final offlineRevisionProvider = StateProvider<int>((ref) => 0);

final bookContentProvider =
    FutureProvider.family<String, String>((ref, bookId) async {
  if (!kIsWeb) {
    final offline = ref.watch(bookOfflineServiceProvider);
    try {
      final cached = await offline.readCached(bookId);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {
      // Fall through to bundled assets.
    }
  }

  final book = await ref.watch(bookProvider(bookId).future);
  if (book == null) return '';
  final path = book.fullTextPath ?? book.excerptPath ?? book.assetPath;
  if (path.isEmpty) return '';
  return rootBundle.loadString(path);
});

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
  (ref) => ReaderSettingsNotifier(ref.watch(localStorageProvider)),
);

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  ReaderSettingsNotifier(this._local) : super(const ReaderSettings()) {
    _load();
  }

  final LocalStorageService _local;

  void _load() {
    final raw = _local.settings.get(_readerSettingsKey);
    if (raw is Map) {
      state = ReaderSettings.fromJson(Map<String, dynamic>.from(raw));
    }
  }

  Future<void> update(ReaderSettings next) async {
    state = next;
    await _local.settings.put(_readerSettingsKey, next.toJson());
  }
}

final bookReadingStateProvider =
    Provider.family<BookReadingState, String>((ref, bookId) {
  ref.watch(bookReadingRevisionProvider);
  return ref.watch(bookReadingServiceProvider).loadState(bookId);
});

final bookReadingRevisionProvider = StateProvider<int>((ref) => 0);

void _bumpReadingRevision(Ref ref) {
  ref.read(bookReadingRevisionProvider.notifier).state++;
}

final bookReadingActionsProvider = Provider<BookReadingActions>(
  (ref) => BookReadingActions(ref),
);

class BookReadingActions {
  BookReadingActions(this._ref);

  final Ref _ref;

  BookReadingService get _service => _ref.read(bookReadingServiceProvider);

  Future<void> _syncIfSignedIn() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    await _ref.read(userProfileServiceProvider).syncReadingData(user.id);
  }

  Future<void> saveProgress(BookReadingProgress progress) async {
    await _service.saveProgress(progress);
    _bumpReadingRevision(_ref);
    await _syncIfSignedIn();
  }

  Future<BookHighlight> addHighlight({
    required String bookId,
    required int start,
    required int end,
    String? note,
  }) async {
    final h = await _service.createHighlight(
      bookId: bookId,
      start: start,
      end: end,
      note: note,
    );
    _bumpReadingRevision(_ref);
    await _syncIfSignedIn();
    return h;
  }

  Future<void> updateHighlightNote(
    String bookId,
    BookHighlight highlight,
    String? note,
  ) async {
    await _service.saveHighlight(
      bookId,
      highlight.copyWith(
        note: note,
        updatedAt: DateTime.now(),
      ),
    );
    _bumpReadingRevision(_ref);
    await _syncIfSignedIn();
  }

  Future<void> removeHighlight(String bookId, String highlightId) async {
    await _service.removeHighlight(bookId, highlightId);
    _bumpReadingRevision(_ref);
    await _syncIfSignedIn();
  }

  Future<void> saveUserNote(String bookId, String? note) async {
    await _service.saveUserNote(bookId, note);
    _bumpReadingRevision(_ref);
    await _syncIfSignedIn();
  }

  Future<void> downloadForOffline(Book book) async {
    await _ref.read(bookOfflineServiceProvider).downloadBook(book);
    _ref.read(offlineRevisionProvider.notifier).state++;
  }
}

final bookSearchProvider =
    Provider.family<List<BookSearchMatch>, ({String bookId, String query})>(
  (ref, args) {
    final content = ref.watch(bookContentProvider(args.bookId));
    return content.when(
      data: (text) =>
          ref.watch(bookReadingServiceProvider).searchInText(text, args.query),
      loading: () => const [],
      error: (_, _) => const [],
    );
  },
);

final booksForTopicProvider =
    FutureProvider.family<List<Book>, String>((ref, topicId) async {
  final books = await ref.watch(booksProvider.future);
  return books
      .where(
        (b) => b.recommendations.any((r) => r.topicId == topicId) ||
            b.recommendedTopicIds.contains(topicId),
      )
      .toList()
    ..sort((a, b) {
      final pa = _topicPriority(a, topicId);
      final pb = _topicPriority(b, topicId);
      return pa.compareTo(pb);
    });
});

int _topicPriority(Book book, String topicId) {
  for (final r in book.recommendations) {
    if (r.topicId == topicId) return r.priority;
  }
  return 99;
}

final claimReadingLinksProvider =
    FutureProvider.family<List<ClaimReadingLink>, String>((ref, claimId) async {
  return ref.watch(claimReadingServiceProvider).linksForClaim(claimId);
});

final allBookProgressProvider = Provider<Map<String, BookReadingProgress>>((ref) {
  ref.watch(bookReadingRevisionProvider);
  final booksAsync = ref.watch(booksProvider);
  final service = ref.watch(bookReadingServiceProvider);
  return booksAsync.maybeWhen(
    data: (books) {
      return {
        for (final book in books)
          if (service.loadState(book.id).progress != null)
            book.id: service.loadState(book.id).progress!,
      };
    },
    orElse: () => const {},
  );
});

/// Most recently updated in-progress book for "Continue reading" hero.
final continueReadingProvider = Provider<({Book book, BookReadingProgress progress})?>((ref) {
  ref.watch(bookReadingRevisionProvider);
  final booksAsync = ref.watch(booksProvider);
  final service = ref.watch(bookReadingServiceProvider);
  return booksAsync.maybeWhen(
    data: (books) {
      ({Book book, BookReadingProgress progress})? best;
      for (final book in books) {
        final p = service.loadState(book.id).progress;
        if (p == null || p.scrollFraction < 0.02) continue;
        if (best == null || p.updatedAt.isAfter(best.progress.updatedAt)) {
          best = (book: book, progress: p);
        }
      }
      return best;
    },
    orElse: () => null,
  );
});