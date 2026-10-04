import 'package:equatable/equatable.dart';

/// A curated drill playlist of opponent prompts for timed practice.
class DebatePlaylist extends Equatable {
  const DebatePlaylist({
    required this.id,
    required this.title,
    required this.description,
    required this.prompts,
    this.topicId,
    this.defaultSeconds = 120,
    this.difficulty = 'standard',
  });

  final String id;
  final String title;
  final String description;
  final List<DebatePlaylistPrompt> prompts;
  final String? topicId;
  final int defaultSeconds;
  final String difficulty;

  factory DebatePlaylist.fromJson(Map<String, dynamic> json) => DebatePlaylist(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        topicId: json['topicId'] as String?,
        defaultSeconds: json['defaultSeconds'] as int? ?? 120,
        difficulty: json['difficulty'] as String? ?? 'standard',
        prompts: (json['prompts'] as List<dynamic>? ?? [])
            .map(
              (e) => DebatePlaylistPrompt.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        if (topicId != null) 'topicId': topicId,
        'defaultSeconds': defaultSeconds,
        'difficulty': difficulty,
        'prompts': prompts.map((p) => p.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, prompts.length];
}

class DebatePlaylistPrompt extends Equatable {
  const DebatePlaylistPrompt({
    required this.text,
    this.claimId,
    this.hint,
    this.seconds,
  });

  final String text;
  final String? claimId;
  final String? hint;
  final int? seconds;

  factory DebatePlaylistPrompt.fromJson(Map<String, dynamic> json) =>
      DebatePlaylistPrompt(
        text: json['text'] as String,
        claimId: json['claimId'] as String?,
        hint: json['hint'] as String?,
        seconds: json['seconds'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        if (claimId != null) 'claimId': claimId,
        if (hint != null) 'hint': hint,
        if (seconds != null) 'seconds': seconds,
      };

  @override
  List<Object?> get props => [text, claimId];
}
