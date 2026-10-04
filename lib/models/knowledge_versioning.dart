import 'package:equatable/equatable.dart';

/// Shared versioning metadata for live-update delta sync and RAG pipelines.
///
/// Every knowledge-base document envelope and entity carries these fields so
/// the app can detect stale bundles, apply partial updates, and invalidate
/// vector indexes when [contentHash] changes.
abstract class VersionedEntity extends Equatable {
  const VersionedEntity();

  int get schemaVersion;
  String get kbVersion;
  int get revision;
  String get contentHash;
  String get updatedAt;
  String? get publishedAt;
}

/// Document-level wrapper (topics.json, claim bundles, books manifest).
class KnowledgeDocumentMeta extends Equatable {
  const KnowledgeDocumentMeta({
    required this.schemaVersion,
    required this.kbVersion,
    required this.updatedAt,
    required this.contentHash,
    this.publishedAt,
  });

  final int schemaVersion;
  final String kbVersion;
  final String updatedAt;
  final String contentHash;
  final String? publishedAt;

  factory KnowledgeDocumentMeta.fromJson(Map<String, dynamic> json) =>
      KnowledgeDocumentMeta(
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        kbVersion: json['kbVersion'] as String? ?? '1.0.0',
        updatedAt: json['updatedAt'] as String,
        contentHash: json['contentHash'] as String? ?? '',
        publishedAt: json['publishedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'kbVersion': kbVersion,
        'updatedAt': updatedAt,
        'contentHash': contentHash,
        if (publishedAt != null) 'publishedAt': publishedAt,
      };

  @override
  List<Object?> get props =>
      [schemaVersion, kbVersion, contentHash, updatedAt];
}