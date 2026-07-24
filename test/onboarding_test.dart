import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/core/app_initializer.dart';
import 'package:socialism_destroyer/features/auth/screens/onboarding_screen.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';
import 'package:socialism_destroyer/services/local_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initTestHive();
    final box = Hive.box(LocalStorageService.settingsBox);
    await box.delete('onboarding_complete');
  });

  testWidgets('Onboarding screen 1 shows mission statement', (tester) async {
    await tester.pumpWidget(
      testProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Discover the Engine'), findsOneWidget);
    expect(find.textContaining('Super-Based'), findsOneWidget);
    expect(find.text('Fully Sourced'), findsOneWidget);
  });

  testWidgets('Onboarding advances to features screen', (tester) async {
    await tester.pumpWidget(
      testProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discover the Engine'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Three Weapons'), findsOneWidget);
    expect(find.text('Topic Tree'), findsOneWidget);
    expect(find.text('Argument Crusher'), findsOneWidget);
  });

  testWidgets('Skip button is always visible', (tester) async {
    await tester.pumpWidget(
      testProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
  });

  test('markOnboardingComplete updates live routing flag', () async {
    expect(AppInitializer.isOnboardingComplete(), isFalse);
    await AppInitializer.markOnboardingComplete();
    expect(AppInitializer.isOnboardingComplete(), isTrue);
  });

}