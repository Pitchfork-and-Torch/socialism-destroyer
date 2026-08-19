import 'package:equatable/equatable.dart';

/// Types of locally persisted user interactions (Hive / future Supabase sync).
enum UserInteractionType {
  note,
  favorite,
  debateHistory,
  readingProgress,
  bookmark,
}

/// Unified envelope for all user-generated or user-state records.
///
/// [payload] holds type-specific JSON (see factories below). [entityId]
/// points at the claim, book, or topic the interaction relates to.
class UserInteraction extends Equatable {
  const UserInteraction({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.updatedAt,
    this.schemaVersion = 1,
  });

  final String id;
  final UserInteractionType type;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int schemaVersion;

  factory UserInteraction.fromJson(Map<String, dynamic> json) =>
      UserInteraction(
        id: json['id'] as String,
        type: _parseType(json['type'] as String),
        entityId: json['entityId'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        schemaVersion: json['schemaVersion'] as int? ?? 1,
      );

  static UserInteractionType _parseType(String raw) =>
      UserInteractionType.values.firstWhere(
        (t) => t.name == raw,
        orElse: () => UserInteractionType.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'schemaVersion': schemaVersion,
      };

  factory UserInteraction.note(UserNote note) => UserInteraction(
        id: note.id,
        type: UserInteractionType.note,
        entityId: note.claimId,
        payload: note.toPayload(),
        createdAt: note.createdAt,
        updatedAt: note.updatedAt,
      );

  factory UserInteraction.debate(DebateHistoryEntry entry) => UserInteraction(
        id: entry.id,
        type: UserInteractionType.debateHistory,
        entityId: entry.matchedClaimIds.isNotEmpty
            ? entry.matchedClaimIds.first
            : 'none',
        payload: entry.toPayload(),
        createdAt: entry.createdAt,
      );

  factory UserInteraction.favorite({
    required String id,
    required String claimId,
    required DateTime createdAt,
  }) =>
      UserInteraction(
        id: id,
        type: UserInteractionType.favorite,
        entityId: claimId,
        payload: const {},
        createdAt: createdAt,
      );

  factory UserInteraction.readingProgress({
    required String id,
    required String bookId,
    required int chapterIndex,
    required int charOffset,
    required DateTime updatedAt,
  }) =>
      UserInteraction(
        id: id,
        type: UserInteractionType.readingProgress,
        entityId: bookId,
        payload: {
          'chapterIndex': chapterIndex,
          'charOffset': charOffset,
        },
        createdAt: updatedAt,
        updatedAt: updatedAt,
      );

  UserNote? toNote() {
    if (type != UserInteractionType.note) return null;
    return UserNote.fromPayload(
      id: id,
      claimId: entityId,
      payload: payload,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DebateHistoryEntry? toDebateEntry() {
    if (type != UserInteractionType.debateHistory) return null;
    return DebateHistoryEntry.fromPayload(
      id: id,
      payload: payload,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, entityId];
}

class UserNote extends Equatable {
  const UserNote({
    required this.id,
    required this.claimId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String claimId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toPayload() => {'content': content};

  Map<String, dynamic> toJson() => {
        'id': id,
        'claimId': claimId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  factory UserNote.fromJson(Map<String, dynamic> json) => UserNote(
        id: json['id'] as String,
        claimId: json['claimId'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  factory UserNote.fromPayload({
    required String id,
    required String claimId,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) =>
      UserNote(
        id: id,
        claimId: claimId,
        content: payload['content'] as String,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [id, claimId];
}

class DebateHistoryEntry extends Equatable {
  const DebateHistoryEntry({
    required this.id,
    required this.inputText,
    required this.summary,
    required this.matchedClaimIds,
    required this.createdAt,
  });

  final String id;
  final String inputText;
  final String summary;
  final List<String> matchedClaimIds;
  final DateTime createdAt;

  Map<String, dynamic> toPayload() => {
        'inputText': inputText,
        'summary': summary,
        'matchedClaimIds': matchedClaimIds,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'inputText': inputText,
        'summary': summary,
        'matchedClaimIds': matchedClaimIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DebateHistoryEntry.fromJson(Map<String, dynamic> json) =>
      DebateHistoryEntry(
        id: json['id'] as String,
        inputText: json['inputText'] as String,
        summary: json['summary'] as String,
        matchedClaimIds: (json['matchedClaimIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  factory DebateHistoryEntry.fromPayload({
    required String id,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
  }) =>
      DebateHistoryEntry(
        id: id,
        inputText: payload['inputText'] as String,
        summary: payload['summary'] as String,
        matchedClaimIds: (payload['matchedClaimIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id];
}