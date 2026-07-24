import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:socialism_destroyer/models/knowledge_manifest.dart';
import 'package:socialism_destroyer/models/knowledge_sync.dart';
import 'package:socialism_destroyer/services/knowledge_overlay_store.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/services/knowledge_sync_service.dart';
import 'package:socialism_destroyer/utils/app_constants.dart';

import 'test_helpers.dart';

String _remoteHash(String kbVersion, String assetPath) {
  final normalized = assetPath.startsWith('assets/')
      ? assetPath.substring('assets/'.length)
      : assetPath;
  return 'sha256:remote-$kbVersion-$normalized';
}

/// Integration tests for CDN delta sync with a mock HTTP client.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Knowledge sync integration', () {
    late Directory tempDir;
    late KnowledgeOverlayStore overlay;
    late KnowledgeService knowledge;
    late KnowledgeManifest bundledManifest;
    late List<String> allAssets;

    setUpAll(() async {
      await initTestHive();
      initTestDatabase();
      final raw = await rootBundle
          .loadString(AppConstants.knowledgeManifestAsset);
      bundledManifest =
          KnowledgeManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      allAssets = [
        bundledManifest.topicsAsset,
        if (bundledManifest.booksAsset != null) bundledManifest.booksAsset!,
        ...bundledManifest.claimBundles.map((b) => b.asset),
      ];
    });

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('sd_sync_int');
      overlay = KnowledgeOverlayStore(rootOverride: tempDir.path);
      knowledge = KnowledgeService(overlayStore: overlay);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    http.Client buildMockCdn({
      required String remoteKbVersion,
      required String remoteManifestHash,
    }) {
      final remoteManifest = {
        'schemaVersion': bundledManifest.meta.schemaVersion,
        'kbVersion': remoteKbVersion,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'contentHash': remoteManifestHash,
        'topicsAsset': bundledManifest.topicsAsset,
        if (bundledManifest.booksAsset != null)
          'booksAsset': bundledManifest.booksAsset,
        'claimBundles': bundledManifest.claimBundles
            .map((b) => {
                  'id': b.id,
                  'asset': b.asset,
                  'priority': b.priority,
                })
            .toList(),
      };

      final remoteChangelog = {
        'currentVersion': remoteKbVersion,
        'lastUpdated': '2026-10-01',
        'entries': [
          {
            'version': remoteKbVersion,
            'date': '2026-10-01',
            'title': 'CBO 2026 wage study drop',
            'changes': [
              'Updated minimum-wage evidence with latest CBO scoring',
            ],
          },
        ],
      };

      return MockClient((request) async {
        final url = request.url.toString();
        const cdn = 'https://cdn.test';

        if (url == '$cdn/data/v2/knowledge_manifest.json') {
          return http.Response(jsonEncode(remoteManifest), 200);
        }
        if (url == '$cdn/data/changelog.json') {
          return http.Response(jsonEncode(remoteChangelog), 200);
        }

        for (final asset in allAssets) {
          final normalized = asset.startsWith('assets/')
              ? asset.substring('assets/'.length)
              : asset;
          final assetUrl = '$cdn/$normalized';
          final hashUrl = '$assetUrl.sha256';

          if (url == hashUrl) {
            return http.Response(_remoteHash(remoteKbVersion, asset), 200);
          }
          if (url == assetUrl) {
            final body = await rootBundle.loadString(asset);
            return http.Response(body, 200);
          }
        }

        return http.Response('not found', 404);
      });
    }

    Future<void> seedMatchingHashes(String kbVersion) async {
      final hashes = <String, String>{
        for (final asset in allAssets) asset: _remoteHash(kbVersion, asset),
      };
      await overlay.saveAssetHashes(hashes);
    }

    KnowledgeSyncService buildSyncService({
      required http.Client client,
      bool online = true,
    }) =>
        KnowledgeSyncService(
          overlayStore: overlay,
          knowledgeService: knowledge,
          httpClient: client,
          cdnUrlOverride: 'https://cdn.test',
          onlineOverride: () => online,
        );

    test('check detects remote kbVersion newer than bundled', () async {
      final sync = buildSyncService(
        client: buildMockCdn(
          remoteKbVersion: '3.5.0',
          remoteManifestHash: 'sha256:remote-manifest-280',
        ),
      );

      final check = await sync.checkForUpdates();
      expect(check.availability, UpdateAvailability.updateAvailable);
      expect(check.remoteMeta?.kbVersion, '3.5.0');
      expect(check.message, contains('3.5.0'));
    });

    test('syncLatest updates manifest when asset hashes already match', () async {
      await seedMatchingHashes('3.5.0');
      final sync = buildSyncService(
        client: buildMockCdn(
          remoteKbVersion: '3.5.0',
          remoteManifestHash: 'sha256:remote-manifest-280',
        ),
      );

      final result = await sync.syncLatest();
      expect(result.success, isTrue, reason: result.message);
      expect(result.newKbVersion, '3.5.0');

      final after = await sync.getLocalStatus();
      expect(after.effectiveKbVersion, '3.5.0');
      expect(after.lastSyncedAt, isNotNull);
      expect(await overlay.hasOverlayManifest(), isTrue);

      final changelog = await sync.getChangelog();
      expect(changelog.entries.any((e) => e.version == '3.5.0'), isTrue);
    });

    test('remote manifest preserves bundled asset paths', () async {
      final client = buildMockCdn(
        remoteKbVersion: '3.5.0',
        remoteManifestHash: 'sha256:remote-manifest-280',
      );
      final response = await client.get(
        Uri.parse('https://cdn.test/data/v2/knowledge_manifest.json'),
      );
      final manifest = KnowledgeManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      expect(manifest.topicsAsset, startsWith('assets/'));
      for (final bundle in manifest.claimBundles) {
        expect(bundle.asset, startsWith('assets/'));
      }
    });

    test('overlay writeAsset stores downloaded bundle bytes', () async {
      final body = await rootBundle.loadString(bundledManifest.topicsAsset);
      await overlay.writeAsset(bundledManifest.topicsAsset, body);
      expect(await overlay.hasOverlayAsset(bundledManifest.topicsAsset), isTrue);
      final read = await overlay.readOverlayAsset(bundledManifest.topicsAsset);
      expect(read, body);
    });

    test('offline check does not block bundled knowledge', () async {
      final sync = buildSyncService(
        client: buildMockCdn(
          remoteKbVersion: '3.5.0',
          remoteManifestHash: 'sha256:remote-manifest-280',
        ),
        online: false,
      );

      final check = await sync.checkForUpdates();
      expect(check.availability, UpdateAvailability.offline);

      final claims = await knowledge.getClaims();
      expect(claims.length, greaterThanOrEqualTo(AppConstants.minClaimsTarget));
    });

    test('failed sync leaves bundled content usable', () async {
      final brokenClient = MockClient((request) async {
        if (request.url.path.endsWith('knowledge_manifest.json')) {
          return http.Response('not-json', 200);
        }
        return http.Response('error', 500);
      });

      final sync = KnowledgeSyncService(
        overlayStore: overlay,
        knowledgeService: knowledge,
        httpClient: brokenClient,
        cdnUrlOverride: 'https://cdn.test',
        onlineOverride: () => true,
      );

      final result = await sync.syncLatest();
      expect(result.success, isFalse);

      final claims = await knowledge.getClaims();
      expect(claims, isNotEmpty);
    });

    test('autoCheckOnLaunch syncs when update available', () async {
      await seedMatchingHashes('3.5.0');
      final sync = buildSyncService(
        client: buildMockCdn(
          remoteKbVersion: '3.5.0',
          remoteManifestHash: 'sha256:remote-manifest-280',
        ),
      );
      await sync.setAutoSyncOnLaunch(true);

      await sync.autoCheckOnLaunch();

      final status = await sync.getLocalStatus();
      expect(status.effectiveKbVersion, '3.5.0');
    });
  });
}