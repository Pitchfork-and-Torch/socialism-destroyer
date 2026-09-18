import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/tree/data/fallacy_catalog.dart';
import 'package:socialism_destroyer/features/tree/widgets/fallacy_callout_panel.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';

void main() {
  test('FallacyCatalog resolves crusher fallacies used in claims', () {
    expect(FallacyCatalog.resolve('nirvana fallacy')?.label, 'Nirvana Fallacy');
    expect(
      FallacyCatalog.resolve('single-cause fallacy')?.label,
      'Single-Cause Fallacy',
    );
    // Must not fall through to the generic placeholder description.
    expect(
      FallacyCatalog.resolve('nirvana fallacy')!.description,
      isNot(contains('common rhetorical move')),
    );
    expect(
      FallacyCatalog.resolve('single-cause fallacy')!.description,
      isNot(contains('common rhetorical move')),
    );
  });

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

    expect(find.textContaining('detected  -  tap to expand'), findsOneWidget);
    expect(find.text('Zero-Sum Fallacy'), findsNothing);

    await tester.tap(find.textContaining('detected  -  tap to expand'));
    await tester.pump();

    expect(find.text('Zero-Sum Fallacy'), findsOneWidget);
  });
}
