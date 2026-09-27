import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/crusher_result.dart';
import '../../../models/source.dart';
import '../../../models/user_interaction.dart';
import '../../../services/local_storage_service.dart';

/// Persists every crusher session to Hive (synced to Supabase when signed in).
class DebateHistoryService {
  DebateHistoryService({LocalStorageService? local})
      : _local = local ?? LocalStorageService();

  final LocalStorageService _local;
  static const _uuid = Uuid();

  Future<DebateHistoryEntry> save(CrusherResult result) async {
    final entry = DebateHistoryEntry(
      id: result.id,
      inputText: result.inputText,
      summary: result.executiveSummary,
      matchedClaimIds: result.matchedClaimIds,
      createdAt: result.createdAt,
    );

    await _local.debateHistory.put(entry.id, {
      'id': entry.id,
      'createdAt': entry.createdAt.toIso8601String(),
      ...entry.toPayload(),
      'mode': result.mode.name,
      'intentLabel': result.analysis.intentLabel,
      'matchConfidence': result.analysis.matchConfidence,
      'fallacies': result.fallacies,
      'relatedTopicIds': result.relatedTopics.map((t) => t.id).toList(),
      'result': result.toJson(),
    });

    return entry;
  }

  List<DebateHistoryEntry> listRecent({int limit = 50}) {
    final entries = _local.debateHistory.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    entries.sort((a, b) {
      final aDate = a['createdAt'] as String? ?? '';
      final bDate = b['createdAt'] as String? ?? '';
      return bDate.compareTo(aDate);
    });

    return entries.take(limit).map((raw) {
      final id = raw['id'] as String? ?? _uuid.v4();
      return DebateHistoryEntry.fromPayload(
        id: id,
        payload: raw,
        createdAt: raw['createdAt'] != null
            ? DateTime.parse(raw['createdAt'] as String)
            : DateTime.now(),
      );
    }).toList();
  }

  /// Rich metadata for history UI (mode, confidence, intent).
  List<DebateHistoryMeta> listRecentMeta({int limit = 50}) {
    final entries = _local.debateHistory.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    entries.sort((a, b) {
      final aDate = a['createdAt'] as String? ?? '';
      final bDate = b['createdAt'] as String? ?? '';
      return bDate.compareTo(aDate);
    });

    return entries.take(limit).map(DebateHistoryMeta.fromRaw).toList();
  }

  CrusherResult? loadResult(String id) {
    final raw = _local.debateHistory.get(id);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw);
    final resultJson = map['result'];
    if (resultJson is! Map) return null;
    return _resultFromStored(Map<String, dynamic>.from(resultJson));
  }

  CrusherResult? _resultFromStored(Map<String, dynamic> json) {
    try {
      return CrusherResult(
        id: json['id'] as String,
        inputText: json['inputText'] as String,
        analysis: InputAnalysis.fromJson(
          Map<String, dynamic>.from(json['analysis'] as Map),
        ),
        mode: CrusherResponseMode.values.byName(json['mode'] as String),
        executiveSummary: json['executiveSummary'] as String,
        evidenceBullets: (json['evidenceBullets'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        sources: (json['sources'] as List<dynamic>? ?? [])
            .map((e) => Source.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        fallacies: (json['fallacies'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        relatedTopics: (json['relatedTopics'] as List<dynamic>? ?? [])
            .map(
              (e) => RelatedTopicRef.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
        matchedClaims: const [],
        whyItMatters: json['whyItMatters'] as String,
        steelmannedOpponentClaim: json['steelmannedOpponentClaim'] as String?,
        primaryClaimTitle: json['primaryClaimTitle'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Pushes recent local debate rows to Supabase `profiles.debate_history`.
  Future<void> syncToProfile(String uid) async {
    try {
      final client = Supabase.instance.client;
      final recent = listRecent(limit: 30)
          .map(
            (e) => {
              'id': e.id,
              'inputText': e.inputText,
              'summary': e.summary,
              'matchedClaimIds': e.matchedClaimIds,
              'createdAt': e.createdAt.toIso8601String(),
            },
          )
          .toList();

      final row = await client
          .from('profiles')
          .select('debate_history')
          .eq('uid', uid)
          .maybeSingle();
      final existing = (row?['debate_history'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final byId = {for (final e in existing) e['id'] as String: e};
      for (final r in recent) {
        byId[r['id'] as String] = r;
      }
      final merged = byId.values.toList()
        ..sort((a, b) {
          final ad = a['createdAt'] as String? ?? '';
          final bd = b['createdAt'] as String? ?? '';
          return bd.compareTo(ad);
        });

      await client.from('profiles').update({
        'debate_history': merged.take(50).toList(),
      }).eq('uid', uid);
    } catch (_) {
      // Offline or Supabase not configured — local Hive is source of truth.
    }
  }
}

/// History list row with crusher metadata for the UI.
class DebateHistoryMeta {
  const DebateHistoryMeta({
    required this.id,
    required this.inputText,
    required this.summary,
    required this.createdAt,
    this.mode,
    this.matchConfidence,
    this.intentLabel,
  });

  final String id;
  final String inputText;
  final String summary;
  final DateTime createdAt;
  final CrusherResponseMode? mode;
  final double? matchConfidence;
  final String? intentLabel;

  factory DebateHistoryMeta.fromRaw(Map<String, dynamic> raw) {
    final modeName = raw['mode'] as String?;
    return DebateHistoryMeta(
      id: raw['id'] as String? ?? '',
      inputText: raw['inputText'] as String? ?? '',
      summary: raw['summary'] as String? ?? '',
      createdAt: raw['createdAt'] != null
          ? DateTime.parse(raw['createdAt'] as String)
          : DateTime.now(),
      mode: modeName != null
          ? CrusherResponseMode.values.byName(modeName)
          : null,
      matchConfidence: (raw['matchConfidence'] as num?)?.toDouble(),
      intentLabel: raw['intentLabel'] as String?,
    );
  }

  String get modeLabel => switch (mode) {
        CrusherResponseMode.curated => 'Curated',
        CrusherResponseMode.composed => 'Synthesized',
        CrusherResponseMode.llmEnhanced => 'AI-enhanced',
        null => 'Crushed',
      };
}