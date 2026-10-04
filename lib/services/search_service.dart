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

    // FTS path (native). Empty on web / unindexed tests -> fuzzy pool.
    final ftsIds = await DatabaseService.instance.searchClaimIds(
      trimmed,
      limit: AppConstants.maxSearchResults,
    );

    final lower = trimmed.toLowerCase();
    final terms = lower
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2)
        .toList();

    final ftsHit = ftsIds.isNotEmpty;
    final pool = ftsHit
        ? ftsIds.map((id) => claimMap[id]).whereType<Claim>()
        : claimMap.values;

    final scored = <Claim, int>{};
    for (final claim in pool) {
      var score = _precisionScore(claim, lower, terms);
      if (ftsHit) score += 1; // keep FTS survivors; re-rank, do not drop
      if (score > 0) scored[claim] = score;
    }

    final results = scored.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        if (!ftsHit) return 0;
        return ftsIds.indexOf(a.key.id).compareTo(ftsIds.indexOf(b.key.id));
      });

    final output = results
        .take(AppConstants.maxSearchResults)
        .map((e) => e.key)
        .toList();
    _queryCache[trimmed.toLowerCase()] = output;
    return output;
  }

  /// Phrase + tag precision used for both FTS re-rank and fuzzy fallback.
  static int precisionScore(Claim claim, String lowerQuery, List<String> terms) =>
      _precisionScore(claim, lowerQuery, terms);

  static int _precisionScore(Claim claim, String lower, List<String> terms) {
    final haystack = claim.searchText.toLowerCase();
    final title = claim.title.toLowerCase();
    final socialist = claim.socialistClaimText.toLowerCase();
    var score = 0;

    if (title.contains(lower)) score += 40;
    if (socialist.contains(lower)) score += 28;
    if (haystack.contains(lower)) score += 18;

    for (final term in terms) {
      if (haystack.contains(term)) score += term.length;
      if (title.contains(term)) score += 12;
      if (socialist.contains(term)) score += 8;
      if (claim.tags.any((t) => t.toLowerCase().contains(term))) score += 6;
      if (claim.id.toLowerCase().contains(term)) score += 5;
    }
    return score;
  }
}