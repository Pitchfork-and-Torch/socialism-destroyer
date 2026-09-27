import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:socialism_destroyer/core/app_initializer.dart';
import 'package:socialism_destroyer/features/crusher/screens/argument_crusher_screen.dart';
import 'package:socialism_destroyer/features/debate_simulator/screens/debate_simulator_screen.dart';
import 'package:socialism_destroyer/features/home/screens/home_screen.dart';
import 'package:socialism_destroyer/models/debate_session.dart';
import 'package:socialism_destroyer/features/library/screens/library_reader_screen.dart';
import 'package:socialism_destroyer/features/library/screens/library_screen.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/features/shared/widgets/app_shell.dart';
import 'package:socialism_destroyer/features/sync/widgets/sync_launch_listener.dart';
import 'package:socialism_destroyer/features/tree/providers/topic_tree_providers.dart';
import 'package:socialism_destroyer/features/tree/screens/claim_detail_screen.dart';
import 'package:socialism_destroyer/features/tree/screens/topic_tree_screen.dart';
import 'package:socialism_destroyer/features/tree/services/topic_tree_index.dart';
import 'package:socialism_destroyer/features/crusher/providers/crusher_providers.dart';
import 'package:socialism_destroyer/features/sync/providers/knowledge_sync_providers.dart';
import 'package:socialism_destroyer/models/knowledge_sync.dart';
import 'package:socialism_destroyer/utils/app_constants.dart';
import 'package:socialism_destroyer/features/crusher/services/crusher_service.dart';
import 'package:socialism_destroyer/features/home/widgets/crush_argument_bar.dart';
import 'package:socialism_destroyer/features/library/providers/library_providers.dart';
import 'package:socialism_destroyer/models/book.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/models/topic.dart';
import 'package:socialism_destroyer/providers/app_providers.dart';
import 'package:socialism_destroyer/services/database_service.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/services/local_storage_service.dart';
import 'package:socialism_destroyer/themes/app_fonts.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';
import 'package:socialism_destroyer/features/home/models/user_progress.dart';
import 'package:socialism_destroyer/features/home/providers/home_providers.dart';
import 'package:socialism_destroyer/features/tree/widgets/claim_detail_skeleton.dart';

import 'fakes/noop_debate_history_service.dart';
import 'fakes/test_book_offline_service.dart';
import 'fakes/test_claim_retrieval_backend.dart';

/// Standard device sizes for journey tests.
abstract final class TestDevices {
  static const Size iphone14 = Size(390, 844);
  static const Size ipadPortrait = Size(834, 1194);
  static const Size ipadLandscape = Size(1194, 834);
  static const Size desktop = Size(1280, 800);
}

void initTestDatabase() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> initTestHive() async {
  if (Hive.isBoxOpen(LocalStorageService.settingsBox)) return;
  final dir = Directory.systemTemp.createTempSync('sd_hive_test');
  Hive.init(dir.path);
  await Future.wait([
    Hive.openBox<String>(LocalStorageService.favoritesBox),
    Hive.openBox<Map>(LocalStorageService.notesBox),
    Hive.openBox<Map>(LocalStorageService.historyBox),
    Hive.openBox<Map>(LocalStorageService.debateSessionsBox),
    Hive.openBox<Map>(LocalStorageService.progressBox),
    Hive.openBox(LocalStorageService.settingsBox),
    Hive.openBox<String>(LocalStorageService.knowledgeOverlayBox),
  ]);
}

/// Active router from the most recent [pumpTestApp] call (for test navigation).
GoRouter? activeTestRouter;

/// Journey-test theme — production typography with system fonts (no CDN fetches).
ThemeData journeyTestTheme() => AppTheme.dark;

/// Cached knowledge bundle for consistent test data.
class TestKnowledgeBundle {
  TestKnowledgeBundle._({
    required this.topics,
    required this.claims,
    required this.books,
    required this.treeIndex,
  });

  final List<Topic> topics;
  final List<Claim> claims;
  final List<Book> books;
  final TopicTreeIndex treeIndex;

  static TestKnowledgeBundle? _instance;

  static Future<TestKnowledgeBundle> load() async {
    if (_instance != null) return _instance!;
    final knowledge = KnowledgeService();
    final topics = await knowledge.getTopics();
    final claims = await knowledge.getClaims();
    final books = await knowledge.getBooks();
    _instance = TestKnowledgeBundle._(
      topics: topics,
      claims: claims,
      books: books,
      treeIndex: TopicTreeIndex(roots: topics, claims: claims),
    );
    return _instance!;
  }

  Claim claimById(String id) => claims.firstWhere((c) => c.id == id);
}

/// Pre-warmed knowledge service — avoids asset I/O stalls under widget fake-async.
KnowledgeService? _preloadedKnowledgeService;

KnowledgeService preloadedKnowledgeService() {
  final service = _preloadedKnowledgeService;
  assert(service != null, 'Call initTestEnvironment() first');
  return service!;
}

FlutterExceptionHandler? _originalFlutterErrorHandler;

void _suppressNonFatalTestErrors() {
  _originalFlutterErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    if (message.contains('overflowed') ||
        message.contains('GoogleFonts') ||
        message.contains('HttpException') ||
        message.contains('Connection refused')) {
      return;
    }
    _originalFlutterErrorHandler?.call(details);
  };
}

void restoreTestErrorHandlers() {
  if (_originalFlutterErrorHandler != null) {
    FlutterError.onError = _originalFlutterErrorHandler;
  }
}

List<Map<String, String>>? _preloadedInsights;

Future<void> initTestEnvironment() async {
  AppFonts.configureForTests();
  _suppressNonFatalTestErrors();
  initTestDatabase();
  await initTestHive();
  final bundle = await TestKnowledgeBundle.load();
  await DatabaseService.instance.init(bundle.claims);
  _preloadedKnowledgeService = KnowledgeService();
  await Future.wait([
    _preloadedKnowledgeService!.getClaims(),
    _preloadedKnowledgeService!.getTopics(),
    _preloadedKnowledgeService!.getBooks(),
  ]);
  final insightsRaw = await rootBundle.loadString(AppConstants.insightsAsset);
  final insightsJson = jsonDecode(insightsRaw) as Map<String, dynamic>;
  _preloadedInsights = (insightsJson['insights'] as List<dynamic>).map((e) {
    final m = e as Map<String, dynamic>;
    return {
      'id': m['id'] as String,
      'quote': m['quote'] as String,
      'author': m['author'] as String,
      'dataPoint': m['dataPoint'] as String,
      'source': m['source'] as String,
    };
  }).toList();
}

ProviderScope testProviderScope({
  required Widget child,
  bool onboardingComplete = true,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      bootstrapProvider.overrideWithValue(
        AppBootstrap(onboardingComplete: onboardingComplete),
      ),
      ...overrides,
    ],
    child: child,
  );
}

/// Full app router for multi-screen user journeys.
GoRouter buildTestRouter({
  String initialLocation = AppRoutes.home,
  bool onboardingComplete = true,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.tree,
            builder: (context, state) => TopicTreeScreen(
              initialCategoryId: state.uri.queryParameters['category'],
            ),
          ),
          GoRoute(
            path: AppRoutes.crusher,
            builder: (context, state) => ArgumentCrusherScreen(
              initialQuery: state.uri.queryParameters['q'],
            ),
          ),
          GoRoute(
            path: AppRoutes.debate,
            builder: (context, state) {
              final modeParam = state.uri.queryParameters['mode'];
              DebateMode? mode;
              if (modeParam == 'challenge') {
                mode = DebateMode.challenge;
              } else if (modeParam == 'spar') {
                mode = DebateMode.spar;
              }
              return DebateSimulatorScreen(
                initialQuery: state.uri.queryParameters['q'],
                initialClaimId: state.uri.queryParameters['claim'],
                initialTopicId: state.uri.queryParameters['topic'],
                initialMode: mode,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.library,
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: 'read/:bookId',
                builder: (context, state) => LibraryReaderScreen(
                  bookId: state.pathParameters['bookId']!,
                  fromTopicId: state.uri.queryParameters['topic'],
                  fromClaimId: state.uri.queryParameters['claim'],
                  initialChapterId: state.uri.queryParameters['chapter'],
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.claim,
        builder: (context, state) => ClaimDetailScreen(
          claimId: state.pathParameters['id']!,
        ),
      ),
    ],
    redirect: (context, state) {
      if (!onboardingComplete && state.uri.path != AppRoutes.onboarding) {
        return AppRoutes.home;
      }
      return null;
    },
  );
}

const _goldenUserProgress = UserProgress(
  streakDays: 3,
  totalCrushes: 2,
  achievements: ['welcome', 'first_crush', 'explorer'],
);

List<Override> defaultJourneyOverrides(TestKnowledgeBundle bundle) => [
      knowledgeSyncStateProvider.overrideWith(
        (ref) async => const KnowledgeSyncState(
          bundledKbVersion: AppConstants.knowledgeBaseVersion,
        ),
      ),
      topicTreeIndexProvider.overrideWith((ref) async => bundle.treeIndex),
      booksProvider.overrideWith((ref) async => bundle.books),
      claimsProvider.overrideWith((ref) async => bundle.claims),
      allInsightsProvider.overrideWith(
        (ref) async => _preloadedInsights ?? const [],
      ),
      userProgressProvider.overrideWith(
        (ref) => UserProgressNotifier(
          ref.watch(userProgressServiceProvider),
          initialProgress: _goldenUserProgress,
          skipPersistence: true,
        ),
      ),
      crusherServiceProvider.overrideWith(
        (ref) => CrusherService(
          knowledge: preloadedKnowledgeService(),
          retrieval: TestClaimRetrievalBackend(bundle.claims),
        ),
      ),
      debateHistoryServiceProvider.overrideWith((ref) => NoOpDebateHistoryService()),
    ];

/// Overrides for library reader goldens — instant book content, no disk I/O.
List<Override> goldenLibraryReaderOverrides(TestKnowledgeBundle bundle) {
  final law = bundle.books.firstWhere((b) => b.id == 'the-law');
  const sampleContent = '''
# The Law

*By Frédéric Bastiat*

## The Law Perverted

The law perverted! And the police powers of the state perverted along with it!

## Life, Liberty, and Property

We hold from God the gift that contains all others, Life.
''';
  return [
    bookProvider('the-law').overrideWith((ref) async => law),
    bookContentProvider('the-law').overrideWith((ref) async => sampleContent),
    bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
  ];
}

Future<void> pumpTestApp(
  WidgetTester tester, {
  required Size size,
  String initialLocation = AppRoutes.home,
  List<Override> overrides = const [],
  TargetPlatform? platform,
  bool wrapSyncListener = false,
}) async {
  final bundle = await TestKnowledgeBundle.load();
  final previousPlatform = debugDefaultTargetPlatformOverride;
  if (platform != null) {
    debugDefaultTargetPlatformOverride = platform;
  }

  await tester.binding.setSurfaceSize(size);

  final router = buildTestRouter(initialLocation: initialLocation);
  activeTestRouter = router;

  Widget app = MaterialApp.router(
    theme: journeyTestTheme(),
    routerConfig: router,
    builder: (context, child) => MediaQuery(
      data: MediaQueryData(
        size: size,
        disableAnimations: true,
        platformBrightness: Brightness.dark,
      ),
      child: child!,
    ),
  );

  if (wrapSyncListener) {
    app = SyncLaunchListener(child: app);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bootstrapProvider.overrideWithValue(
          const AppBootstrap(onboardingComplete: true),
        ),
        ...defaultJourneyOverrides(bundle),
        ...overrides,
      ],
      child: app,
    ),
  );

  await tester.pump();
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  addTearDown(() {
    debugDefaultTargetPlatformOverride = previousPlatform;
    tester.binding.setSurfaceSize(null);
  });

  // Reset platform before binding invariant checks at test end.
  addTearDown(() => debugDefaultTargetPlatformOverride = previousPlatform);
}

Future<void> settleJourney(WidgetTester tester, {int maxPumps = 30}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) break;
  }
}

Future<void> tapNavTab(WidgetTester tester, String label) async {
  var finder = find.text(label);
  if (finder.evaluate().isEmpty) {
    finder = find.bySemanticsLabel(label);
  }
  expect(finder, findsWidgets);
  await tester.tap(finder.last);
  await settleJourney(tester);
}

Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = 120,
  int maxScrolls = 20,
}) async {
  for (var i = 0; i < maxScrolls; i++) {
    if (finder.evaluate().isNotEmpty) return;
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) return;
    await tester.drag(
      scrollables.first,
      Offset(0, -delta),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps until [finder] matches or [maxPumps] is exhausted.
Future<void> waitForFinder(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 80,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out after ${maxPumps * 100}ms waiting for $finder');
}

/// Pumps until anchor text is visible and loading chrome is gone.
Future<void> awaitGoldenReady(
  WidgetTester tester, {
  required Finder readyAnchor,
  int maxPumps = 100,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    final hasAnchor = readyAnchor.evaluate().isNotEmpty;
    final hasSpinner =
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasSkeleton =
        find.byType(ClaimDetailSkeleton).evaluate().isNotEmpty;
    if (hasAnchor && !hasSpinner && !hasSkeleton) {
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
  }
  fail(
    'Timed out after ${maxPumps * 100}ms waiting for golden ready state '
    '(anchor: $readyAnchor)',
  );
}

/// Home-hub crush flow — pushes crusher with query (mirrors production UX).
Future<void> crushFromHomeHub(
  WidgetTester tester,
  String query,
) async {
  final bar = find.byType(CrushArgumentBar);
  expect(bar, findsOneWidget);
  await tester.enterText(
    find.descendant(of: bar, matching: find.byType(TextField)),
    query,
  );
  await tester.tap(
    find.descendant(of: bar, matching: find.text('Crush It')),
  );
  await waitForFinder(
    tester,
    find.textContaining('Their Argument'),
    maxPumps: 100,
  );
  await scrollUntilVisible(tester, find.text('Why This Holds Up'), maxScrolls: 20);
}

/// Navigates to claim detail (full-screen route outside shell).
Future<void> openClaimDetail(
  WidgetTester tester,
  String claimId, {
  int maxPumps = 80,
}) async {
  final router = activeTestRouter;
  assert(router != null, 'Call pumpTestApp before openClaimDetail');
  router!.push('/claim/$claimId');
  await tester.pump();
  await waitForFinder(tester, find.text('Counter-Argument'), maxPumps: maxPumps);
}