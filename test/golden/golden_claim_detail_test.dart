import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/core/app_initializer.dart';
import 'package:socialism_destroyer/features/library/providers/library_providers.dart';
import 'package:socialism_destroyer/features/tree/screens/claim_detail_screen.dart';
import 'package:socialism_destroyer/providers/app_providers.dart';
import 'package:socialism_destroyer/services/claim_reading_service.dart';
import '../test_helpers.dart';

/// Isolated golden — batched with other goldens this capture can hang (scrollUntilVisible).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  testWidgets('golden — claim detail library reading panel', (tester) async {
    final bundle = await TestKnowledgeBundle.load();
    final claim = bundle.claimById('profit-is-theft');
    final readingLinks =
        await ClaimReadingService().linksForClaim('profit-is-theft');

    await tester.binding.setSurfaceSize(TestDevices.desktop);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootstrapProvider.overrideWithValue(
            const AppBootstrap(onboardingComplete: true),
          ),
          ...defaultJourneyOverrides(bundle),
          claimProvider('profit-is-theft').overrideWith((ref) async => claim),
          claimReadingLinksProvider('profit-is-theft')
              .overrideWith((ref) async => readingLinks),
        ],
        child: MaterialApp(
          theme: journeyTestTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: TestDevices.desktop,
              disableAnimations: true,
              platformBrightness: Brightness.dark,
            ),
            child: const ClaimDetailScreen(claimId: 'profit-is-theft'),
          ),
        ),
      ),
    );
    await waitForFinder(tester, find.text('On this page'), maxPumps: 80);
    await tester.tap(find.text('Library Reading'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await waitForFinder(
      tester,
      find.text('Read Next'),
      maxPumps: 40,
    );
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
      find.byType(ClaimDetailScreen),
      matchesGoldenFile('golden/goldens/claim_library_reading_desktop.png'),
    );
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}