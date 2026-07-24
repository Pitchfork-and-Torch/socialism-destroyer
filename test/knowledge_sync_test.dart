import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:socialism_destroyer/models/changelog.dart';
import 'package:socialism_destroyer/models/knowledge_manifest.dart';
import 'package:socialism_destroyer/models/knowledge_sync.dart';
import 'package:socialism_destroyer/models/knowledge_versioning.dart';
import 'package:socialism_destroyer/services/knowledge_overlay_store.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/services/knowledge_sync_service.dart';
import 'package:socialism_destroyer/services/local_storage_service.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KnowledgeVersion', () {
    test('compares semantic versions', () {
      expect(KnowledgeVersion.compare('2.1.0', '2.0.0'), greaterThan(0));
      expect(KnowledgeVersion.compare('2.0.0', '2.0.0'), 0);
      expect(KnowledgeVersion.compare('1.9.9', '2.0.0'), lessThan(0));
      expect(KnowledgeVersion.isNewer('2.1.0', '2.0.0'), isTrue);
      expect(KnowledgeVersion.isNewer('2.0.0', '2.0.0'), isFalse);
    });
  });

  group('ChangelogDocument', () {
    test('merges entries by version', () {
      final bundled = ChangelogDocument.fromJson({
        'currentVersion': '2.0.0',
        'lastUpdated': '2026-07-04',
        'entries': [
          {
            'version': '2.0.0',
            'date': '2026-07-04',
            'title': 'Bundled',
            'changes': ['A'],
          },
        ],
      });
      final remote = ChangelogDocument.fromJson({
        'currentVersion': '2.1.0',
        'lastUpdated': '2026-10-01',
        'entries': [
          {
            'version': '2.1.0',
            'date': '2026-10-01',
            'title': 'Remote drop',
            'changes': ['B'],
          },
        ],
      });
      final merged = bundled.merge(remote);
      expect(merged.currentVersion, '2.1.0');
      expect(merged.entries.length, 2);
      expect(merged.entries.first.version, '2.1.0');
    });
  });

  group('KnowledgeOverlayStore', () {
    late Directory tempDir;
    late KnowledgeOverlayStore overlay;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('sd_overlay_test');
      overlay = KnowledgeOverlayStore(rootOverride: tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('writes and reads overlay assets', () async {
      const assetPath = 'assets/data/v2/topics.json';
      const payload = '{"topics":[]}';
      await overlay.writeAsset(assetPath, payload);

      expect(await overlay.hasOverlayAsset(assetPath), isTrue);
      expect(await overlay.readOverlayAsset(assetPath), payload);
    });

    test('persists sync state', () async {
      const state = KnowledgeSyncState(
        bundledKbVersion: '2.0.0',
        overlayKbVersion: '2.1.0',
        lastSyncedAt: '2026-07-04T12:00:00Z',
      );
      await overlay.saveSyncState(state);
      final loaded = await overlay.loadSyncState();
      expect(loaded.overlayKbVersion, '2.1.0');
      expect(loaded.effectiveKbVersion, '2.1.0');
    });
  });

  group('KnowledgeService overlay', () {
    late Directory tempDir;
    late KnowledgeOverlayStore overlay;
    late KnowledgeService service;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('sd_kb_overlay_test');
      overlay = KnowledgeOverlayStore(rootOverride: tempDir.path);
      service = KnowledgeService(overlayStore: overlay);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('prefers overlay manifest when present', () async {
      final bundled = await service.getBundledManifest();
      final overlayManifest = KnowledgeManifest(
        meta: KnowledgeDocumentMeta(
          schemaVersion: bundled.meta.schemaVersion,
          kbVersion: '9.9.9',
          updatedAt: bundled.meta.updatedAt,
          contentHash: bundled.meta.contentHash,
        ),
        topicsAsset: bundled.topicsAsset,
        claimBundles: bundled.claimBundles,
        booksAsset: bundled.booksAsset,
      );
      await overlay.writeManifest(overlayManifest);

      await service.reload();
      final manifest = await service.getManifest();
      expect(manifest.meta.kbVersion, '9.9.9');
    });
  });

  group('KnowledgeSyncService', () {
    setUpAll(() async {
      await initTestHive();
    });

    test('auto sync on launch defaults to true', () async {
      final sync = KnowledgeSyncService();
      expect(sync.autoSyncOnLaunch, isTrue);
      await sync.setAutoSyncOnLaunch(false);
      expect(sync.autoSyncOnLaunch, isFalse);
      await Hive.box(LocalStorageService.settingsBox)
          .put(KnowledgeSyncService.autoSyncOnLaunchKey, true);
    });

    test('check without CDN returns notConfigured', () async {
      final sync = KnowledgeSyncService(cdnUrlOverride: '');
      final result = await sync.checkForUpdates();
      expect(result.availability, UpdateAvailability.notConfigured);
    });

    test('uses production CDN when env is unset', () {
      final sync = KnowledgeSyncService();
      expect(sync.cdnBaseUrl, isNotNull);
      expect(sync.cdnBaseUrl, contains('destroyer.jonbailey.xyz'));
    });

    test('loads bundled changelog', () async {
      final sync = KnowledgeSyncService();
      final changelog = await sync.getChangelog();
      expect(changelog.currentVersion, '3.8.0');
      expect(changelog.entries.any((e) => e.version == '2.0.0'), isTrue);
    });
  });
}