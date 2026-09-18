import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/features/library/providers/library_providers.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';

import 'package:socialism_destroyer/themes/widgets/tree_node.dart';

import '../fakes/test_book_offline_service.dart';
import '../test_helpers.dart';

/// iPhone new user: home → topic tree → crush argument → read PD book.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  tearDownAll(restoreTestErrorHandlers);

  testWidgets('iPhone user completes full learning loop without sign-in',
      (tester) async {
    final bundle = await TestKnowledgeBundle.load();
    final law = bundle.books.firstWhere((b) => b.id == 'the-law');
    const sampleLawContent = '''
# The Law

*By Frédéric Bastiat*

## The Law Perverted

The law perverted! And the police powers of the state perverted along with it!
''';

    await pumpTestApp(
      tester,
      size: TestDevices.iphone14,
      initialLocation: AppRoutes.home,
      platform: TargetPlatform.iOS,
      overrides: [
        bookProvider('the-law').overrideWith((ref) async => law),
        bookContentProvider('the-law').overrideWith((ref) async => sampleLawContent),
        bookOfflineServiceProvider.overrideWith((_) => TestBookOfflineService()),
      ],
    );

    expect(find.text('Crush Any Argument'), findsOneWidget);

    await tapNavTab(tester, 'Topics');
    expect(find.text('Topic Tree'), findsOneWidget);
    expect(find.byType(TreeNode), findsWidgets);

    final historical = find.descendant(
      of: find.byType(TreeNode),
      matching: find.text('Historical Record of Socialism'),
    );
    await tester.tap(historical.first);
    await settleJourney(tester);
    expect(find.textContaining('claim'), findsWidgets);

    await tapNavTab(tester, 'Home');
    await crushFromHomeHub(
      tester,
      'capitalism exploits the working class',
    );
    expect(find.textContaining('Counter-Argument'), findsOneWidget);

    await tapNavTab(tester, 'Library');
    await waitForFinder(tester, find.byType(Scrollable), maxPumps: 40);
    final libraryScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('The Law'),
      200,
      scrollable: libraryScrollable,
    );
    expect(find.text('The Law'), findsWidgets);
    activeTestRouter!.push('/library/read/the-law');
    await settleJourney(tester, maxPumps: 40);

    expect(find.byTooltip('Book note'), findsOneWidget);
    expect(find.byTooltip('Highlights'), findsOneWidget);

    expect(find.textContaining('The Law'), findsWidgets);
    debugDefaultTargetPlatformOverride = null;
  });
}