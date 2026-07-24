import '../models/claim.dart';
import '../utils/app_constants.dart';
import 'database_service.dart';
import 'knowledge_service.dart';

/// Hybrid search: SQLite FTS5 on native/desktop, fuzzy ranking as tiebreaker.
class SearchService {
  SearchService(this._knowledge);

  final KnowledgeService _knowledge;
  Map<String, Claim>? _claimMapCache;
  final Map<String, List<Claim>> _queryCache = {};

  Future<Map<String, Claim>> _claimMap() async {
    if (_claimMapCache != null) return _claimMapCache!;
    final claims = await _knowledge.getClaims();
    _claimMapCache = {for (final c in claims) c.id: c};
    return _claimMapCache!;
  }

  void invalidateCache() {
    _claimMapCache = null;
    _queryCache.clear();
  }

  Future<List<Claim>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    if (trimmed.length < 2) return [];

    final cached = _queryCache[trimmed.toLowerCase()];
    if (cached != null) return cached;

    final claimMap = await _claimMap();

    // FTS path
    final ftsIds = await DatabaseService.instance.searchClaimIds(
      trimmed,
      limit: AppConstants.maxSearchResults,
    );

    if (ftsIds.isNotEmpty) {
      final results = ftsIds
          .map((id) => claimMap[id])
          .whereType<Claim>()
          .toList();
      _queryCache[trimmed.toLowerCase()] = results;
      return results;
    }

    // Fuzzy fallback
    final terms = trimmed.toLowerCase().split(RegExp(r'\s+'));
    final scored = <Claim, int>{};
    for (final claim in claimMap.values) {
      final haystack = claim.searchText.toLowerCase();
      var score = 0;
      for (final term in terms) {
        if (haystack.contains(term)) score += term.length;
        if (claim.title.toLowerCase().contains(term)) score += 10;
        if (claim.tags.any((t) => t.toLowerCase().contains(term))) score += 5;
      }
      if (score > 0) scored[claim] = score;
    }

    final results = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final output = results
        .take(AppConstants.maxSearchResults)
        .map((e) => e.key)
        .toList();
    _queryCache[trimmed.toLowerCase()] = output;
    return output;
  }
}