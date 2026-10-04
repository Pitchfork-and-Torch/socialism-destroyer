import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/claim_suggestion.dart';

class ClaimSuggestionException implements Exception {
  const ClaimSuggestionException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Stores moderated claim suggestions locally for curator review.
class ClaimSuggestionService {
  static const String _submissionsBoxName = 'claim_suggestions_local';
  static const String _draftBoxName = 'claim_suggestion_drafts';
  static const String _draftKey = 'pending_draft';

  Future<Box<dynamic>> _submissionsBox() async {
    if (!Hive.isBoxOpen(_submissionsBoxName)) {
      await Hive.openBox<dynamic>(_submissionsBoxName);
    }
    return Hive.box<dynamic>(_submissionsBoxName);
  }

  Future<Box<dynamic>> _draftBox() async {
    if (!Hive.isBoxOpen(_draftBoxName)) {
      await Hive.openBox<dynamic>(_draftBoxName);
    }
    return Hive.box<dynamic>(_draftBoxName);
  }

  Future<ClaimSuggestionDraft?> loadDraft() async {
    final box = await _draftBox();
    final raw = box.get(_draftKey);
    if (raw == null) return null;
    return ClaimSuggestionDraft.fromJson(
      Map<String, dynamic>.from(raw as Map),
    );
  }

  Future<void> saveDraft(ClaimSuggestionDraft draft) async {
    final box = await _draftBox();
    await box.put(_draftKey, draft.toJson());
  }

  Future<void> clearDraft() async {
    final box = await _draftBox();
    await box.delete(_draftKey);
  }

  Future<List<ClaimSuggestion>> fetchLocalSuggestions() async {
    final box = await _submissionsBox();
    final suggestions = <ClaimSuggestion>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        suggestions.add(
          ClaimSuggestion.fromJson(Map<String, dynamic>.from(raw)),
        );
      }
    }
    suggestions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return suggestions;
  }

  Future<ClaimSuggestion> submit({
    required String topicId,
    required String title,
    required String socialistClaim,
    required String counterSummary,
    required List<SuggestionSource> sources,
    String? notes,
  }) async {
    _validateSubmission(
      topicId: topicId,
      title: title,
      socialistClaim: socialistClaim,
      counterSummary: counterSummary,
      sources: sources,
    );

    final now = DateTime.now().toUtc();
    final id = 'local-${now.millisecondsSinceEpoch}';
    final suggestion = ClaimSuggestion(
      id: id,
      userId: 'anonymous',
      topicId: topicId,
      title: title.trim(),
      socialistClaim: socialistClaim.trim(),
      counterSummary: counterSummary.trim(),
      sources: sources,
      notes: notes?.trim(),
      status: SuggestionStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    final box = await _submissionsBox();
    await box.put(id, _suggestionToLocalJson(suggestion));
    await clearDraft();
    return suggestion;
  }

  void _validateSubmission({
    required String topicId,
    required String title,
    required String socialistClaim,
    required String counterSummary,
    required List<SuggestionSource> sources,
  }) {
    if (topicId.trim().isEmpty) {
      throw const ClaimSuggestionException('Select a topic category.');
    }
    if (title.trim().length < 8) {
      throw const ClaimSuggestionException('Title needs at least 8 characters.');
    }
    if (socialistClaim.trim().length < 20) {
      throw const ClaimSuggestionException(
        'Steelman the socialist claim in at least 20 characters.',
      );
    }
    if (counterSummary.trim().length < 40) {
      throw const ClaimSuggestionException(
        'Counter summary needs at least 40 characters with evidence direction.',
      );
    }
    if (sources.length < 2) {
      throw const ClaimSuggestionException(
        'Add at least two source links (government, academic, or primary).',
      );
    }
    for (final s in sources) {
      if (s.title.trim().isEmpty || s.url.trim().isEmpty) {
        throw const ClaimSuggestionException('Each source needs a title and URL.');
      }
      final uri = Uri.tryParse(s.url.trim());
      if (uri == null || !uri.hasScheme) {
        throw const ClaimSuggestionException('Source URLs must be valid http(s) links.');
      }
    }
  }

  Map<String, dynamic> _suggestionToLocalJson(ClaimSuggestion suggestion) => {
        'id': suggestion.id,
        'user_id': suggestion.userId,
        'topic_id': suggestion.topicId,
        'title': suggestion.title,
        'socialist_claim': suggestion.socialistClaim,
        'counter_summary': suggestion.counterSummary,
        'sources': suggestion.sources.map((s) => s.toJson()).toList(),
        if (suggestion.notes != null && suggestion.notes!.isNotEmpty)
          'notes': suggestion.notes,
        'status': suggestion.status.name,
        'created_at': suggestion.createdAt.toIso8601String(),
        'updated_at': suggestion.updatedAt.toIso8601String(),
      };

  /// Debug helper — serialize draft for tests.
  String encodeDraft(ClaimSuggestionDraft draft) =>
      jsonEncode(draft.toJson());
}