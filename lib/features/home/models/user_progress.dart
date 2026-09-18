import 'package:equatable/equatable.dart';

/// Local streak and achievement state persisted in Hive.
class UserProgress extends Equatable {
  const UserProgress({
    this.streakDays = 0,
    this.totalCrushes = 0,
    this.achievements = const [],
    this.lastVisitDate,
  });

  final int streakDays;
  final int totalCrushes;
  final List<String> achievements;
  final DateTime? lastVisitDate;

  UserProgress copyWith({
    int? streakDays,
    int? totalCrushes,
    List<String>? achievements,
    DateTime? lastVisitDate,
  }) =>
      UserProgress(
        streakDays: streakDays ?? this.streakDays,
        totalCrushes: totalCrushes ?? this.totalCrushes,
        achievements: achievements ?? this.achievements,
        lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      );

  @override
  List<Object?> get props => [streakDays, totalCrushes, achievements, lastVisitDate];
}

/// Display metadata for unlocked achievement badges.
class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });

  final String id;
  final String label;
  final String icon;
  final String description;
}

abstract final class Achievements {
  static const welcome = AchievementDef(
    id: 'welcome',
    label: 'Patriot',
    icon: 'flag',
    description: 'Opened the liberty engine',
  );
  static const streak3 = AchievementDef(
    id: 'streak_3',
    label: '3-Day Streak',
    icon: 'local_fire_department',
    description: 'Three days of truth-seeking',
  );
  static const streak7 = AchievementDef(
    id: 'streak_7',
    label: 'Week Warrior',
    icon: 'military_tech',
    description: 'Seven-day streak',
  );
  static const firstCrush = AchievementDef(
    id: 'first_crush',
    label: 'First Crush',
    icon: 'bolt',
    description: 'Crushed your first argument',
  );
  static const explorer = AchievementDef(
    id: 'explorer',
    label: 'Explorer',
    icon: 'account_tree',
    description: 'Browsed the topic tree',
  );
  static const scholar = AchievementDef(
    id: 'scholar',
    label: 'Scholar',
    icon: 'menu_book',
    description: 'Read 25% of a classic text',
  );
  static const bibliophile = AchievementDef(
    id: 'bibliophile',
    label: 'Bibliophile',
    icon: 'auto_stories',
    description: 'Opened the public-domain library',
  );

  static const all = [
    welcome,
    streak3,
    streak7,
    firstCrush,
    explorer,
    scholar,
    bibliophile,
  ];

  static AchievementDef? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}