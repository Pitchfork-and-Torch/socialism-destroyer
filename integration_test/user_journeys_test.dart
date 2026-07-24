import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/services/book_reading_service.dart';
import 'package:socialism_destroyer/themes/widgets/tree_node.dart';

import '../test/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('integration — iPhone learning loop through library note', (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.iphone14,
      initialLocation: AppRoutes.home,
    );

    await tapNavTab(tester, 'Topics');
    await tester.tap(
      find.descendant(
        of: find.byType(TreeNode),
        matching: find.text('Historical Record of Socialism'),
      ).first,
    );
    await settleJourney(tester);

    await tapNavTab(tester, 'Home');
    await crushFromHomeHub(
      tester,
      'Venezuela failed only because of sanctions',
    );

    await tapNavTab(tester, 'Library');
    await scrollUntilVisible(tester, find.text('The Law'));
    await tester.tap(find.text('The Law'));
    await settleJourney(tester, maxPumps: 50);
    await tester.tap(find.byTooltip('Book note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Integration test reading note.');
    await tester.tap(find.text('Save'));

    expect(
      BookReadingService().loadState('the-law').userNote,
      contains('Integration test'),
    );
  });

  testWidgets('integration — desktop Venezuela claim deep-dive', (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.desktop,
      initialLocation: '${AppRoutes.tree}?category=historical-socialism',
    );

    await settleJourney(tester, maxPumps: 40);
    await tester.tap(find.textContaining('Venezuela').first);
    await settleJourney(tester, maxPumps: 50);

    expect(find.text('Executive Summary'), findsOneWidget);
    expect(find.text('Sources'), findsWidgets);
  });
}