import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socialism_destroyer/features/auth/screens/onboarding_screen.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';
import 'test_helpers.dart';

void main() {
  testWidgets('OnboardingScreen shows mission and continue button', (tester) async {
    await tester.binding.setSurfaceSize(TestDevices.iphone14);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      testProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
            data: const MediaQueryData(size: TestDevices.iphone14),
            child: const OnboardingScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Discover the Engine'), findsOneWidget);
    expect(find.textContaining('Super-Based'), findsOneWidget);
  });
}