import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_progress.dart';
import '../../../services/local_storage_service.dart';

/// Tracks daily streaks and lightweight achievements offline.
class UserProgressService {
  UserProgressService({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  static const _keyStreak = 'streak_days';
  static const _keyLastVisit = 'last_visit_date';
  static const _keyTotalCrushes = 'total_crushes';
  static const _keyAchievements = 'achievement_ids';

  Box get _box => _storage.settings;

  UserProgress read() {
    final achievements = (_box.get(_keyAchievements) as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final lastRaw = _box.get(_keyLastVisit) as String?;
    return UserProgress(
      streakDays: (_box.get(_keyStreak) as int?) ?? 0,
      totalCrushes: (_box.get(_keyTotalCrushes) as int?) ?? 0,
      achievements: achievements,
      lastVisitDate: lastRaw != null ? DateTime.tryParse(lastRaw) : null,
    );
  }

  /// Call on app/home open — updates streak and unlocks visit achievements.
  Future<UserProgress> recordVisit() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var progress = read();
    var streak = progress.streakDays;
    final last = progress.lastVisitDate;

    if (last == null) {
      streak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // same day — no streak change
      } else if (diff == 1) {
        streak += 1;
      } else {
        streak = 1;
      }
    }

    var achievements = List<String>.from(progress.achievements);
    achievements = _unlock(achievements, Achievements.welcome.id);
    if (streak >= 3) achievements = _unlock(achievements, Achievements.streak3.id);
    if (streak >= 7) achievements = _unlock(achievements, Achievements.streak7.id);

    await _box.put(_keyStreak, streak);
    await _box.put(_keyLastVisit, today.toIso8601String());
    await _box.put(_keyAchievements, achievements);

    return progress.copyWith(
      streakDays: streak,
      achievements: achievements,
      lastVisitDate: today,
    );
  }

  Future<UserProgress> recordCrush() async {
    var progress = read();
    final total = progress.totalCrushes + 1;
    var achievements = List<String>.from(progress.achievements);
    achievements = _unlock(achievements, Achievements.firstCrush.id);

    await _box.put(_keyTotalCrushes, total);
    await _box.put(_keyAchievements, achievements);

    return progress.copyWith(
      totalCrushes: total,
      achievements: achievements,
    );
  }

  Future<UserProgress> recordTreeVisit() async {
    var progress = read();
    var achievements = List<String>.from(progress.achievements);
    achievements = _unlock(achievements, Achievements.explorer.id);
    await _box.put(_keyAchievements, achievements);
    return progress.copyWith(achievements: achievements);
  }

  Future<UserProgress> recordLibraryVisit() async {
    var progress = read();
    var achievements = List<String>.from(progress.achievements);
    achievements = _unlock(achievements, Achievements.bibliophile.id);
    await _box.put(_keyAchievements, achievements);
    return progress.copyWith(achievements: achievements);
  }

  Future<UserProgress> recordReadingMilestone() async {
    var progress = read();
    var achievements = List<String>.from(progress.achievements);
    achievements = _unlock(achievements, Achievements.scholar.id);
    await _box.put(_keyAchievements, achievements);
    return progress.copyWith(achievements: achievements);
  }

  List<String> _unlock(List<String> current, String id) {
    if (current.contains(id)) return current;
    return [...current, id];
  }
}