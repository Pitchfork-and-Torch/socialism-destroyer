import 'package:equatable/equatable.dart';

import 'knowledge_versioning.dart';

/// Describes a claim JSON bundle loaded in priority order (higher overrides).
class ClaimBundleRef extends Equatable {
  const ClaimBundleRef({
    required this.id,
    required this.asset,
    this.priority = 0,
  });

  final String id;
  final String asset;
  final int priority;

  factory ClaimBundleRef.fromJson(Map<String, dynamic> json) => ClaimBundleRef(
        id: json['id'] as String,
        asset: json['asset'] as String,
        priority: json['priority'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, asset, priority];
}

/// Root manifest for offline knowledge base and live-update delta sync.
class KnowledgeManifest extends Equatable {
  const KnowledgeManifest({
    required this.meta,
    required this.topicsAsset,
    required this.claimBundles,
    this.booksAsset,
  });

  final KnowledgeDocumentMeta meta;
  final String topicsAsset;
  final List<ClaimBundleRef> claimBundles;
  final String? booksAsset;

  factory KnowledgeManifest.fromJson(Map<String, dynamic> json) =>
      KnowledgeManifest(
        meta: KnowledgeDocumentMeta.fromJson(json),
        topicsAsset: json['topicsAsset'] as String,
        claimBundles: (json['claimBundles'] as List<dynamic>)
            .map((e) => ClaimBundleRef.fromJson(e as Map<String, dynamic>))
            .toList(),
        booksAsset: json['booksAsset'] as String?,
      );

  @override
  List<Object?> get props => [meta.kbVersion, topicsAsset, claimBundles];
}