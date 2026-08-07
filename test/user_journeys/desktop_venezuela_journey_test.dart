import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/features/tree/widgets/claim_section_nav.dart';
import 'package:socialism_destroyer/features/tree/widgets/topic_claims_panel.dart';
import 'package:socialism_destroyer/providers/app_providers.dart';

import '../test_helpers.dart';

/// Desktop power user deep-dives Venezuela economic collapse evidence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('desktop user researches Venezuela collapse via tree and claim detail',
      (tester) async {
    final bundle = await TestKnowledgeBundle.load();
    await pumpTestApp(
      tester,
      size: TestDevices.desktop,
      initialLocation: '${AppRoutes.tree}?category=historical-socialism',
      overrides: [
        claimProvider('venezuela-sanctions').overrideWith(
          (ref) async => bundle.claimById('venezuela-sanctions'),
        ),
      ],
    );

    await waitForFinder(tester, find.byType(NavigationRail), maxPumps: 40);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(TopicClaimsPanel), findsOneWidget);
    expect(find.textContaining('Venezuela'), findsWidgets);

    await tester.tap(find.textContaining('Venezuela Failed').first);
    await waitForFinder(tester, find.text('Counter-Argument'), maxPumps: 80);
    await scrollUntilVisible(tester, find.text('Why This Holds Up'), maxScrolls: 25);

    expect(find.text('Counter-Argument'), findsWidgets);
    expect(find.text('Why This Holds Up'), findsWidgets);
    expect(find.text('On this page'), findsOneWidget);
    expect(find.byType(ClaimSectionNav), findsOneWidget);
    expect(find.textContaining('hyperinflation'), findsWidgets);

    expect(bundle.claimById('venezuela-sanctions').sources.length,
        greaterThanOrEqualTo(2));
  });
}