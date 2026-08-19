import 'package:equatable/equatable.dart';

import 'crusher_result.dart';
import 'source.dart';

/// How a debate session is structured.
enum DebateMode {
  /// User posts opponent arguments; engine returns sourced counters.
  spar,

  /// Engine opens with a steelmanned claim; user rebuts and is scored.
  challenge,
}

/// Speaker of a transcript turn.
enum DebateRole {
  user,
  engine,
  system,
}

/// Offline feedback on a user's rebuttal quality (Challenge mode, or optional spar self-check).
class TurnFeedback extends Equatable {
  const TurnFeedback({
    required this.overallScore,
    required this.evidenceScore,
    required this.specificityScore,
    required this.fallacyAwarenessScore,
    required this.strengths,
    required this.improvements,
    required this.detectedFallacies,
    required this.matchedClaimIds,
    this.summary,
  });

  /// 0–100 composite.
  final int overallScore;
  final int evidenceScore;
  final int specificityScore;
  final int fallacyAwarenessScore;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> detectedFallacies;
  final List<String> matchedClaimIds;
  final String? summary;

  String get gradeLabel {
    if (overallScore >= 85) return 'Debate-ready';
    if (overallScore >= 70) return 'Strong';
    if (overallScore >= 55) return 'Solid foundation';
    if (overallScore >= 40) return 'Needs sources';
    return 'Rebuild with evidence';
  }

  Map<String, dynamic> toJson() => {
        'overallScore': overallScore,
        'evidenceScore': evidenceScore,
        'specificityScore': specificityScore,
        'fallacyAwarenessScore': fallacyAwarenessScore,
        'strengths': strengths,
        'improvements': improvements,
        'detectedFallacies': detectedFallacies,
        'matchedClaimIds': matchedClaimIds,
        if (summary != null) 'summary': summary,
      };

  factory TurnFeedback.fromJson(Map<String, dynamic> json) => TurnFeedback(
        overallScore: json['overallScore'] as int? ?? 0,
        evidenceScore: json['evidenceScore'] as int? ?? 0,
        specificityScore: json['specificityScore'] as int? ?? 0,
        fallacyAwarenessScore: json['fallacyAwarenessScore'] as int? ?? 0,
        strengths: (json['strengths'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        improvements: (json['improvements'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        detectedFallacies: (json['detectedFallacies'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        matchedClaimIds: (json['matchedClaimIds'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        summary: json['summary'] as String?,
      );

  @override
  List<Object?> get props => [overallScore, evidenceScore, summary];
}

/// One message in a multi-turn debate.
class DebateTurn extends Equatable {
  const DebateTurn({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.crusherResult,
    this.feedback,
    this.label,
  });

  final String id;
  final DebateRole role;
  final String text;
  final DateTime createdAt;

  /// Engine turns may carry full Crusher output for evidence sidebar + export.
  final CrusherResult? crusherResult;
  final TurnFeedback? feedback;

  /// Short UI chip (e.g. "Opening steelman", "Your rebuttal").
  final String? label;

  List<Source> get sources => crusherResult?.sources ?? const [];

  List<String> get fallacies => crusherResult?.fallacies ?? const [];

  List<String> get evidenceBullets =>
      crusherResult?.evidenceBullets ?? const [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        if (label != null) 'label': label,
        if (crusherResult != null) 'crusherResult': crusherResult!.toJson(),
        if (feedback != null) 'feedback': feedback!.toJson(),
      };

  factory DebateTurn.fromJson(Map<String, dynamic> json) {
    CrusherResult? result;
    final rawResult = json['crusherResult'];
    if (rawResult is Map) {
      result = _crusherFromJson(Map<String, dynamic>.from(rawResult));
    }
    TurnFeedback? feedback;
    final rawFeedback = json['feedback'];
    if (rawFeedback is Map) {
      feedback = TurnFeedback.fromJson(Map<String, dynamic>.from(rawFeedback));
    }
    return DebateTurn(
      id: json['id'] as String,
      role: DebateRole.values.byName(json['role'] as String),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      label: json['label'] as String?,
      crusherResult: result,
      feedback: feedback,
    );
  }

  static CrusherResult _crusherFromJson(Map<String, dynamic> json) {
    return CrusherResult(
      id: json['id'] as String? ?? 'restored',
      inputText: json['inputText'] as String? ?? '',
      analysis: json['analysis'] is Map
          ? InputAnalysis.fromJson(
              Map<String, dynamic>.from(json['analysis'] as Map),
            )
          : const InputAnalysis(
              normalizedInput: '',
              expandedQuery: '',
              keyPhrases: [],
              detectedTopicIds: [],
              suspectedFallacies: [],
              matchConfidence: 0,
            ),
      mode: CrusherResponseMode.values.byName(
        json['mode'] as String? ?? 'composed',
      ),
      executiveSummary: json['executiveSummary'] as String? ?? '',
      evidenceBullets: (json['evidenceBullets'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => Source.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      fallacies: (json['fallacies'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      relatedTopics: (json['relatedTopics'] as List<dynamic>? ?? [])
          .map(
            (e) => RelatedTopicRef.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      matchedClaims: const [],
      whyItMatters: json['whyItMatters'] as String? ?? '',
      steelmannedOpponentClaim: json['steelmannedOpponentClaim'] as String?,
      primaryClaimTitle: json['primaryClaimTitle'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, role, text];
}

/// Full multi-turn debate session (Hive-persisted).
class DebateSession extends Equatable {
  const DebateSession({
    required this.id,
    required this.mode,
    required this.title,
    required this.turns,
    required this.createdAt,
    required this.updatedAt,
    this.seedArgument,
    this.seedClaimId,
    this.topicId,
    this.llmAssisted = false,
  });

  final String id;
  final DebateMode mode;
  final String title;
  final List<DebateTurn> turns;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? seedArgument;
  final String? seedClaimId;
  final String? topicId;

  /// True if any engine turn used optional LLM polish.
  final bool llmAssisted;

  int get turnCount => turns.length;

  int get userTurnCount =>
      turns.where((t) => t.role == DebateRole.user).length;

  DebateTurn? get latestEngineTurn {
    for (var i = turns.length - 1; i >= 0; i--) {
      if (turns[i].role == DebateRole.engine) return turns[i];
    }
    return null;
  }

  /// Aggregate sources from all engine turns (deduped by URL/title).
  List<Source> get allSources {
    final seen = <String>{};
    final out = <Source>[];
    for (final t in turns) {
      for (final s in t.sources) {
        final key = s.url.isNotEmpty ? s.url : (s.citation ?? s.title);
        if (seen.add(key)) out.add(s);
      }
    }
    return out;
  }

  List<String> get allMatchedClaimIds {
    final ids = <String>{};
    for (final t in turns) {
      final result = t.crusherResult;
      if (result != null) {
        ids.addAll(result.matchedClaimIds);
      }
      final fb = t.feedback;
      if (fb != null) {
        ids.addAll(fb.matchedClaimIds);
      }
    }
    return ids.toList();
  }

  double? get averageUserScore {
    final scored = turns
        .where((t) => t.role == DebateRole.user && t.feedback != null)
        .map((t) => t.feedback!.overallScore)
        .toList();
    if (scored.isEmpty) return null;
    return scored.reduce((a, b) => a + b) / scored.length;
  }

  DebateSession copyWith({
    String? title,
    List<DebateTurn>? turns,
    DateTime? updatedAt,
    bool? llmAssisted,
  }) =>
      DebateSession(
        id: id,
        mode: mode,
        title: title ?? this.title,
        turns: turns ?? this.turns,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        seedArgument: seedArgument,
        seedClaimId: seedClaimId,
        topicId: topicId,
        llmAssisted: llmAssisted ?? this.llmAssisted,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.name,
        'title': title,
        'turns': turns.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (seedArgument != null) 'seedArgument': seedArgument,
        if (seedClaimId != null) 'seedClaimId': seedClaimId,
        if (topicId != null) 'topicId': topicId,
        'llmAssisted': llmAssisted,
      };

  factory DebateSession.fromJson(Map<String, dynamic> json) => DebateSession(
        id: json['id'] as String,
        mode: DebateMode.values.byName(json['mode'] as String? ?? 'spar'),
        title: json['title'] as String? ?? 'Debate',
        turns: (json['turns'] as List<dynamic>? ?? [])
            .map((e) => DebateTurn.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
        ),
        seedArgument: json['seedArgument'] as String?,
        seedClaimId: json['seedClaimId'] as String?,
        topicId: json['topicId'] as String?,
        llmAssisted: json['llmAssisted'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, mode, turns.length, updatedAt];
}
