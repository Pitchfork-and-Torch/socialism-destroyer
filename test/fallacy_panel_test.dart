import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/tree/widgets/fallacy_callout_panel.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';

void main() {
  testWidgets('FallacyCalloutPanel expands on tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: FallacyCalloutPanel(
            fallacies: ['zero-sum fallacy'],
          ),
        ),
      ),
    );

    expect(find.textContaining('detected — tap to expand'), findsOneWidget);
    expect(find.text('Zero-Sum Fallacy'), findsNothing);

    await tester.tap(find.textContaining('detected — tap to expand'));
    await tester.pump();

    expect(find.text('Zero-Sum Fallacy'), findsOneWidget);
  });
}