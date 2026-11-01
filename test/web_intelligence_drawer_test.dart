import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/home/widgets/home_intelligence_section.dart';
import 'package:socialism_destroyer/features/sync/providers/knowledge_sync_providers.dart';
import 'package:socialism_destroyer/features/sync/widgets/sync_intelligence_panel.dart';
import 'package:socialism_destroyer/models/changelog.dart';
import 'package:socialism_destroyer/models/knowledge_sync.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';
import 'package:socialism_destroyer/utils/app_constants.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestEnvironment();
  });

  Future<void> pumpFooter(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          knowledgeSyncStateProvider.overrideWith(
            (ref) async => const KnowledgeSyncState(
              bundledKbVersion: AppConstants.knowledgeBaseVersion,
            ),
          ),
          changelogProvider.overrideWith(
            (ref) async => ChangelogDocument(
              currentVersion: AppConstants.knowledgeBaseVersion,
              lastUpdated: '2026-07-05',
              entries: const [
                ChangelogEntry(
                  version: '2.7.0',
                  date: '2026-07-05',
                  title: 'Test release',
                  changes: ['Sample changelog entry'],
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: HomeIntelligenceSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('collapsed drawer does not mount sync panel', (tester) async {
    await pumpFooter(tester);
    expect(find.text('Intelligence updates'), findsOneWidget);
    expect(find.byType(SyncIntelligencePanel), findsNothing);
  });

  testWidgets('expand arrow toggles sync panel', (tester) async {
    await pumpFooter(tester);
    await tester.tap(find.byTooltip('Expand'));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(SyncIntelligencePanel), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse'));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(SyncIntelligencePanel), findsNothing);
  });

  testWidgets('title tap expands and collapse hides sync panel', (tester) async {
    await pumpFooter(tester);
    await tester.tap(find.text('Intelligence updates'));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(SyncIntelligencePanel), findsOneWidget);
    expect(find.text('Sync Intelligence'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse'));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(SyncIntelligencePanel), findsNothing);
  });

  testWidgets('dismiss hides drawer and restore brings it back', (tester) async {
    await pumpFooter(tester);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.text('Intelligence updates'), findsNothing);
    expect(find.text('Show intelligence updates'), findsOneWidget);

    await tester.tap(find.text('Show intelligence updates'));
    await tester.pump();
    expect(find.text('Intelligence updates'), findsOneWidget);
  });
}