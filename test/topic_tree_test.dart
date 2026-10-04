import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/tree/providers/topic_tree_providers.dart';
import 'package:socialism_destroyer/features/tree/screens/topic_tree_screen.dart';
import 'package:socialism_destroyer/features/tree/services/topic_tree_index.dart';
import 'package:socialism_destroyer/themes/widgets/tree_node.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TopicTreeIndex', () {
    test('loads 11 top-level categories', () async {
      final knowledge = KnowledgeService();
      final topics = await knowledge.getTopics();
      final claims = await knowledge.getClaims();
      final index = TopicTreeIndex(roots: topics, claims: claims);
      expect(index.topLevelCount, 11);
    });

    test('curated v2 seeds include 15 flagship claims across 3 categories', () async {
      final knowledge = KnowledgeService();
      final topics = await knowledge.getTopics();
      final claims = await knowledge.getClaims();
      final index = TopicTreeIndex(roots: topics, claims: claims);

      final wealth = index.claimsFor(
        topics.firstWhere((t) => t.id == 'wealth-inequality-mobility'),
      );
      final historical = index.claimsFor(
        topics.firstWhere((t) => t.id == 'historical-socialism'),
      );
      final nordic = index.claimsFor(
        topics.firstWhere((t) => t.id == 'nordic-democratic-socialism'),
      );

      expect(wealth.length, greaterThanOrEqualTo(5));
      expect(historical.length, greaterThanOrEqualTo(5));
      expect(nordic.length, greaterThanOrEqualTo(5));

      final ussr = claims.firstWhere((c) => c.id == 'ussr-not-real-socialism');
      expect(ussr.schemaVersion, 2);
      expect(ussr.sources.length, greaterThanOrEqualTo(3));
    });

    test('search filter matches claim titles', () async {
      final knowledge = KnowledgeService();
      final topics = await knowledge.getTopics();
      final claims = await knowledge.getClaims();
      final index = TopicTreeIndex(roots: topics, claims: claims);

      final nordic = topics.firstWhere((t) => t.id == 'nordic-democratic-socialism');
      expect(index.matchesFilter(nordic, 'Sweden'), isTrue);
      expect(index.matchesFilter(nordic, 'xyznonexistent'), isFalse);
    });
  });

  group('TopicTreeScreen layout', () {
    late TopicTreeIndex treeIndex;

    setUpAll(() async {
      await initTestHive();
    });

    setUp(() async {
      final knowledge = KnowledgeService();
      treeIndex = TopicTreeIndex(
        roots: await knowledge.getTopics(),
        claims: await knowledge.getClaims(),
      );
    });

    Future<void> pumpTree(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topicTreeIndexProvider.overrideWith((ref) async => treeIndex),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                disableAnimations: true,
              ),
              child: const TopicTreeScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await settleJourney(tester, maxPumps: 50);
      await waitForFinder(tester, find.text('Topic Tree'), maxPumps: 50);
    }

    testWidgets('renders 11 categories on mobile', (tester) async {
      await pumpTree(tester, const Size(390, 844));
      expect(treeIndex.topLevelCount, 11);
      expect(find.text('Topic Tree'), findsOneWidget);
      expect(find.byType(TreeNode), findsWidgets);
      expect(find.text('Historical Record of Socialism'), findsOneWidget);
      expect(find.text('The Nordic Model Myth & "Democratic Socialism"'), findsOneWidget);
      expect(find.text('Search topics & claims…'), findsOneWidget);
    });

    testWidgets('search filters visible topics', (tester) async {
      await pumpTree(tester, const Size(390, 844));
      await tester.enterText(find.byType(TextField), 'venezuela');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Historical Record of Socialism'), findsOneWidget);
    });

    testWidgets('desktop split pane shows claims panel placeholder', (tester) async {
      await pumpTree(tester, const Size(1280, 800));
      expect(treeIndex.topLevelCount, 11);
      expect(find.text('Select a topic'), findsOneWidget);
      expect(find.byType(TreeNode), findsWidgets);
    });

    testWidgets('expanding topic shows claims', (tester) async {
      await pumpTree(tester, const Size(390, 844));
      final wealthNode = find.descendant(
        of: find.byType(TreeNode),
        matching: find.text('Wealth Inequality & Mobility'),
      );
      await tester.tap(wealthNode.first);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('claim'), findsWidgets);
    });
  });
}