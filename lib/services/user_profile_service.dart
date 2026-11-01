import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'local_storage_service.dart';

/// Syncs user data between Hive (offline) and Supabase `profiles` table.
class UserProfileService {
  UserProfileService({LocalStorageService? local})
      : _local = local ?? LocalStorageService();

  final LocalStorageService _local;

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<UserProfile?> fetchProfile(String uid) async {
    final client = _client;
    if (client == null) return null;

    final row = await client.from('profiles').select().eq('uid', uid).maybeSingle();
    if (row == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(row));
  }

  Future<UserProfile> upsertFromAuthUser(User user) async {
    final now = DateTime.now().toUtc();
    final uid = user.id;
    final existing = await fetchProfile(uid);

    final localFavorites = _local.favorites.values.cast<String>().toList();
    final localNotes = _exportBox(_local.notes);
    final localProgress = _exportBox(_local.readingProgress);
    final localHistory = _local.debateHistory.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final profile = UserProfile(
      uid: uid,
      email: user.email ?? existing?.email,
      displayName: user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String? ??
          existing?.displayName,
      photoUrl: user.userMetadata?['avatar_url'] as String? ??
          user.userMetadata?['picture'] as String? ??
          existing?.photoUrl,
      createdAt: existing?.createdAt ?? now,
      lastLogin: now,
      favorites: _mergeLists(existing?.favorites ?? [], localFavorites),
      personalNotes: {...?existing?.personalNotes, ...localNotes},
      readingProgress: {...?existing?.readingProgress, ...localProgress},
      debateHistory: [
        ...?existing?.debateHistory,
        ...localHistory,
      ],
    );

    await _saveToSupabase(profile);
    await _hydrateLocal(profile);
    return profile;
  }

  Future<void> _saveToSupabase(UserProfile profile) async {
    final client = _client;
    if (client == null) return;

    await client.from('profiles').upsert({
      'uid': profile.uid,
      'email': profile.email,
      'display_name': profile.displayName,
      'photo_url': profile.photoUrl,
      'created_at': profile.createdAt.toIso8601String(),
      'last_login': profile.lastLogin.toIso8601String(),
      'favorites': profile.favorites,
      'personal_notes': profile.personalNotes,
      'reading_progress': profile.readingProgress,
      'debate_history': profile.debateHistory,
    });
  }

  Future<void> _hydrateLocal(UserProfile profile) async {
    for (final id in profile.favorites) {
      await _local.favorites.put(id, id);
    }
    for (final entry in profile.personalNotes.entries) {
      await _local.notes.put(entry.key, Map.from(entry.value as Map));
    }
    for (final entry in profile.readingProgress.entries) {
      await _local.readingProgress.put(entry.key, Map.from(entry.value as Map));
    }
  }

  Map<String, dynamic> _exportBox(Box<Map> box) {
    return {for (final key in box.keys) key.toString(): box.get(key)};
  }

  List<String> _mergeLists(List<String> a, List<String> b) {
    return {...a, ...b}.toList();
  }

  /// Pushes local reading progress and book annotations to Supabase.
  Future<void> syncReadingData(String uid) async {
    final existing = await fetchProfile(uid);
    if (existing == null) return;

    final localProgress = _exportBox(_local.readingProgress);
    final localNotes = _exportBox(_local.notes);

    final updated = existing.copyWith(
      readingProgress: {...existing.readingProgress, ...localProgress},
      personalNotes: {...existing.personalNotes, ...localNotes},
      lastLogin: DateTime.now().toUtc(),
    );
    await _saveToSupabase(updated);
  }
}