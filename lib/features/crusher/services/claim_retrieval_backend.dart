import 'dart:math' as math;

import '../../../models/claim.dart';
import '../../../models/crusher_result.dart';
import '../../../services/knowledge_service.dart';
import '../../../services/search_service.dart';

/// Abstraction for claim retrieval — FTS + local embedding overlap today;
/// swap in Vectorize/pgvector via [VectorClaimRetrievalBackend] when ready.
abstract class ClaimRetrievalBackend {
  Future<List<RetrievalHit>> retrieve(String query, {int limit = 8});
}

/// SQLite FTS5 + fuzzy fallback (production path).
class FtsClaimRetrievalBackend implements ClaimRetrievalBackend {
  FtsClaimRetrievalBackend(this._search);

  final SearchService _search;

  @override
  Future<List<RetrievalHit>> retrieve(String query, {int limit = 8}) async {
    final claims = await _search.search(query);
    return claims
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map(
          (e) => RetrievalHit(
            claimId: e.value.id,
            score: 1.0 - (e.key * 0.08),
            method: RetrievalMethod.fts,
            rank: e.key,
          ),
        )
        .toList();
  }
}

/// Local token overlap on [Claim.ragText] — bridge until cloud vectors ship.
class EmbeddingOverlapRetrievalBackend implements ClaimRetrievalBackend {
  EmbeddingOverlapRetrievalBackend(this._knowledge);

  final KnowledgeService _knowledge;
  List<Claim>? _claims;

  @override
  Future<List<RetrievalHit>> retrieve(String query, {int limit = 8}) async {
    _claims ??= await _knowledge.getClaims();
    final terms = _tokenize(query);
    if (terms.isEmpty) return const [];

    final scored = <RetrievalHit>[];
    for (final claim in _claims!) {
      final corpus = _tokenize(
        '${claim.ragText} ${claim.socialistClaimText} ${claim.title}',
      );
      if (corpus.isEmpty) continue;

      var overlap = 0;
      for (final t in terms) {
        if (corpus.contains(t)) overlap++;
      }
      if (overlap == 0) continue;

      final score = overlap / terms.length;
      scored.add(
        RetrievalHit(
          claimId: claim.id,
          score: score.clamp(0, 1),
          method: RetrievalMethod.embedding,
          rank: 0,
        ),
      );
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map(
          (e) => RetrievalHit(
            claimId: e.value.claimId,
            score: e.value.score,
            method: e.value.method,
            rank: e.key,
          ),
        )
        .toList();
  }

  Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\$]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();
  }
}

/// Offline local-vector retrieval via hashed bag-of-words + cosine similarity.
///
/// Bridges to future cloud Vectorize/pgvector: same interface; set [enabled]
/// and swap implementation without touching hybrid merge or UI.
class VectorClaimRetrievalBackend implements ClaimRetrievalBackend {
  VectorClaimRetrievalBackend({
    required KnowledgeService knowledge,
    this.enabled = true,
    this.dimensions = 256,
  }) : _knowledge = knowledge;

  final KnowledgeService _knowledge;
  final bool enabled;
  final int dimensions;

  List<Claim>? _claims;
  final Map<String, List<double>> _vectorCache = {};

  @override
  Future<List<RetrievalHit>> retrieve(String query, {int limit = 8}) async {
    if (!enabled) return const [];
    _claims ??= await _knowledge.getClaims();
    final qVec = _embed(query);
    if (_l2(qVec) < 1e-9) return const [];

    final scored = <RetrievalHit>[];
    for (final claim in _claims!) {
      final cVec = _vectorCache.putIfAbsent(
        claim.id,
        () => _embed(
          '${claim.ragText} ${claim.socialistClaimText} ${claim.title} '
          '${claim.tags.join(' ')} ${claim.executiveSummary}',
        ),
      );
      final sim = _cosine(qVec, cVec);
      if (sim < 0.08) continue;
      scored.add(
        RetrievalHit(
          claimId: claim.id,
          score: sim.clamp(0, 1),
          method: RetrievalMethod.vector,
          rank: 0,
        ),
      );
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map(
          (e) => RetrievalHit(
            claimId: e.value.claimId,
            score: e.value.score,
            method: RetrievalMethod.vector,
            rank: e.key,
          ),
        )
        .toList();
  }

  List<double> _embed(String text) {
    final vec = List<double>.filled(dimensions, 0);
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2);
    for (final t in tokens) {
      // Stable FNV-1a style hash → bucket + signed weight.
      var h = 2166136261;
      for (final c in t.codeUnits) {
        h ^= c;
        h = (h * 16777619) & 0x7fffffff;
      }
      final idx = h % dimensions;
      final sign = (h & 1) == 0 ? 1.0 : -1.0;
      // Sublinear TF-style boost for length.
      vec[idx] += sign * (1.0 + (t.length > 6 ? 0.15 : 0));
    }
    // L2 normalize for cosine.
    final n = _l2(vec);
    if (n < 1e-9) return vec;
    for (var i = 0; i < vec.length; i++) {
      vec[i] /= n;
    }
    return vec;
  }

  double _l2(List<double> v) {
    var s = 0.0;
    for (final x in v) {
      s += x * x;
    }
    return s > 0 ? math.sqrt(s) : 0;
  }

  double _cosine(List<double> a, List<double> b) {
    var dot = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }
}

/// Merges FTS + embedding overlap + optional cloud vector hits.
class HybridClaimRetrievalBackend implements ClaimRetrievalBackend {
  HybridClaimRetrievalBackend({
    required this._fts,
    required this._embedding,
    this._vector,
  });

  final ClaimRetrievalBackend _fts;
  final ClaimRetrievalBackend _embedding;
  final ClaimRetrievalBackend? _vector;

  @override
  Future<List<RetrievalHit>> retrieve(String query, {int limit = 8}) async {
    final merged = <String, RetrievalHit>{};

    void absorb(List<RetrievalHit> hits, double weight) {
      for (final h in hits) {
        final existing = merged[h.claimId];
        final blended = (h.score * weight) + (existing?.score ?? 0);
        merged[h.claimId] = RetrievalHit(
          claimId: h.claimId,
          score: blended,
          method: existing?.method ?? h.method,
          rank: h.rank,
        );
      }
    }

    if (_vector != null) {
      absorb(await _vector.retrieve(query, limit: limit), 1.2);
    }
    absorb(await _fts.retrieve(query, limit: limit), 1.0);
    absorb(await _embedding.retrieve(query, limit: limit), 0.85);

    final list = merged.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return list.take(limit).toList();
  }
}

/// Re-ranks retrieval hits against input analysis signals.
class ClaimRanker {
  static const _phraseClaimBoosts = <String, List<String>>{
    'exploit': ['exploitation-marx', 'profit-is-theft', 'wage-labor-voluntary-contract'],
    'working class': ['exploitation-marx', 'profit-is-theft'],
    'profit is theft': ['profit-is-theft'],
    'billionaire': ['billionaires-shouldnt-exist', 'fed-scf-wealth-share'],
    'nordic': ['nordic-socialist', 'nordic-capitalist'],
    'sweden': ['nordic-socialist', 'sweden-no-statutory-minimum-wage'],
    'venezuela': ['venezuela-sanctions'],
    'sanctions': ['venezuela-sanctions'],
    'minimum wage': ['minimum-wage-no-harm', 'minimum-wage-entry'],
    'rent control': ['rent-control-helps'],
    'healthcare': ['healthcare-right', 'healthcare-cost', 'singapore-healthcare-hsa'],
    'medicare': ['healthcare-right'],
    'mobility': ['intergenerational-mobility-chetty', 'mobility-dead'],
    'american dream': ['intergenerational-mobility-chetty'],
    'inequality': ['wealth-inequality-broken', 'gini-misused'],
    'gini': ['gini-misused'],
    'real socialism': ['ussr-not-real-socialism'],
    'not real socialism': ['ussr-not-real-socialism', 'cambodia-ignored'],
    'planning': ['calculation-impossible', 'mises-bureaucratic-managemen'],
    'worker coop': ['economic-democracy', 'worker-coops-superior'],
    'constitution': ['constitution-limits', 'natural-rights'],
  };

  static List<MatchedClaimRef> rank({
    required List<RetrievalHit> hits,
    required Map<String, Claim> claimMap,
    required String input,
    required InputAnalysis analysis,
  }) {
    final lower = input.toLowerCase();
    final scored = <MatchedClaimRef>[];

    for (final hit in hits) {
      final claim = claimMap[hit.claimId];
      if (claim == null) continue;

      var score = hit.score;
      final socialist = claim.socialistClaimText.toLowerCase();

      for (final phrase in analysis.keyPhrases) {
        final p = phrase.toLowerCase();
        if (socialist.contains(p)) score += 0.14;
        if (claim.searchText.toLowerCase().contains(p)) score += 0.09;
      }
      if (analysis.detectedTopicIds.isNotEmpty) {
        if (analysis.detectedTopicIds.contains(claim.topicId)) {
          score += 0.35;
        } else {
          score -= 0.3;
        }
      }

      if (lower.contains('exploit') && claim.topicId == 'profit-exploitation') {
        score += 0.25;
      }

      // Avoid housing claims hijacking generic labor-exploitation inputs.
      final housingIntent = lower.contains('rent') ||
          lower.contains('housing') ||
          lower.contains('landlord') ||
          lower.contains('zoning');
      if (!housingIntent &&
          (socialist.contains('housing') ||
              socialist.contains('landlord') ||
              socialist.contains('rent '))) {
        score -= 0.5;
      }

      for (final tag in claim.tags) {
        if (lower.contains(tag.toLowerCase())) score += 0.07;
      }

      var phraseBoosts = 0;
      for (final entry in _phraseClaimBoosts.entries) {
        if (lower.contains(entry.key) && entry.value.contains(claim.id)) {
          score += 0.28;
          phraseBoosts++;
        }
      }
      if (phraseBoosts >= 2) score += 0.2;

      // Token overlap between user input and steelmanned claim text.
      final inputTokens = lower.split(RegExp(r'\W+')).where((t) => t.length > 3);
      for (final token in inputTokens) {
        if (socialist.contains(token)) score += 0.04;
      }

      scored.add(
        MatchedClaimRef(claim: claim, score: score.clamp(0, 3), role: 'supporting'),
      );
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.isNotEmpty) {
      scored[0] = MatchedClaimRef(
        claim: scored[0].claim,
        score: scored[0].score,
        role: 'primary',
      );
    }
    return scored.take(8).toList();
  }
}