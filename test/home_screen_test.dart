import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:socialism_destroyer/features/home/screens/home_screen.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/features/shared/widgets/app_shell.dart';
import 'package:socialism_destroyer/features/shared/widgets/compact_bottom_chrome.dart';
import 'package:socialism_destroyer/features/tree/services/topic_tree_index.dart';
import 'package:socialism_destroyer/features/tree/providers/topic_tree_providers.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TopicTreeIndex treeIndex;

  setUpAll(() async {
    await initTestHive();
    final knowledge = KnowledgeService();
    treeIndex = TopicTreeIndex(
      roots: await knowledge.getTopics(),
      claims: await knowledge.getClaims(),
    );
  });

  Future<void> pumpHome(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    final router = GoRouter(
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
              builder: (context, state) => const SizedBox(key: Key('tree')),
            ),
            GoRoute(
              path: AppRoutes.crusher,
              builder: (context, state) => const SizedBox(key: Key('crusher')),
            ),
            GoRoute(
              path: AppRoutes.library,
              builder: (context, state) => const SizedBox(key: Key('library')),
            ),
          ],
        ),
      ],
      initialLocation: AppRoutes.home,
    );

    await tester.pumpWidget(
      testProviderScope(
        child: ProviderScope(
          overrides: [
            topicTreeIndexProvider.overrideWith((ref) async => treeIndex),
          ],
          child: MaterialApp.router(
            theme: AppTheme.dark,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQueryData(
                size: size,
                disableAnimations: true,
              ),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('HomeScreen hub', () {
    testWidgets('mobile shows crush bar, insight, and bottom nav', (tester) async {
      await pumpHome(tester, const Size(390, 844));
      expect(find.text('Crush Any Argument'), findsOneWidget);
      expect(find.text("Today's Based Insight"), findsOneWidget);
      expect(find.byType(CompactBottomChrome), findsOneWidget);
      expect(find.text('Wealth & Mobility'), findsOneWidget);
    });

    testWidgets('tablet shows crush bar and bottom nav', (tester) async {
      await pumpHome(tester, const Size(768, 1024));
      expect(find.text('Crush Any Argument'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Help us grow the arsenal'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Help us grow the arsenal'), findsOneWidget);
    });

    testWidgets('desktop shows navigation rail', (tester) async {
      await pumpHome(tester, const Size(1280, 800));
      expect(find.text('Crush Any Argument'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Topics'), findsOneWidget);
    });

    testWidgets('quick category chips are tappable', (tester) async {
      await pumpHome(tester, const Size(390, 844));
      expect(find.text('Wealth & Mobility'), findsOneWidget);
      await tester.tap(find.text('Wealth & Mobility'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('crush input navigates on submit', (tester) async {
      await pumpHome(tester, const Size(390, 844));
      await tester.enterText(
        find.byType(TextField),
        'democratic socialism works in Sweden',
      );
      await tester.tap(find.text('Crush It'));
      await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('crusher')), findsOneWidget);
    });
  });
}