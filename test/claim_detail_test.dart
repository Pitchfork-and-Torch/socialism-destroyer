import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/tree/providers/topic_tree_providers.dart';
import 'package:socialism_destroyer/features/tree/screens/claim_detail_screen.dart';
import 'package:socialism_destroyer/features/tree/services/topic_tree_index.dart';
import 'package:socialism_destroyer/features/tree/widgets/claim_section_nav.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/providers/app_providers.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TopicTreeIndex treeIndex;
  late Claim wealthClaim;
  late Claim povertyClaim;

  setUpAll(() async {
    await initTestHive();
    final knowledge = KnowledgeService();
    final topics = await knowledge.getTopics();
    final claims = await knowledge.getClaims();
    treeIndex = TopicTreeIndex(roots: topics, claims: claims);
    wealthClaim = (await knowledge.getClaimById('wealth-inequality-broken'))!;
    povertyClaim = (await knowledge.getClaimById('absolute-poverty-world-bank'))!;
  });

  Future<void> pumpClaim(WidgetTester tester, Size size, String claimId) async {
    await tester.binding.setSurfaceSize(size);
    Claim claimFor(String id) => switch (id) {
          'wealth-inequality-broken' => wealthClaim,
          'absolute-poverty-world-bank' => povertyClaim,
          _ => wealthClaim,
        };

    await tester.pumpWidget(
      testProviderScope(
        child: ProviderScope(
          overrides: [
            topicTreeIndexProvider.overrideWith((ref) async => treeIndex),
            claimProvider(claimId).overrideWith((ref) async => claimFor(claimId)),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: MediaQueryData(size: size, disableAnimations: true),
              child: ClaimDetailScreen(claimId: claimId),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  group('ClaimDetailScreen', () {
    testWidgets('mobile shows steelmanned argument before counter-argument', (tester) async {
      await pumpClaim(tester, const Size(390, 844), 'wealth-inequality-broken');
      expect(find.text('Their Argument'), findsOneWidget);
      expect(find.text('Counter-Argument'), findsOneWidget);
      expect(find.text('Why This Holds Up'), findsOneWidget);
      expect(find.text('Why This Matters for America'), findsOneWidget);

      final theirArgY = tester.getTopLeft(find.text('Their Argument')).dy;
      final counterY = tester.getTopLeft(find.text('Counter-Argument')).dy;
      expect(theirArgY, lessThan(counterY));
    });

    testWidgets('desktop split shows section nav', (tester) async {
      await pumpClaim(tester, const Size(1280, 800), 'wealth-inequality-broken');
      expect(find.text('On this page'), findsOneWidget);
      expect(find.byType(ClaimSectionNav), findsOneWidget);
    });

    testWidgets('flagship claim renders interactive chart', (tester) async {
      await pumpClaim(tester, const Size(768, 1024), 'absolute-poverty-world-bank');
      expect(
        find.textContaining('Global Extreme Poverty Rate'),
        findsOneWidget,
      );
    });

    testWidgets('fallacy callouts collapsed by default for wealth claim', (tester) async {
      await pumpClaim(tester, const Size(390, 844), 'wealth-inequality-broken');
      expect(find.text('Logical Fallacies Identified'), findsOneWidget);
      expect(find.textContaining('fallacies detected'), findsOneWidget);
      expect(find.text('Zero-Sum Fallacy'), findsNothing);
    });
  });
}