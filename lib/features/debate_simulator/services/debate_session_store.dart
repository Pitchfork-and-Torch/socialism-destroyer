import 'package:uuid/uuid.dart';

import '../../../models/debate_session.dart';
import '../../../services/local_storage_service.dart';

/// Hive-backed multi-turn debate sessions.
class DebateSessionStore {
  DebateSessionStore({LocalStorageService? local})
      : _local = local ?? LocalStorageService();

  final LocalStorageService _local;
  static const _uuid = Uuid();

  Future<void> save(DebateSession session) async {
    await _local.debateSessions.put(session.id, session.toJson());
  }

  DebateSession? load(String id) {
    final raw = _local.debateSessions.get(id);
    if (raw == null) return null;
    try {
      return DebateSession.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    await _local.debateSessions.delete(id);
  }

  List<DebateSession> listRecent({int limit = 30}) {
    final entries = _local.debateSessions.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    entries.sort((a, b) {
      final aDate = a['updatedAt'] as String? ?? '';
      final bDate = b['updatedAt'] as String? ?? '';
      return bDate.compareTo(aDate);
    });
    final out = <DebateSession>[];
    for (final raw in entries.take(limit)) {
      try {
        out.add(DebateSession.fromJson(raw));
      } catch (_) {
        // Skip corrupt rows.
      }
    }
    return out;
  }

  String newId() => _uuid.v4();
}
