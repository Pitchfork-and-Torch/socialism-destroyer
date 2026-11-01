import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/models/book_reading.dart';
import 'package:socialism_destroyer/features/library/screens/library_reader_screen.dart';
import 'package:socialism_destroyer/features/library/screens/library_screen.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';

import 'package:socialism_destroyer/features/library/utils/book_content_parser.dart';
import 'package:socialism_destroyer/services/book_reading_service.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/features/library/providers/library_providers.dart';
import 'fakes/test_book_offline_service.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookReadingService', () {
    setUpAll(() async {
      await initTestHive();
    });

    test('search finds Bastiat legal plunder passage', () async {
      final knowledge = KnowledgeService();
      final books = await knowledge.getBooks();
      final law = books.firstWhere((b) => b.id == 'the-law');
      final path = law.fullTextPath!;
      final service = BookReadingService();
      final content = await rootBundle.loadString(path);
      final matches = service.searchInText(content, 'legal plunder');
      expect(matches.length, greaterThan(3));
    });

    test('persists progress and highlights offline', () async {
      final service = BookReadingService();
      await service.saveProgress(
        BookReadingProgress(
          bookId: 'the-law',
          scrollFraction: 0.42,
          scrollOffset: 1200,
          chapterId: 'perversion',
          updatedAt: DateTime.now(),
        ),
      );
      await service.createHighlight(
        bookId: 'the-law',
        start: 100,
        end: 140,
        note: 'Key insight',
      );
      final state = service.loadState('the-law');
      expect(state.progress?.scrollFraction, closeTo(0.42, 0.001));
      expect(state.highlights, hasLength(1));
      expect(state.highlights.first.note, 'Key insight');
    });
  });

  group('BookContentParser', () {
    test('parses chapter blocks from full law text', () async {
      final knowledge = KnowledgeService();
      final books = await knowledge.getBooks();
      final law = books.firstWhere((b) => b.id == 'the-law');
      final content = await rootBundle.loadString(law.fullTextPath!);
      expect(content.length, greaterThan(50000));
      expect(content.toLowerCase(), contains('legal plunder'));
      expect(law.chapters.length, greaterThan(10));
      final blocks = BookContentParser.parse(content, law.chapters);
      expect(blocks, isNotEmpty);
      expect(
        blocks.any((b) => b.text.toLowerCase().contains('legal plunder')),
        isTrue,
      );
    });
  });

  group('Library screens', () {
    late List<dynamic> books;

    setUpAll(() async {
      await initTestHive();
      books = await KnowledgeService().getBooks();
    });

    Future<void> pumpLibrary(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            booksProvider.overrideWith((ref) async => books.cast()),
          ],
          child: MaterialApp(
            theme: journeyTestTheme(),
            home: MediaQuery(
              data: MediaQueryData(size: size, disableAnimations: true),
              child: const LibraryScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 30);
      await waitForFinder(tester, find.text('The Law'), maxPumps: 30);
    }

    testWidgets('library lists expanded American and economics canon', (tester) async {
      await pumpLibrary(tester, const Size(390, 844));
      expect(books.length, greaterThanOrEqualTo(35));
      expect(find.text('The Declaration of Independence'), findsWidgets);
      expect(find.textContaining('Full text'), findsWidgets);
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(find.text('Common Sense'), 200, scrollable: scrollable);
      await tester.scrollUntilVisible(find.text('The Law'), 200, scrollable: scrollable);
      expect(find.text('The Law'), findsWidgets);
    });

    testWidgets('reader shows TOC and progress at 1280px', (tester) async {
      final law = books.cast().firstWhere((b) => b.id == 'the-law');
      const sampleContent = '''
# The Law

*By Frédéric Bastiat*

## The Law Perverted

The law perverted! And the police powers of the state perverted along with it!

## Life, Liberty, and Property

We hold from God the gift that contains all others, Life.
''';

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookProvider('the-law').overrideWith((ref) async => law),
            bookContentProvider('the-law').overrideWith((ref) async => sampleContent),
            bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
          ],
          child: MaterialApp(
            theme: journeyTestTheme(),
            home: const MediaQuery(
              data: MediaQueryData(
                size: Size(1280, 800),
                disableAnimations: true,
              ),
              child: LibraryReaderScreen(bookId: 'the-law'),
            ),
          ),
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 40);
      await waitForFinder(tester, find.text('Contents'), maxPumps: 40);
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('The Law Perverted'), findsWidgets);
    });

    testWidgets('reader jumps to linked chapter when opened from claim', (tester) async {
      final won = books.cast().firstWhere((b) => b.id == 'wealth-of-nations');
      const sampleContent = '''
# An Inquiry into the Nature and Causes of the Wealth of Nations

## The Invisible Hand

By preferring the support of domestic to that of foreign industry, he intends only his own security;
and by directing that industry in such a manner as its produce may be of the greatest value,
he intends only his own gain, and he is in this, as in many other cases, led by an invisible hand.
''';

      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookProvider('wealth-of-nations').overrideWith((ref) async => won),
            bookContentProvider('wealth-of-nations').overrideWith((ref) async => sampleContent),
            bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
          ],
          child: MaterialApp(
            theme: journeyTestTheme(),
            home: const MediaQuery(
              data: MediaQueryData(
                size: Size(390, 844),
                disableAnimations: true,
              ),
              child: LibraryReaderScreen(
                bookId: 'wealth-of-nations',
                fromClaimId: 'profit-is-theft',
                initialChapterId: 'invisible-hand',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 60);
      await waitForFinder(tester, find.text('The Invisible Hand'), maxPumps: 60);
      expect(find.text(won.title), findsWidgets);
      expect(find.text('The Invisible Hand'), findsWidgets);
    });

    test('isOutsideShell detects claim routes', () {
      expect(AppRoutes.isOutsideShell('/claim/rent-control-helps'), isTrue);
      expect(AppRoutes.isOutsideShell('/library/read/the-law'), isFalse);
      expect(AppRoutes.isOutsideShell('/tree'), isFalse);
    });

    testWidgets('claim page navigates to reader on mobile width (go, not blank)', (tester) async {
      final law = books.cast().firstWhere((b) => b.id == 'the-law');
      const sampleContent = '# The Law\n\n## Public Works\n\nContent here.';

      final router = buildTestRouter(
        initialLocation: '/claim/rent-control-helps',
      );
      activeTestRouter = router;

      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookProvider('the-law').overrideWith((ref) async => law),
            bookContentProvider('the-law').overrideWith((ref) async => sampleContent),
            bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
          ],
          child: MaterialApp.router(
            theme: journeyTestTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 40);

      router.go(
        AppRoutes.libraryReaderPath(
          'the-law',
          chapterId: 'identify-plunder',
          claimId: 'rent-control-helps',
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 40);
      await waitForFinder(tester, find.text('The Law'), maxPumps: 40);

      expect(find.text('The Law'), findsWidgets);
      expect(find.text('Library'), findsWidgets);
    });

    test('libraryReaderPath encodes chapter and claim deep links', () {
      expect(
        AppRoutes.libraryReaderPath('wealth-of-nations'),
        '/library/read/wealth-of-nations',
      );
      expect(
        AppRoutes.libraryReaderPath(
          'wealth-of-nations',
          chapterId: 'invisible-hand',
          claimId: 'profit-is-theft',
        ),
        '/library/read/wealth-of-nations?chapter=invisible-hand&claim=profit-is-theft',
      );
    });

    testWidgets('shell route renders reader at /library/read (not blank)', (tester) async {
      final law = books.cast().firstWhere((b) => b.id == 'the-law');
      const sampleContent = '''
# The Law

## How to Identify Legal Plunder

See whether the law takes from some persons what belongs to them.
''';

      final router = buildTestRouter(
        initialLocation: AppRoutes.libraryReaderPath(
          'the-law',
          chapterId: 'identify-plunder',
          claimId: 'rent-control-helps',
        ),
      );
      activeTestRouter = router;

      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookProvider('the-law').overrideWith((ref) async => law),
            bookContentProvider('the-law').overrideWith((ref) async => sampleContent),
            bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
          ],
          child: MaterialApp.router(
            theme: journeyTestTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 40);
      await waitForFinder(tester, find.text('The Law'), maxPumps: 40);

      expect(find.text('The Law'), findsWidgets);
      expect(find.text('How to Identify Legal Plunder'), findsWidgets);
      expect(find.text('Library'), findsWidgets);
    });
  });
}