import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/changelog.dart';
import '../models/knowledge_manifest.dart';
import '../models/knowledge_sync.dart';
import '../utils/app_constants.dart';
import 'local_storage_service.dart';
import 'knowledge_overlay_store_io.dart'
    if (dart.library.html) 'knowledge_overlay_store_io_stub.dart';

/// Persists synced knowledge assets under the app documents directory.
///
/// Overlay files mirror bundled asset paths without the `assets/` prefix:
/// `assets/data/v2/topics.json` → `{overlayRoot}/data/v2/topics.json`
///
/// On web, overlay data is stored in [LocalStorageService.knowledgeOverlayBox].
class KnowledgeOverlayStore {
  KnowledgeOverlayStore({this._rootOverride});

  final String? _rootOverride;
  String? _root;

  static const String overlayDirName = 'knowledge_overlay';
  static const String manifestFileName = 'knowledge_manifest.json';
  static const String changelogFileName = 'changelog.json';
  static const String syncStateFileName = 'sync_state.json';
  static const String assetHashesFileName = 'asset_hashes.json';
  static const String _hiveSyncStateKey = '__sync_state__';
  static const String _hiveManifestKey = '__manifest__';
  static const String _hiveChangelogKey = '__changelog__';
  static const String _hiveAssetHashesKey = '__asset_hashes__';
  static const String _hiveAssetPrefix = 'asset:';

  bool get _usesHive => kIsWeb && _rootOverride == null;

  Future<String> get root async {
    final override = _rootOverride;
    if (override != null) return override;
    final cached = _root;
    if (cached != null) return cached;
    if (kIsWeb) {
      _root = '';
      return _root!;
    }
    try {
      _root = p.join(
        (await getApplicationDocumentsDirectory()).path,
        overlayDirName,
      );
    } catch (_) {
      // Tests and unsupported platforms — overlay reads are no-ops.
      _root = '';
    }
    return _root!;
  }

  Future<bool> get _canUseFileOverlay async {
    if (_usesHive) return false;
    if (_rootOverride != null) return true;
    final path = await root;
    return path.isNotEmpty;
  }

  bool get isAvailable => _rootOverride != null || !kIsWeb || _usesHive;

  Box<String>? get _hiveBox {
    if (!_usesHive) return null;
    if (!Hive.isBoxOpen(LocalStorageService.knowledgeOverlayBox)) return null;
    return Hive.box<String>(LocalStorageService.knowledgeOverlayBox);
  }

  String assetKeyFromBundlePath(String bundlePath) {
    if (bundlePath.startsWith('assets/')) {
      return bundlePath.substring('assets/'.length);
    }
    return bundlePath;
  }

  Future<String> pathForAsset(String bundlePath) async {
    return p.join(await root, assetKeyFromBundlePath(bundlePath));
  }

  Future<bool> hasOverlayManifest() async {
    if (_usesHive) return _hiveBox?.containsKey(_hiveManifestKey) ?? false;
    if (!await _canUseFileOverlay) return false;
    return OverlayFileOps.exists(p.join(await root, manifestFileName));
  }

  Future<bool> hasOverlayAsset(String bundlePath) async {
    if (_usesHive) {
      return _hiveBox?.containsKey('$_hiveAssetPrefix${assetKeyFromBundlePath(bundlePath)}') ??
          false;
    }
    if (!await _canUseFileOverlay) return false;
    return OverlayFileOps.exists(await pathForAsset(bundlePath));
  }

  Future<String?> readOverlayAsset(String bundlePath) async {
    if (_usesHive) {
      return _hiveBox?.get('$_hiveAssetPrefix${assetKeyFromBundlePath(bundlePath)}');
    }
    if (!await _canUseFileOverlay) return null;
    final path = await pathForAsset(bundlePath);
    if (!await OverlayFileOps.exists(path)) return null;
    return OverlayFileOps.read(path);
  }

  Future<String?> readOverlayManifest() async {
    if (_usesHive) return _hiveBox?.get(_hiveManifestKey);
    if (!await _canUseFileOverlay) return null;
    final path = p.join(await root, manifestFileName);
    if (!await OverlayFileOps.exists(path)) return null;
    return OverlayFileOps.read(path);
  }

  Future<KnowledgeManifest?> loadOverlayManifest() async {
    final raw = await readOverlayManifest();
    if (raw == null) return null;
    return KnowledgeManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<ChangelogDocument?> loadOverlayChangelog() async {
    if (_usesHive) {
      final raw = _hiveBox?.get(_hiveChangelogKey);
      if (raw == null) return null;
      return ChangelogDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    if (!await _canUseFileOverlay) return null;
    final path = p.join(await root, changelogFileName);
    if (!await OverlayFileOps.exists(path)) return null;
    final raw = await OverlayFileOps.read(path);
    return ChangelogDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<KnowledgeSyncState> loadSyncState() async {
    if (_usesHive) {
      final raw = _hiveBox?.get(_hiveSyncStateKey);
      if (raw == null) {
        return KnowledgeSyncState(bundledKbVersion: AppConstants.knowledgeBaseVersion);
      }
      return KnowledgeSyncState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    if (!await _canUseFileOverlay) {
      return KnowledgeSyncState(bundledKbVersion: AppConstants.knowledgeBaseVersion);
    }
    final path = p.join(await root, syncStateFileName);
    if (!await OverlayFileOps.exists(path)) {
      return KnowledgeSyncState(bundledKbVersion: AppConstants.knowledgeBaseVersion);
    }
    final raw = await OverlayFileOps.read(path);
    return KnowledgeSyncState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSyncState(KnowledgeSyncState state) async {
    if (_usesHive) {
      await _hivePut(_hiveSyncStateKey, jsonEncode(state.toJson()));
      return;
    }
    if (!await _canUseFileOverlay) return;
    await _ensureFileRoot();
    await OverlayFileOps.write(
      p.join(await root, syncStateFileName),
      jsonEncode(state.toJson()),
    );
  }

  Future<Map<String, String>> loadAssetHashes() async {
    if (_usesHive) {
      final raw = _hiveBox?.get(_hiveAssetHashesKey);
      if (raw == null) return {};
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json.map((k, v) => MapEntry(k, v as String));
    }
    if (!await _canUseFileOverlay) return {};
    final path = p.join(await root, assetHashesFileName);
    if (!await OverlayFileOps.exists(path)) return {};
    final raw = await OverlayFileOps.read(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> saveAssetHashes(Map<String, String> hashes) async {
    if (_usesHive) {
      await _hivePut(_hiveAssetHashesKey, jsonEncode(hashes));
      return;
    }
    if (!await _canUseFileOverlay) return;
    await _ensureFileRoot();
    await OverlayFileOps.write(
      p.join(await root, assetHashesFileName),
      jsonEncode(hashes),
    );
  }

  Future<void> writeManifest(KnowledgeManifest manifest) async {
    final json = {
      'schemaVersion': manifest.meta.schemaVersion,
      'kbVersion': manifest.meta.kbVersion,
      'updatedAt': manifest.meta.updatedAt,
      'contentHash': manifest.meta.contentHash,
      if (manifest.meta.publishedAt != null)
        'publishedAt': manifest.meta.publishedAt,
      'topicsAsset': manifest.topicsAsset,
      if (manifest.booksAsset != null) 'booksAsset': manifest.booksAsset,
      'claimBundles': manifest.claimBundles
          .map((b) => {
                'id': b.id,
                'asset': b.asset,
                'priority': b.priority,
              })
          .toList(),
    };
    final payload = const JsonEncoder.withIndent('  ').convert(json);
    if (_usesHive) {
      await _hivePut(_hiveManifestKey, payload);
      return;
    }
    if (!await _canUseFileOverlay) return;
    await _ensureFileRoot();
    await OverlayFileOps.write(p.join(await root, manifestFileName), payload);
  }

  Future<void> writeChangelog(ChangelogDocument changelog) async {
    final payload =
        const JsonEncoder.withIndent('  ').convert(changelog.toJson());
    if (_usesHive) {
      await _hivePut(_hiveChangelogKey, payload);
      return;
    }
    if (!await _canUseFileOverlay) return;
    await _ensureFileRoot();
    await OverlayFileOps.write(p.join(await root, changelogFileName), payload);
  }

  Future<void> writeAsset(String bundlePath, String content) async {
    if (!bundlePath.startsWith('assets/')) {
      throw ArgumentError.value(
        bundlePath.length > 64 ? '${bundlePath.substring(0, 64)}…' : bundlePath,
        'bundlePath',
        'Expected bundled asset path starting with assets/',
      );
    }
    if (_usesHive) {
      await _hivePut('$_hiveAssetPrefix${assetKeyFromBundlePath(bundlePath)}', content);
      return;
    }
    if (!await _canUseFileOverlay) return;
    await _ensureFileRoot();
    final path = await pathForAsset(bundlePath);
    await OverlayFileOps.write(path, content, createParent: true);
  }

  Future<void> clearOverlay() async {
    if (_usesHive) {
      await _hiveBox?.clear();
      return;
    }
    if (!await _canUseFileOverlay) return;
    await OverlayFileOps.deleteDirectory(await root);
    _root = null;
  }

  Future<void> _ensureFileRoot() async {
    if (!await _canUseFileOverlay) return;
    await OverlayFileOps.ensureDirectory(await root);
  }

  Future<void> _hivePut(String key, String value) async {
    final box = _hiveBox;
    if (box == null) {
      throw StateError('Knowledge overlay Hive box is not open');
    }
    await box.put(key, value);
  }
}