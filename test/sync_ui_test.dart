import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/sync/providers/knowledge_sync_providers.dart';
import 'package:socialism_destroyer/features/sync/widgets/changelog_sheet.dart';
import 'package:socialism_destroyer/features/sync/widgets/sync_intelligence_panel.dart';
import 'package:socialism_destroyer/models/changelog.dart';
import 'package:socialism_destroyer/models/knowledge_sync.dart';
import 'package:socialism_destroyer/themes/app_theme.dart';
import 'package:socialism_destroyer/utils/app_constants.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initTestHive();
  });

  Future<void> pumpPanel(
    WidgetTester tester, {
    KnowledgeSyncState? status,
    ChangelogDocument? changelog,
    Size size = const Size(800, 900),
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          knowledgeSyncStateProvider.overrideWith(
            (ref) async =>
                status ??
                const KnowledgeSyncState(
                  bundledKbVersion: AppConstants.knowledgeBaseVersion,
                ),
          ),
          if (changelog != null)
            changelogProvider.overrideWith((ref) async => changelog),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: const Scaffold(body: SyncIntelligencePanel()),
          ),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('SyncIntelligencePanel UI', () {
    testWidgets('shows prominent sync button and auto-check toggle', (tester) async {
      await pumpPanel(tester);
      expect(find.text('Sync Latest Intelligence'), findsWidgets);
      expect(find.text('Auto-check on launch'), findsOneWidget);
      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('Offline? Bundled intelligence remains fully available.'),
          findsOneWidget);
    });

    testWidgets('highlights update badge when remote is newer', (tester) async {
      await pumpPanel(
        tester,
        size: const Size(800, 1000),
        status: const KnowledgeSyncState(
          bundledKbVersion: '2.2.0',
          remoteKbVersion: '2.3.0',
        ),
      );
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('v2.3.0'), findsOneWidget);
    });

    testWidgets('changelog sheet lists version entries', (tester) async {
      await pumpPanel(
        tester,
        status: const KnowledgeSyncState(bundledKbVersion: '2.2.0'),
        changelog: ChangelogDocument(
          currentVersion: '2.2.0',
          lastUpdated: '2026-07-04',
          entries: const [
            ChangelogEntry(
              version: '2.2.0',
              date: '2026-07-04',
              title: 'Test release',
              changes: ['New claim pack'],
            ),
          ],
        ),
      );

      await tester.tap(find.text('Changelog'));
      await tester.pumpAndSettle();

      expect(find.byType(ChangelogSheet), findsOneWidget);
      expect(find.text('Intelligence Changelog'), findsOneWidget);
      expect(find.text('Test release'), findsOneWidget);
      expect(find.text('New claim pack'), findsOneWidget);
    });
  });
}