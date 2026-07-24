import 'package:equatable/equatable.dart';

import 'claim.dart';
import 'source.dart';

/// How the crusher produced its response.
enum CrusherResponseMode {
  /// High-confidence match to a single curated claim.
  curated,

  /// Synthesized from multiple curated claims (no single strong match).
  composed,

  /// LLM-enhanced structured response (optional API key).
  llmEnhanced,
}

enum RetrievalMethod { fts, fuzzy, vector, embedding }

/// A scored claim hit from any retrieval backend.
class RetrievalHit extends Equatable {
  const RetrievalHit({
    required this.claimId,
    required this.score,
    required this.method,
    required this.rank,
  });

  final String claimId;
  final double score;
  final RetrievalMethod method;
  final int rank;

  @override
  List<Object?> get props => [claimId, score];
}

/// Parsed understanding of user input before retrieval.
class InputAnalysis extends Equatable {
  const InputAnalysis({
    required this.normalizedInput,
    required this.expandedQuery,
    required this.keyPhrases,
    required this.detectedTopicIds,
    required this.suspectedFallacies,
    required this.matchConfidence,
    this.intentLabel,
  });

  final String normalizedInput;
  final String expandedQuery;
  final List<String> keyPhrases;
  final List<String> detectedTopicIds;
  final List<String> suspectedFallacies;
  final double matchConfidence;

  /// Human-readable intent (e.g. "Labor exploitation", "Nordic model").
  final String? intentLabel;

  Map<String, dynamic> toJson() => {
        'normalizedInput': normalizedInput,
        'expandedQuery': expandedQuery,
        'keyPhrases': keyPhrases,
        'detectedTopicIds': detectedTopicIds,
        'suspectedFallacies': suspectedFallacies,
        'matchConfidence': matchConfidence,
        if (intentLabel != null) 'intentLabel': intentLabel,
      };

  factory InputAnalysis.fromJson(Map<String, dynamic> json) => InputAnalysis(
        normalizedInput: json['normalizedInput'] as String,
        expandedQuery: json['expandedQuery'] as String,
        keyPhrases: (json['keyPhrases'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        detectedTopicIds: (json['detectedTopicIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        suspectedFallacies: (json['suspectedFallacies'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        matchConfidence: (json['matchConfidence'] as num).toDouble(),
        intentLabel: json['intentLabel'] as String?,
      );

  @override
  List<Object?> get props => [normalizedInput, matchConfidence];
}

class RelatedTopicRef extends Equatable {
  const RelatedTopicRef({
    required this.id,
    required this.title,
    this.description,
  });

  final String id;
  final String title;
  final String? description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
      };

  factory RelatedTopicRef.fromJson(Map<String, dynamic> json) =>
      RelatedTopicRef(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
      );

  @override
  List<Object?> get props => [id];
}

class MatchedClaimRef extends Equatable {
  const MatchedClaimRef({
    required this.claim,
    required this.score,
    required this.role,
  });

  final Claim claim;
  final double score;

  /// primary | supporting
  final String role;

  Map<String, dynamic> toJson() => {
        'claimId': claim.id,
        'score': score,
        'role': role,
      };

  @override
  List<Object?> get props => [claim.id, score];
}

/// Full Argument Crusher output — exportable and storable in debate history.
class CrusherResult extends Equatable {
  const CrusherResult({
    required this.id,
    required this.inputText,
    required this.analysis,
    required this.mode,
    required this.executiveSummary,
    required this.evidenceBullets,
    required this.sources,
    required this.fallacies,
    required this.relatedTopics,
    required this.matchedClaims,
    required this.whyItMatters,
    required this.createdAt,
    this.steelmannedOpponentClaim,
    this.primaryClaimTitle,
  });

  final String id;
  final String inputText;

  /// Strongest steelman from matched curated claim (when available).
  final String? steelmannedOpponentClaim;
  final String? primaryClaimTitle;
  final InputAnalysis analysis;
  final CrusherResponseMode mode;
  final String executiveSummary;
  final List<String> evidenceBullets;
  final List<Source> sources;
  final List<String> fallacies;
  final List<RelatedTopicRef> relatedTopics;
  final List<MatchedClaimRef> matchedClaims;
  final String whyItMatters;
  final DateTime createdAt;

  List<String> get matchedClaimIds =>
      matchedClaims.map((m) => m.claim.id).toList();

  Claim? get primaryClaim {
    for (final m in matchedClaims) {
      if (m.role == 'primary') return m.claim;
    }
    return matchedClaims.isNotEmpty ? matchedClaims.first.claim : null;
  }

  String get modeLabel => switch (mode) {
        CrusherResponseMode.curated => 'Curated knowledge base',
        CrusherResponseMode.composed => 'Multi-claim synthesis',
        CrusherResponseMode.llmEnhanced => 'AI-enhanced response',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'inputText': inputText,
        'analysis': analysis.toJson(),
        'mode': mode.name,
        'executiveSummary': executiveSummary,
        'evidenceBullets': evidenceBullets,
        'sources': sources.map((s) => s.toJson()).toList(),
        'fallacies': fallacies,
        'relatedTopics': relatedTopics.map((t) => t.toJson()).toList(),
        'matchedClaimIds': matchedClaimIds,
        'whyItMatters': whyItMatters,
        'createdAt': createdAt.toIso8601String(),
        if (steelmannedOpponentClaim != null)
          'steelmannedOpponentClaim': steelmannedOpponentClaim,
        if (primaryClaimTitle != null) 'primaryClaimTitle': primaryClaimTitle,
      };

  @override
  List<Object?> get props => [id, inputText, mode];
}