import 'package:equatable/equatable.dart';

import 'knowledge_versioning.dart';

/// Semantic version comparison for kbVersion strings (e.g. "2.0.0").
abstract final class KnowledgeVersion {
  static int compare(String a, String b) {
    final pa = _parse(a);
    final pb = _parse(b);
    for (var i = 0; i < 3; i++) {
      final diff = pa[i] - pb[i];
      if (diff != 0) return diff;
    }
    return 0;
  }

  static bool isNewer(String candidate, String baseline) =>
      compare(candidate, baseline) > 0;

  static List<int> _parse(String v) {
    final parts = v.split('.');
    int part(int i) =>
        i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0;
    return [part(0), part(1), part(2)];
  }
}

enum SyncPhase {
  idle,
  checking,
  downloading,
  applying,
  complete,
  error,
}

enum UpdateAvailability {
  unknown,
  upToDate,
  updateAvailable,
  offline,
  notConfigured,
}

/// Describes a single asset delta in a remote manifest.
class KnowledgeDelta extends Equatable {
  const KnowledgeDelta({
    required this.assetPath,
    required this.contentHash,
    this.remoteUrl,
  });

  final String assetPath;
  final String contentHash;
  final String? remoteUrl;

  factory KnowledgeDelta.fromManifestAsset({
    required String assetPath,
    required String contentHash,
    required String cdnBase,
  }) =>
      KnowledgeDelta(
        assetPath: assetPath,
        contentHash: contentHash,
        remoteUrl: _resolveCdnUrl(cdnBase, assetPath),
      );

  static String _resolveCdnUrl(String base, String assetPath) {
    final normalized = assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;
    final trimmedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$trimmedBase/$normalized';
  }

  @override
  List<Object?> get props => [assetPath, contentHash];
}

/// Persisted sync metadata (Hive settings).
class KnowledgeSyncState extends Equatable {
  const KnowledgeSyncState({
    required this.bundledKbVersion,
    this.overlayKbVersion,
    this.overlayContentHash,
    this.lastCheckedAt,
    this.lastSyncedAt,
    this.remoteKbVersion,
    this.lastError,
  });

  final String bundledKbVersion;
  final String? overlayKbVersion;
  final String? overlayContentHash;
  final String? lastCheckedAt;
  final String? lastSyncedAt;
  final String? remoteKbVersion;
  final String? lastError;

  String get effectiveKbVersion => overlayKbVersion ?? bundledKbVersion;

  bool get hasOverlay => overlayKbVersion != null;

  factory KnowledgeSyncState.fromJson(Map<String, dynamic> json) =>
      KnowledgeSyncState(
        bundledKbVersion:
            json['bundledKbVersion'] as String? ?? '1.0.0',
        overlayKbVersion: json['overlayKbVersion'] as String?,
        overlayContentHash: json['overlayContentHash'] as String?,
        lastCheckedAt: json['lastCheckedAt'] as String?,
        lastSyncedAt: json['lastSyncedAt'] as String?,
        remoteKbVersion: json['remoteKbVersion'] as String?,
        lastError: json['lastError'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'bundledKbVersion': bundledKbVersion,
        if (overlayKbVersion != null) 'overlayKbVersion': overlayKbVersion,
        if (overlayContentHash != null) 'overlayContentHash': overlayContentHash,
        if (lastCheckedAt != null) 'lastCheckedAt': lastCheckedAt,
        if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt,
        if (remoteKbVersion != null) 'remoteKbVersion': remoteKbVersion,
        if (lastError != null) 'lastError': lastError,
      };

  KnowledgeSyncState copyWith({
    String? bundledKbVersion,
    String? overlayKbVersion,
    String? overlayContentHash,
    String? lastCheckedAt,
    String? lastSyncedAt,
    String? remoteKbVersion,
    String? lastError,
    bool clearError = false,
    bool clearOverlay = false,
  }) =>
      KnowledgeSyncState(
        bundledKbVersion: bundledKbVersion ?? this.bundledKbVersion,
        overlayKbVersion:
            clearOverlay ? null : (overlayKbVersion ?? this.overlayKbVersion),
        overlayContentHash: clearOverlay
            ? null
            : (overlayContentHash ?? this.overlayContentHash),
        lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        remoteKbVersion: remoteKbVersion ?? this.remoteKbVersion,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );

  @override
  List<Object?> get props => [
        bundledKbVersion,
        overlayKbVersion,
        overlayContentHash,
        lastCheckedAt,
        lastSyncedAt,
        remoteKbVersion,
        lastError,
      ];
}

class SyncCheckResult extends Equatable {
  const SyncCheckResult({
    required this.availability,
    this.remoteMeta,
    this.message,
  });

  final UpdateAvailability availability;
  final KnowledgeDocumentMeta? remoteMeta;
  final String? message;

  @override
  List<Object?> get props => [availability, remoteMeta, message];
}

class SyncResult extends Equatable {
  const SyncResult({
    required this.success,
    this.appliedDeltas = const [],
    this.newKbVersion,
    this.message,
  });

  final bool success;
  final List<KnowledgeDelta> appliedDeltas;
  final String? newKbVersion;
  final String? message;

  @override
  List<Object?> get props => [success, appliedDeltas, newKbVersion, message];
}