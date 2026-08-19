import 'package:hive_flutter/hive_flutter.dart';

/// Offline-first persistence for favorites, notes, reading progress, debate history.
class LocalStorageService {
  static const String favoritesBox = 'favorites';
  static const String notesBox = 'notes';
  static const String historyBox = 'debate_history';
  static const String debateSessionsBox = 'debate_sessions';
  static const String progressBox = 'reading_progress';
  static const String settingsBox = 'settings';
  static const String knowledgeOverlayBox = 'knowledge_overlay';

  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(favoritesBox),
      Hive.openBox<Map>(notesBox),
      Hive.openBox<Map>(historyBox),
      Hive.openBox<Map>(debateSessionsBox),
      Hive.openBox<Map>(progressBox),
      Hive.openBox(settingsBox),
      Hive.openBox<String>(knowledgeOverlayBox),
    ]);
  }

  Box<String> get favorites => Hive.box<String>(favoritesBox);
  Box<Map> get notes => Hive.box<Map>(notesBox);
  Box<Map> get debateHistory => Hive.box<Map>(historyBox);
  Box<Map> get debateSessions => Hive.box<Map>(debateSessionsBox);
  Box<Map> get readingProgress => Hive.box<Map>(progressBox);
  Box get settings => Hive.box(settingsBox);

  bool isFavorite(String claimId) => favorites.containsKey(claimId);

  Future<void> toggleFavorite(String claimId) async {
    if (favorites.containsKey(claimId)) {
      await favorites.delete(claimId);
    } else {
      await favorites.put(claimId, claimId);
    }
  }
}