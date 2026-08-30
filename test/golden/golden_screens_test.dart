import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/features/auth/screens/onboarding_screen.dart';
import 'package:socialism_destroyer/features/shared/router/app_router.dart';
import 'package:socialism_destroyer/features/shared/widgets/app_shell.dart';
import 'package:socialism_destroyer/features/tree/widgets/topic_claims_panel.dart';
import '../test_helpers.dart';

/// Golden snapshots for core screens at phone and desktop widths.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('golden — home iPhone', (tester) async {
    await pumpTestApp(tester, size: TestDevices.iphone14);
    await awaitGoldenReady(
      tester,
      readyAnchor: find.text('Crush Any Argument'),
    );
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('golden/goldens/home_iphone.png'),
    );
  });

  testWidgets('golden — topic tree desktop split', (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.desktop,
      initialLocation: '${AppRoutes.tree}?category=historical-socialism',
    );
    await waitForFinder(tester, find.byType(NavigationRail), maxPumps: 60);
    await waitForFinder(tester, find.byType(TopicClaimsPanel), maxPumps: 60);
    await awaitGoldenReady(
      tester,
      readyAnchor: find.textContaining('Venezuela'),
    );
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('golden/goldens/topic_tree_desktop.png'),
    );
  });

  testWidgets('golden — argument crusher with query', (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.iphone14,
      initialLocation:
          '${AppRoutes.crusher}?q=${Uri.encodeComponent('capitalism exploits the working class')}',
    );
    await awaitGoldenReady(
      tester,
      readyAnchor: find.textContaining('Their Argument'),
      maxPumps: 120,
    );
    await scrollUntilVisible(
      tester,
      find.textContaining('Read in the Library'),
      maxScrolls: 30,
    );
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('golden/goldens/crusher_iphone.png'),
    );
  });

  testWidgets('golden — onboarding iPhone', (tester) async {
    await tester.binding.setSurfaceSize(TestDevices.iphone14);
    await tester.pumpWidget(
      testProviderScope(
        child: MaterialApp(
          theme: journeyTestTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: TestDevices.iphone14,
              disableAnimations: true,
              platformBrightness: Brightness.dark,
            ),
            child: const OnboardingScreen(),
          ),
        ),
      ),
    );
    await waitForFinder(
      tester,
      find.textContaining('Your Super-Based'),
      maxPumps: 40,
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('golden/goldens/onboarding_iphone.png'),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('golden — library catalog iPhone', (tester) async {
    await pumpTestApp(
      tester,
      size: TestDevices.iphone14,
      initialLocation: AppRoutes.library,
    );
    await awaitGoldenReady(
      tester,
      readyAnchor: find.textContaining('bundled offline'),
    );
    final libraryScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('The Law'),
      200,
      scrollable: libraryScrollable,
    );
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('golden/goldens/library_catalog_iphone.png'),
    );
  });

  testWidgets('golden — library reader desktop night', (tester) async {
    final bundle = await TestKnowledgeBundle.load();
    await pumpTestApp(
      tester,
      size: TestDevices.desktop,
      initialLocation: '${AppRoutes.library}/read/the-law',
      overrides: goldenLibraryReaderOverrides(bundle),
    );
    await awaitGoldenReady(
      tester,
      readyAnchor: find.text('Contents'),
      maxPumps: 80,
    );
    await waitForFinder(
      tester,
      find.textContaining('The Law Perverted'),
      maxPumps: 40,
    );
    await expectLater(
      find.byType(AppShell),
      matchesGoldenFile('golden/goldens/library_reader_desktop.png'),
    );
  });

}