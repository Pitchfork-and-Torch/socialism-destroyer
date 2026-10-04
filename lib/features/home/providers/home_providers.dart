import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../utils/app_constants.dart';
import '../models/user_progress.dart';
import '../services/user_progress_service.dart';

final userProgressServiceProvider = Provider<UserProgressService>((ref) {
  return UserProgressService(storage: ref.watch(localStorageProvider));
});

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, AsyncValue<UserProgress>>(
  (ref) => UserProgressNotifier(ref.watch(userProgressServiceProvider)),
);

class UserProgressNotifier extends StateNotifier<AsyncValue<UserProgress>> {
  UserProgressNotifier(
    this._service, {
    UserProgress? initialProgress,
    this.skipPersistence = false,
  }) : super(
          initialProgress != null
              ? AsyncData(initialProgress)
              : const AsyncLoading(),
        ) {
    if (initialProgress == null) {
      _init();
    }
  }

  final UserProgressService _service;

  /// Widget/golden tests — update in-memory state without Hive I/O stalls.
  final bool skipPersistence;

  Future<void> _init() async {
    try {
      final progress = await _service.recordVisit();
      state = AsyncData(progress);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> recordCrush() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (skipPersistence) {
      state = AsyncData(
        current.copyWith(totalCrushes: current.totalCrushes + 1),
      );
      return;
    }
    final updated = await _service.recordCrush();
    state = AsyncData(updated);
  }

  Future<void> recordTreeVisit() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (skipPersistence) {
      final achievements = current.achievements.contains(Achievements.explorer.id)
          ? current.achievements
          : [...current.achievements, Achievements.explorer.id];
      state = AsyncData(current.copyWith(achievements: achievements));
      return;
    }
    final updated = await _service.recordTreeVisit();
    state = AsyncData(updated);
  }

  Future<void> recordLibraryVisit() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (skipPersistence) {
      final achievements =
          current.achievements.contains(Achievements.bibliophile.id)
              ? current.achievements
              : [...current.achievements, Achievements.bibliophile.id];
      state = AsyncData(current.copyWith(achievements: achievements));
      return;
    }
    final updated = await _service.recordLibraryVisit();
    state = AsyncData(updated);
  }

  Future<void> recordReadingMilestone() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (skipPersistence) {
      final achievements = current.achievements.contains(Achievements.scholar.id)
          ? current.achievements
          : [...current.achievements, Achievements.scholar.id];
      state = AsyncData(current.copyWith(achievements: achievements));
      return;
    }
    final updated = await _service.recordReadingMilestone();
    state = AsyncData(updated);
  }
}

/// All daily insights for the rotating card carousel.
final allInsightsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final raw = await rootBundle.loadString(AppConstants.insightsAsset);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return (json['insights'] as List<dynamic>).map((e) {
    final m = e as Map<String, dynamic>;
    return {
      'id': m['id'] as String,
      'quote': m['quote'] as String,
      'author': m['author'] as String,
      'dataPoint': m['dataPoint'] as String,
      'source': m['source'] as String,
    };
  }).toList();
});

/// Quick-launch categories shown on the home hub.
class QuickCategory {
  const QuickCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.topicId,
  });

  final String id;
  final String title;
  final String icon;
  final String topicId;
}

const homeQuickCategories = [
  QuickCategory(
    id: 'wealth',
    title: 'Wealth & Mobility',
    icon: 'trending_up',
    topicId: 'wealth-inequality-mobility',
  ),
  QuickCategory(
    id: 'historical',
    title: 'Socialism Failures',
    icon: 'history_edu',
    topicId: 'historical-socialism',
  ),
  QuickCategory(
    id: 'nordic',
    title: 'Nordic Myth',
    icon: 'public',
    topicId: 'nordic-democratic-socialism',
  ),
  QuickCategory(
    id: 'profit',
    title: 'Profit & Exploitation',
    icon: 'insights',
    topicId: 'profit-exploitation',
  ),
  QuickCategory(
    id: 'founding',
    title: 'Founding Principles',
    icon: 'flag',
    topicId: 'founding-principles',
  ),
];