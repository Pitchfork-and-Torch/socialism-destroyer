import 'package:socialism_destroyer/features/crusher/services/claim_retrieval_backend.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';

/// In-memory retrieval for widget tests — avoids sqflite FFI under fake async.
class TestClaimRetrievalBackend implements ClaimRetrievalBackend {
  TestClaimRetrievalBackend(this._claims);

  final List<Claim> _claims;

  @override
  Future<List<RetrievalHit>> retrieve(String query, {int limit = 8}) async {
    final terms = query.toLowerCase().split(RegExp(r'\s+'));
    final scored = <Claim, int>{};

    for (final claim in _claims) {
      final haystack = claim.searchText.toLowerCase();
      var score = 0;
      for (final term in terms) {
        if (term.isEmpty) continue;
        if (haystack.contains(term)) score += term.length;
        if (claim.title.toLowerCase().contains(term)) score += 10;
        if (claim.tags.any((t) => t.toLowerCase().contains(term))) score += 5;
      }
      if (score > 0) scored[claim] = score;
    }

    final results = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return results.take(limit).toList().asMap().entries.map(
      (e) => RetrievalHit(
        claimId: e.value.key.id,
        score: 1.0 - (e.key * 0.08),
        method: RetrievalMethod.fts,
        rank: e.key,
      ),
    ).toList();
  }
}