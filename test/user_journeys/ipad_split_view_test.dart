import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/features/tree/widgets/topic_claims_panel.dart';

import '../test_helpers.dart';

/// iPad user browses topic tree in split-view: tree left, claims right.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('iPad portrait shows split pane after selecting Historical Socialism',
      (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.ipadPortrait,
      initialLocation: AppRoutes.tree,
    );

    expect(find.text('Select a topic'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Historical Record of Socialism'));
    await settleJourney(tester);

    expect(find.byType(TopicClaimsPanel), findsOneWidget);
    expect(find.textContaining('Venezuela'), findsWidgets);
    expect(find.textContaining('claim'), findsWidgets);
  });

  testWidgets('iPad landscape keeps tree and claims visible side by side',
      (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.ipadLandscape,
      initialLocation: '${AppRoutes.tree}?category=historical-socialism',
    );

    await settleJourney(tester, maxPumps: 40);
    expect(find.byType(TopicClaimsPanel), findsOneWidget);
    expect(find.text('Historical Record of Socialism'), findsWidgets);
  });
}