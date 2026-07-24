import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/features/library/providers/library_providers.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/features/sync/providers/knowledge_sync_providers.dart';
import 'package:socialism_destroyer/models/knowledge_sync.dart';
import 'package:socialism_destroyer/utils/app_constants.dart';
import 'package:socialism_destroyer/services/knowledge_sync_service.dart';
import 'package:socialism_destroyer/services/search_service.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';

import 'fakes/test_book_offline_service.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  group('Offline mode', () {
    test('sync check returns notConfigured without CDN', () async {
      final sync = KnowledgeSyncService(cdnUrlOverride: '');
      final result = await sync.checkForUpdates();
      expect(result.availability, UpdateAvailability.notConfigured);
    });

    test('knowledge service loads bundled claims offline', () async {
      final claims = await KnowledgeService().getClaims();
      expect(claims.length, greaterThanOrEqualTo(AppConstants.minClaimsTarget));
    });

    testWidgets('home shows intelligence sync panel while offline', (tester) async {
      await pumpTestApp(
        tester,
        size: TestDevices.iphone14,
        initialLocation: AppRoutes.home,
        overrides: [
          knowledgeSyncStateProvider.overrideWith(
            (ref) async => const KnowledgeSyncState(
              bundledKbVersion: AppConstants.knowledgeBaseVersion,
            ),
          ),
        ],
      );
      expect(find.text('Intelligence updates'), findsOneWidget);
      await tester.tap(find.text('Intelligence updates'));
      await settleJourney(tester);
      expect(find.text('Sync Latest Intelligence'), findsWidgets);
      expect(find.text('Auto-check on launch'), findsOneWidget);
    });
  });

  group('Large search results', () {
    test('caps FTS results at maxSearchResults', () async {
      final search = SearchService(KnowledgeService());
      final results = await search.search('socialism');
      expect(results.length, lessThanOrEqualTo(AppConstants.maxSearchResults));
      expect(results, isNotEmpty);
    });

    test('broad query returns many distinct claims', () async {
      final search = SearchService(KnowledgeService());
      final results = await search.search('capitalism');
      expect(results.length, greaterThan(10));
      expect(results.map((c) => c.id).toSet().length, results.length);
    });
  });

  group('Accessibility', () {
    testWidgets('bottom nav exposes labeled destinations', (tester) async {
      await pumpTestApp(tester, size: TestDevices.iphone14);
      for (final tab in ['Home', 'Topics', 'Crusher', 'Library']) {
        expect(find.bySemanticsLabel(tab), findsWidgets);
      }
    });

    testWidgets('library reader tools have tooltips', (tester) async {
      final bundle = await TestKnowledgeBundle.load();
      final law = bundle.books.firstWhere((b) => b.id == 'the-law');
      await pumpTestApp(
        tester,
        size: TestDevices.iphone14,
        initialLocation: '/library/read/the-law',
        overrides: [
          bookProvider('the-law').overrideWith((ref) async => law),
          bookContentProvider('the-law').overrideWith(
            (ref) async => '# The Law\n\n## Chapter 1\n\nSample passage.',
          ),
          bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
        ],
      );
      await settleJourney(tester, maxPumps: 40);
      await waitForFinder(tester, find.byTooltip('Book note'), maxPumps: 40);

      expect(find.byTooltip('Reader settings'), findsOneWidget);
      expect(find.byTooltip('Book note'), findsOneWidget);
      expect(find.byTooltip('Highlights'), findsOneWidget);
      expect(find.byTooltip('Search in book'), findsOneWidget);
    });
  });
}