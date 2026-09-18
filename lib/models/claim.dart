import 'package:equatable/equatable.dart';

import 'knowledge_versioning.dart';
import 'source.dart';

/// A fully sourced counter-argument tied to a topic in the knowledge base.
///
/// Designed for 100+ claims: [topicPath] enables hierarchical filters without
/// joins; [embeddingText] is the canonical RAG chunk; [searchText] feeds FTS5.
/// Version fields support live delta sync from Supabase (Phase 6).
class Claim extends Equatable implements VersionedEntity {
  const Claim({
    required this.id,
    required this.topicId,
    required this.title,
    required this.socialistClaimText,
    required this.executiveSummary,
    required this.evidenceBullets,
    required this.fallacies,
    required this.sources,
    required this.whyItMatters,
    required this.relatedClaimIds,
    required this.tags,
    required this.updatedAt,
    required this.searchText,
    this.topicPath,
    this.claimQuote,
    this.quoteAttribution,
    this.chartData,
    this.embeddingText,
    this.schemaVersion = 2,
    this.kbVersion = '2.0.0',
    this.revision = 1,
    this.contentHash = '',
    this.publishedAt,
  });

  final String id;
  final String topicId;
  final String? topicPath;
  final String title;
  final String socialistClaimText;
  final String? claimQuote;
  /// Optional attribution line (e.g. public-domain author/source).
  final String? quoteAttribution;
  final String executiveSummary;
  final List<String> evidenceBullets;
  final ClaimChartData? chartData;
  final List<String> fallacies;
  final List<Source> sources;
  final String whyItMatters;
  final List<String> relatedClaimIds;
  final List<String> tags;

  @override
  final int schemaVersion;
  @override
  final String kbVersion;
  @override
  final int revision;
  @override
  final String contentHash;
  @override
  final String updatedAt;
  @override
  final String? publishedAt;

  /// Pre-computed text for vector embedding / RAG retrieval.
  final String? embeddingText;

  /// FTS + in-app search corpus.
  final String searchText;

  /// Backward-compatible alias for UI and legacy JSON (`socialistClaim`).
  String get socialistClaim => socialistClaimText;

  /// Text used for vector indexing — explicit field or derived from content.
  String get ragText => embeddingText ?? _defaultEmbeddingText();

  factory Claim.fromJson(Map<String, dynamic> json) {
    final socialistClaimText = json['socialistClaimText'] as String? ??
        json['socialistClaim'] as String;
    final claim = Claim(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      topicPath: json['topicPath'] as String?,
      title: json['title'] as String,
      socialistClaimText: socialistClaimText,
      claimQuote: json['claimQuote'] as String?,
      quoteAttribution: json['quoteAttribution'] as String?,
      executiveSummary: json['executiveSummary'] as String,
      evidenceBullets: (json['evidenceBullets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      chartData: json['chartData'] != null
          ? ClaimChartData.fromJson(json['chartData'] as Map<String, dynamic>)
          : null,
      fallacies:
          (json['fallacies'] as List<dynamic>).map((e) => e as String).toList(),
      sources: (json['sources'] as List<dynamic>)
          .map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      whyItMatters: json['whyItMatters'] as String,
      relatedClaimIds: (json['relatedClaimIds'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      updatedAt: json['updatedAt'] as String,
      searchText: json['searchText'] as String? ?? '',
      embeddingText: json['embeddingText'] as String?,
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      kbVersion: json['kbVersion'] as String? ?? '1.0.0',
      revision: json['revision'] as int? ?? 1,
      contentHash: json['contentHash'] as String? ?? '',
      publishedAt: json['publishedAt'] as String?,
    );

    if (claim.searchText.isEmpty) {
      return Claim(
        id: claim.id,
        topicId: claim.topicId,
        topicPath: claim.topicPath,
        title: claim.title,
        socialistClaimText: claim.socialistClaimText,
        claimQuote: claim.claimQuote,
        quoteAttribution: claim.quoteAttribution,
        executiveSummary: claim.executiveSummary,
        evidenceBullets: claim.evidenceBullets,
        chartData: claim.chartData,
        fallacies: claim.fallacies,
        sources: claim.sources,
        whyItMatters: claim.whyItMatters,
        relatedClaimIds: claim.relatedClaimIds,
        tags: claim.tags,
        updatedAt: claim.updatedAt,
        searchText: claim._defaultSearchText(),
        embeddingText: claim.embeddingText ?? claim._defaultEmbeddingText(),
        schemaVersion: claim.schemaVersion,
        kbVersion: claim.kbVersion,
        revision: claim.revision,
        contentHash: claim.contentHash,
        publishedAt: claim.publishedAt,
      );
    }
    return claim;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        if (topicPath != null) 'topicPath': topicPath,
        'title': title,
        'socialistClaimText': socialistClaimText,
        if (claimQuote != null) 'claimQuote': claimQuote,
        if (quoteAttribution != null) 'quoteAttribution': quoteAttribution,
        'executiveSummary': executiveSummary,
        'evidenceBullets': evidenceBullets,
        if (chartData != null) 'chartData': chartData!.toJson(),
        'fallacies': fallacies,
        'sources': sources.map((s) => s.toJson()).toList(),
        'whyItMatters': whyItMatters,
        'relatedClaimIds': relatedClaimIds,
        'tags': tags,
        'schemaVersion': schemaVersion,
        'kbVersion': kbVersion,
        'revision': revision,
        'contentHash': contentHash,
        'updatedAt': updatedAt,
        if (publishedAt != null) 'publishedAt': publishedAt,
        'embeddingText': ragText,
        'searchText': searchText,
      };

  String _defaultSearchText() =>
      '$title $socialistClaimText $executiveSummary ${tags.join(' ')}';

  String _defaultEmbeddingText() =>
      'Claim: $title\n'
      'Socialist argument: $socialistClaimText\n'
      'Summary: $executiveSummary\n'
      'Evidence: ${evidenceBullets.join('; ')}\n'
      'Fallacies: ${fallacies.join(', ')}\n'
      'Why it matters: $whyItMatters';

  @override
  List<Object?> get props => [id, topicId, revision, contentHash];
}

/// Envelope for claim bundle JSON files.
class ClaimBundle extends Equatable {
  const ClaimBundle({
    required this.meta,
    required this.bundleId,
    required this.claims,
    this.priority = 0,
  });

  final KnowledgeDocumentMeta meta;
  final String bundleId;
  final List<Claim> claims;
  final int priority;

  factory ClaimBundle.fromJson(Map<String, dynamic> json) => ClaimBundle(
        meta: KnowledgeDocumentMeta.fromJson(json),
        bundleId: json['bundleId'] as String? ?? 'default',
        priority: json['priority'] as int? ?? 0,
        claims: (json['claims'] as List<dynamic>)
            .map((e) => Claim.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [bundleId, claims.length];
}

class ClaimChartData extends Equatable {
  const ClaimChartData({
    required this.type,
    required this.title,
    required this.labels,
    required this.datasets,
  });

  final String type;
  final String title;
  final List<String> labels;
  final List<ChartDataset> datasets;

  factory ClaimChartData.fromJson(Map<String, dynamic> json) => ClaimChartData(
        type: json['type'] as String,
        title: json['title'] as String,
        labels:
            (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
        datasets: (json['datasets'] as List<dynamic>)
            .map((e) => ChartDataset.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'labels': labels,
        'datasets': datasets.map((d) => d.toJson()).toList(),
      };

  @override
  List<Object?> get props => [type, title];
}

class ChartDataset extends Equatable {
  const ChartDataset({required this.label, required this.values});

  final String label;
  final List<double> values;

  factory ChartDataset.fromJson(Map<String, dynamic> json) => ChartDataset(
        label: json['label'] as String,
        values: (json['values'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'values': values,
      };

  @override
  List<Object?> get props => [label];
}