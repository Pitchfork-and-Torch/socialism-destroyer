import 'package:equatable/equatable.dart';

enum SuggestionStatus { pending, approved, rejected }

SuggestionStatus suggestionStatusFromString(String value) =>
    SuggestionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SuggestionStatus.pending,
    );

/// A user-submitted claim idea awaiting curator review.
class ClaimSuggestion extends Equatable {
  const ClaimSuggestion({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.title,
    required this.socialistClaim,
    required this.counterSummary,
    required this.sources,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.reviewerNotes,
  });

  final String id;
  final String userId;
  final String topicId;
  final String title;
  final String socialistClaim;
  final String counterSummary;
  final List<SuggestionSource> sources;
  final String? notes;
  final SuggestionStatus status;
  final String? reviewerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ClaimSuggestion.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'];
    final sources = rawSources is List
        ? rawSources
            .map((e) => SuggestionSource.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : <SuggestionSource>[];

    return ClaimSuggestion(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      topicId: json['topic_id'] as String,
      title: json['title'] as String,
      socialistClaim: json['socialist_claim'] as String,
      counterSummary: json['counter_summary'] as String,
      sources: sources,
      notes: json['notes'] as String?,
      status: suggestionStatusFromString(json['status'] as String? ?? 'pending'),
      reviewerNotes: json['reviewer_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'topic_id': topicId,
        'title': title,
        'socialist_claim': socialistClaim,
        'counter_summary': counterSummary,
        'sources': sources.map((s) => s.toJson()).toList(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  String get statusLabel => switch (status) {
        SuggestionStatus.pending => 'Pending review',
        SuggestionStatus.approved => 'Approved',
        SuggestionStatus.rejected => 'Not accepted',
      };

  @override
  List<Object?> get props => [id, status, updatedAt];
}

class SuggestionSource extends Equatable {
  const SuggestionSource({
    required this.title,
    required this.url,
    this.citation,
  });

  final String title;
  final String url;
  final String? citation;

  factory SuggestionSource.fromJson(Map<String, dynamic> json) =>
      SuggestionSource(
        title: json['title'] as String,
        url: json['url'] as String,
        citation: json['citation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        if (citation != null && citation!.isNotEmpty) 'citation': citation,
      };

  @override
  List<Object?> get props => [title, url];
}

/// Local draft while composing a submission.
class ClaimSuggestionDraft extends Equatable {
  const ClaimSuggestionDraft({
    required this.topicId,
    required this.title,
    required this.socialistClaim,
    required this.counterSummary,
    required this.sources,
    this.notes,
    required this.savedAt,
  });

  final String topicId;
  final String title;
  final String socialistClaim;
  final String counterSummary;
  final List<SuggestionSource> sources;
  final String? notes;
  final DateTime savedAt;

  factory ClaimSuggestionDraft.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'] as List<dynamic>? ?? [];
    return ClaimSuggestionDraft(
      topicId: json['topicId'] as String,
      title: json['title'] as String,
      socialistClaim: json['socialistClaim'] as String,
      counterSummary: json['counterSummary'] as String,
      sources: rawSources
          .map((e) => SuggestionSource.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
      notes: json['notes'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'title': title,
        'socialistClaim': socialistClaim,
        'counterSummary': counterSummary,
        'sources': sources.map((s) => s.toJson()).toList(),
        if (notes != null) 'notes': notes,
        'savedAt': savedAt.toIso8601String(),
      };

  ClaimSuggestion toSuggestion(String id, String userId) => ClaimSuggestion(
        id: id,
        userId: userId,
        topicId: topicId,
        title: title,
        socialistClaim: socialistClaim,
        counterSummary: counterSummary,
        sources: sources,
        notes: notes,
        status: SuggestionStatus.pending,
        createdAt: savedAt,
        updatedAt: savedAt,
      );

  @override
  List<Object?> get props => [topicId, title, savedAt];
}