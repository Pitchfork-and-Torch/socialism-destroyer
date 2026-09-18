import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/changelog.dart';
import '../models/knowledge_manifest.dart';
import '../models/knowledge_sync.dart';
import '../utils/app_constants.dart';
import 'database_service.dart';
import 'knowledge_overlay_store.dart';
import 'knowledge_service.dart';
import 'local_storage_service.dart';

/// Delta sync for versioned knowledge-base content from a CDN / Supabase bucket.
class KnowledgeSyncService {
  KnowledgeSyncService({
    KnowledgeOverlayStore? overlayStore,
    KnowledgeService? knowledgeService,
    http.Client? httpClient,
    Connectivity? connectivity,
    this._cdnUrlOverride,
    this._onlineOverride,
  })  : _overlay = overlayStore ?? KnowledgeOverlayStore(),
        _knowledge = knowledgeService ?? KnowledgeService(),
        _http = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  final KnowledgeOverlayStore _overlay;
  final KnowledgeService _knowledge;
  final http.Client _http;
  final Connectivity _connectivity;
  final String? _cdnUrlOverride;
  final bool Function()? _onlineOverride;

  static const String autoSyncOnLaunchKey = 'auto_sync_on_launch';
  static const Duration _httpTimeout = Duration(seconds: 20);

  String? get cdnBaseUrl {
    final override = _cdnUrlOverride;
    if (override != null) {
      if (override.isEmpty) return null;
      return _normalizeCdnUrl(override);
    }
    final fromEnv = _cdnUrlFromEnv();
    if (fromEnv != null) return fromEnv;
    return _normalizeCdnUrl(AppConstants.defaultKnowledgeCdnUrl);
  }

  String? _cdnUrlFromEnv() {
    try {
      final url = dotenv.env['KNOWLEDGE_CDN_URL'];
      if (url == null || url.isEmpty || url.contains('your-cdn')) return null;
      return _normalizeCdnUrl(url);
    } catch (_) {
      return null;
    }
  }

  static String _normalizeCdnUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  bool get autoSyncOnLaunch {
    final box = Hive.box(LocalStorageService.settingsBox);
    return box.get(autoSyncOnLaunchKey, defaultValue: true) as bool;
  }

  Future<void> setAutoSyncOnLaunch(bool enabled) async {
    final box = Hive.box(LocalStorageService.settingsBox);
    await box.put(autoSyncOnLaunchKey, enabled);
  }

  Future<KnowledgeSyncState> getLocalStatus() async {
    final state = await _overlay.loadSyncState();
    final overlayManifest = await _overlay.loadOverlayManifest();
    if (overlayManifest != null) {
      return state.copyWith(
        overlayKbVersion: overlayManifest.meta.kbVersion,
        overlayContentHash: overlayManifest.meta.contentHash,
      );
    }
    return state;
  }

  Future<ChangelogDocument> getChangelog() async {
    final bundledRaw =
        await rootBundle.loadString(AppConstants.changelogAsset);
    final bundled = ChangelogDocument.fromJson(
      jsonDecode(bundledRaw) as Map<String, dynamic>,
    );
    final overlay = await _overlay.loadOverlayChangelog();
    if (overlay == null) return bundled;
    return bundled.merge(overlay);
  }

  Future<SyncCheckResult> checkForUpdates() async {
    final cdn = cdnBaseUrl;
    if (cdn == null) {
      return const SyncCheckResult(
        availability: UpdateAvailability.notConfigured,
        message: 'Knowledge CDN not configured — bundled intelligence is active.',
      );
    }

    if (!await _isOnline()) {
      await _recordCheck(offline: true);
      return const SyncCheckResult(
        availability: UpdateAvailability.offline,
        message: 'Offline — bundled knowledge base is ready.',
      );
    }

    try {
      final local = await getLocalStatus();
      final remoteManifest = await _fetchRemoteManifest(cdn);
      await _overlay.saveSyncState(
        local.copyWith(
          lastCheckedAt: DateTime.now().toUtc().toIso8601String(),
          remoteKbVersion: remoteManifest.meta.kbVersion,
          clearError: true,
        ),
      );

      final effective = local.effectiveKbVersion;
      final remoteNewer = KnowledgeVersion.isNewer(
        remoteManifest.meta.kbVersion,
        effective,
      );
      final hashChanged = local.overlayContentHash != null &&
          local.overlayContentHash != remoteManifest.meta.contentHash;

      if (!remoteNewer && !hashChanged) {
        return SyncCheckResult(
          availability: UpdateAvailability.upToDate,
          remoteMeta: remoteManifest.meta,
          message: 'Intelligence is current (v$effective).',
        );
      }

      return SyncCheckResult(
        availability: UpdateAvailability.updateAvailable,
        remoteMeta: remoteManifest.meta,
        message:
            'Update available: v$effective → v${remoteManifest.meta.kbVersion}',
      );
    } catch (e) {
      final local = await getLocalStatus();
      await _overlay.saveSyncState(
        local.copyWith(
          lastCheckedAt: DateTime.now().toUtc().toIso8601String(),
          lastError: e.toString(),
        ),
      );
      return SyncCheckResult(
        availability: UpdateAvailability.offline,
        message: 'Could not reach update server — offline mode active.',
      );
    }
  }

  Future<SyncResult> syncLatest({bool force = false}) async {
    final cdn = cdnBaseUrl;
    if (cdn == null) {
      return const SyncResult(
        success: false,
        message: 'Configure KNOWLEDGE_CDN_URL to enable live updates.',
      );
    }

    if (!await _isOnline()) {
      return const SyncResult(
        success: false,
        message: 'No network connection. Bundled content remains available.',
      );
    }

    try {
      final local = await getLocalStatus();
      final bundledManifest = await _knowledge.getBundledManifest();
      final remoteManifest = await _fetchRemoteManifest(cdn);
      final effective = local.effectiveKbVersion;

      if (!force &&
          !KnowledgeVersion.isNewer(remoteManifest.meta.kbVersion, effective) &&
          local.overlayContentHash == remoteManifest.meta.contentHash) {
        return SyncResult(
          success: true,
          newKbVersion: effective,
          message: 'Already on latest intelligence (v$effective).',
        );
      }

      final deltas = await _computeDeltas(
        cdn: cdn,
        bundled: bundledManifest,
        remote: remoteManifest,
        localHashes: await _overlay.loadAssetHashes(),
      );

      for (final delta in deltas) {
        final url = delta.remoteUrl!;
        final response = await _http.get(Uri.parse(url)).timeout(_httpTimeout);
        if (response.statusCode != 200) {
          throw Exception('Failed to download ${delta.assetPath} (${response.statusCode})');
        }
        await _overlay.writeAsset(delta.assetPath, response.body);
      }

      await _overlay.writeManifest(remoteManifest);

      final remoteChangelog = await _fetchRemoteChangelog(cdn);
      if (remoteChangelog != null) {
        await _overlay.writeChangelog(remoteChangelog);
      }

      final newHashes = await _overlay.loadAssetHashes();
      for (final delta in deltas) {
        newHashes[delta.assetPath] = delta.contentHash;
      }
      newHashes['__manifest__'] = remoteManifest.meta.contentHash;
      await _overlay.saveAssetHashes(newHashes);

      await _overlay.saveSyncState(
        local.copyWith(
          bundledKbVersion: bundledManifest.meta.kbVersion,
          overlayKbVersion: remoteManifest.meta.kbVersion,
          overlayContentHash: remoteManifest.meta.contentHash,
          lastSyncedAt: DateTime.now().toUtc().toIso8601String(),
          lastCheckedAt: DateTime.now().toUtc().toIso8601String(),
          remoteKbVersion: remoteManifest.meta.kbVersion,
          clearError: true,
        ),
      );

      await _knowledge.reload();
      final claims = await _knowledge.getClaims();
      await DatabaseService.instance.reindex(claims);

      return SyncResult(
        success: true,
        appliedDeltas: deltas,
        newKbVersion: remoteManifest.meta.kbVersion,
        message: deltas.isEmpty
            ? 'Synced manifest v${remoteManifest.meta.kbVersion}.'
            : 'Applied ${deltas.length} delta(s) — now v${remoteManifest.meta.kbVersion}.',
      );
    } catch (e) {
      final local = await getLocalStatus();
      await _overlay.saveSyncState(
        local.copyWith(
          lastError: e.toString(),
          lastCheckedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
      return SyncResult(
        success: false,
        message: 'Sync failed — offline bundle still works. ${e.toString()}',
      );
    }
  }

  /// Non-blocking launch check; sync only when [autoSyncOnLaunch] and update exists.
  Future<SyncCheckResult?> autoCheckOnLaunch() async {
    if (!autoSyncOnLaunch) return null;
    final check = await checkForUpdates();
    if (check.availability == UpdateAvailability.updateAvailable) {
      await syncLatest();
    }
    return check;
  }

  Future<List<KnowledgeDelta>> _computeDeltas({
    required String cdn,
    required KnowledgeManifest bundled,
    required KnowledgeManifest remote,
    required Map<String, String> localHashes,
  }) async {
    final deltas = <KnowledgeDelta>[];
    final assetsToCheck = <String>{
      remote.topicsAsset,
      if (remote.booksAsset != null) remote.booksAsset!,
      ...remote.claimBundles.map((b) => b.asset),
    };

    for (final asset in assetsToCheck) {
      final remoteHash = await _resolveRemoteAssetHash(cdn, asset, remote);
      final localHash = localHashes[asset];
      final bundledExists = await _bundledAssetExists(asset);

      if (remoteHash == null) continue;
      if (localHash == remoteHash) continue;

      // Skip if bundled hash matches and no overlay override needed.
      if (localHash == null && bundledExists) {
        final bundledHash = await _hashBundledAsset(asset);
        if (bundledHash == remoteHash) continue;
      }

      deltas.add(
        KnowledgeDelta.fromManifestAsset(
          assetPath: asset,
          contentHash: remoteHash,
          cdnBase: cdn,
        ),
      );
    }

    return deltas;
  }

  Future<String?> _resolveRemoteAssetHash(
    String cdn,
    String assetPath,
    KnowledgeManifest remote,
  ) async {
    // Manifest-level assets use document contentHash when listed as primary refs.
    if (assetPath == remote.topicsAsset || assetPath == remote.booksAsset) {
      try {
        final url = KnowledgeDelta.fromManifestAsset(
          assetPath: assetPath,
          contentHash: '',
          cdnBase: cdn,
        ).remoteUrl!;
        final response = await _http.head(Uri.parse(url)).timeout(_httpTimeout);
        if (response.statusCode == 200) {
          final etag = response.headers['etag'];
          if (etag != null && etag.isNotEmpty) return 'etag:$etag';
        }
      } catch (_) {}
    }

    // For bundles, download sidecar hash file if present.
    final hashUrl =
        '${KnowledgeDelta.fromManifestAsset(assetPath: assetPath, contentHash: '', cdnBase: cdn).remoteUrl}.sha256';
    try {
      final response = await _http.get(Uri.parse(hashUrl)).timeout(_httpTimeout);
      if (response.statusCode == 200) {
        final line = response.body.trim().split('\n').first.trim();
        if (line.startsWith('sha256:')) return line;
        return 'sha256:$line';
      }
    } catch (_) {}

    // Fall back: always fetch if version bumped (caller uses version gate).
    return 'remote:${remote.meta.kbVersion}:$assetPath';
  }

  Future<String?> _hashBundledAsset(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json['contentHash'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _bundledAssetExists(String assetPath) async {
    try {
      await rootBundle.loadString(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<KnowledgeManifest> _fetchRemoteManifest(String cdn) async {
    final url = '$cdn/data/v2/knowledge_manifest.json';
    final response = await _http.get(Uri.parse(url)).timeout(_httpTimeout);
    if (response.statusCode != 200) {
      throw Exception('Manifest fetch failed (${response.statusCode})');
    }
    return KnowledgeManifest.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ChangelogDocument?> _fetchRemoteChangelog(String cdn) async {
    try {
      final url = '$cdn/data/changelog.json';
      final response = await _http.get(Uri.parse(url)).timeout(_httpTimeout);
      if (response.statusCode != 200) return null;
      return ChangelogDocument.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isOnline() async {
    final onlineCheck = _onlineOverride;
    if (onlineCheck != null) return onlineCheck();
    if (kIsWeb) return true;
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> _recordCheck({required bool offline}) async {
    final local = await getLocalStatus();
    await _overlay.saveSyncState(
      local.copyWith(
        lastCheckedAt: DateTime.now().toUtc().toIso8601String(),
        lastError: offline ? null : local.lastError,
      ),
    );
  }

  void dispose() => _http.close();
}