import 'package:equatable/equatable.dart';

/// Cloud-synced user profile stored in Supabase `profiles` table.
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    this.favorites = const [],
    this.personalNotes = const {},
    this.readingProgress = const {},
    this.debateHistory = const [],
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> favorites;
  final Map<String, dynamic> personalNotes;
  final Map<String, dynamic> readingProgress;
  final List<Map<String, dynamic>> debateHistory;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        email: json['email'] as String?,
        displayName: json['display_name'] as String?,
        photoUrl: json['photo_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastLogin: DateTime.parse(json['last_login'] as String),
        favorites: (json['favorites'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        personalNotes:
            Map<String, dynamic>.from(json['personal_notes'] as Map? ?? {}),
        readingProgress:
            Map<String, dynamic>.from(json['reading_progress'] as Map? ?? {}),
        debateHistory: (json['debate_history'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'created_at': createdAt.toIso8601String(),
        'last_login': lastLogin.toIso8601String(),
        'favorites': favorites,
        'personal_notes': personalNotes,
        'reading_progress': readingProgress,
        'debate_history': debateHistory,
      };

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? lastLogin,
    List<String>? favorites,
    Map<String, dynamic>? personalNotes,
    Map<String, dynamic>? readingProgress,
    List<Map<String, dynamic>>? debateHistory,
  }) =>
      UserProfile(
        uid: uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
        lastLogin: lastLogin ?? this.lastLogin,
        favorites: favorites ?? this.favorites,
        personalNotes: personalNotes ?? this.personalNotes,
        readingProgress: readingProgress ?? this.readingProgress,
        debateHistory: debateHistory ?? this.debateHistory,
      );

  @override
  List<Object?> get props => [uid, email, lastLogin];
}