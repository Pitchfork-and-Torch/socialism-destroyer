import 'package:uuid/uuid.dart';

import '../../../models/claim.dart';
import '../../../models/crusher_result.dart';
import '../../../models/source.dart' show Source, SourceType;
import '../../../models/topic.dart' show Topic;
import '../../../services/knowledge_service.dart';
import 'argument_analyzer.dart';
import 'claim_retrieval_backend.dart';
import 'llm_crusher_backend.dart';

/// Orchestrates intent analysis → hybrid retrieval → curated/composed response.
///
/// New claims in JSON seeds automatically improve matching via FTS reindex +
/// [Claim.ragText] embedding overlap — no crusher code changes required.
class CrusherService {
  CrusherService({
    required this._knowledge,
    required this._retrieval,
    ArgumentAnalyzer? analyzer,
    LlmCrusherBackend? llm,
  })  : _analyzer = analyzer ?? ArgumentAnalyzer(),
        _llm = llm ?? LlmCrusherBackend();

  final KnowledgeService _knowledge;
  final ClaimRetrievalBackend _retrieval;
  final ArgumentAnalyzer _analyzer;
  final LlmCrusherBackend _llm;
  static const _uuid = Uuid();

  static const _curatedThreshold = 0.68;
  static const _composedThreshold = 0.42;

  Future<CrusherResult> crush(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Input cannot be empty');
    }

    final baseAnalysis = _analyzer.analyze(trimmed);

    // Dual-query retrieval: raw input + synonym-expanded corpus.
    final hitsRaw = await _retrieval.retrieve(trimmed, limit: 8);
    final hitsExpanded =
        await _retrieval.retrieve(baseAnalysis.expandedQuery, limit: 8);
    final hits = _mergeHits(hitsRaw, hitsExpanded);

    final claims = await _knowledge.getClaims();
    final claimMap = {for (final c in claims) c.id: c};

    final ranked = ClaimRanker.rank(
      hits: hits,
      claimMap: claimMap,
      input: trimmed,
      analysis: baseAnalysis,
    );

    final topScore = ranked.isEmpty ? 0.0 : ranked.first.score;
    final analysis = InputAnalysis(
      normalizedInput: baseAnalysis.normalizedInput,
      expandedQuery: baseAnalysis.expandedQuery,
      keyPhrases: baseAnalysis.keyPhrases,
      detectedTopicIds: baseAnalysis.detectedTopicIds,
      suspectedFallacies: _mergeFallacies(baseAnalysis, ranked),
      matchConfidence: (topScore / 1.5).clamp(0, 1),
      intentLabel: baseAnalysis.intentLabel,
    );

    CrusherResult result;
    if (topScore >= _curatedThreshold && ranked.isNotEmpty) {
      result = _buildCurated(trimmed, analysis, ranked);
    } else if (topScore >= _composedThreshold && ranked.isNotEmpty) {
      result = _buildComposed(trimmed, analysis, ranked);
    } else {
      result = _buildFallback(trimmed, analysis, ranked);
    }

    if (_llm.isAvailable) {
      final enhanced = await _llm.enhance(result);
      if (enhanced != null) {
        result = _copyWith(
          result,
          mode: CrusherResponseMode.llmEnhanced,
          executiveSummary: enhanced.executiveSummary,
          evidenceBullets: enhanced.evidenceBullets,
          whyItMatters: enhanced.whyItMatters ?? result.whyItMatters,
        );
      }
    }

    final enrichedTopics = await _resolveTopicRefs(result.matchedClaims, claimMap);
    final withRelated = await _attachRelatedClaims(result, claimMap);

    return _copyWith(
      withRelated,
      relatedTopics: enrichedTopics,
    );
  }

  List<RetrievalHit> _mergeHits(
    List<RetrievalHit> rawHits,
    List<RetrievalHit> expandedHits,
  ) {
    final map = <String, RetrievalHit>{};

    void absorb(List<RetrievalHit> hits, double weight) {
      for (final h in hits) {
        final prev = map[h.claimId];
        final weighted = h.score * weight;
        if (prev == null) {
          map[h.claimId] = RetrievalHit(
            claimId: h.claimId,
            score: weighted,
            method: h.method,
            rank: h.rank,
          );
        } else {
          map[h.claimId] = RetrievalHit(
            claimId: h.claimId,
            score: prev.score + weighted * 0.5,
            method: prev.method,
            rank: prev.rank,
          );
        }
      }
    }

    // Raw user input dominates; expanded synonyms are supporting signal only.
    absorb(rawHits, 1.25);
    absorb(expandedHits, 0.55);
    return map.values.toList()
      ..sort((x, y) => y.score.compareTo(x.score));
  }

  CrusherResult _buildCurated(
    String input,
    InputAnalysis analysis,
    List<MatchedClaimRef> ranked,
  ) {
    final primary = ranked.first.claim;
    final supporting = ranked.skip(1).take(2).map((r) => r.claim).toList();
    return CrusherResult(
      id: _uuid.v4(),
      inputText: input,
      analysis: analysis,
      mode: CrusherResponseMode.curated,
      executiveSummary: primary.executiveSummary,
      evidenceBullets: primary.evidenceBullets,
      sources: primary.sources,
      fallacies: _uniqueFallacies([...analysis.suspectedFallacies, ...primary.fallacies]),
      relatedTopics: _relatedTopics([primary, ...supporting]),
      matchedClaims: ranked.take(3).toList(),
      whyItMatters: primary.whyItMatters,
      steelmannedOpponentClaim: primary.socialistClaimText,
      primaryClaimTitle: primary.title,
      createdAt: DateTime.now(),
    );
  }

  CrusherResult _buildComposed(
    String input,
    InputAnalysis analysis,
    List<MatchedClaimRef> ranked,
  ) {
    final top = ranked.take(3).map((r) => r.claim).toList();
    final summary = StringBuffer()
      ..writeln(top.first.executiveSummary);
    if (top.length > 1) {
      summary.writeln();
      summary.write('This argument touches multiple evidence-backed angles: ');
      summary.write(top.skip(1).map((c) => c.title).join('; '));
      summary.write('.');
    }

    final evidence = <String>[];
    final sources = <Source>[];
    final fallacies = <String>[];
    for (final c in top) {
      evidence.addAll(c.evidenceBullets);
      sources.addAll(c.sources);
      fallacies.addAll(c.fallacies);
    }

    return CrusherResult(
      id: _uuid.v4(),
      inputText: input,
      analysis: analysis,
      mode: CrusherResponseMode.composed,
      executiveSummary: summary.toString().trim(),
      evidenceBullets: evidence.take(8).toList(),
      sources: _dedupeSources(sources),
      fallacies: _uniqueFallacies([...analysis.suspectedFallacies, ...fallacies]),
      relatedTopics: _relatedTopics(top),
      matchedClaims: ranked.take(3).toList(),
      whyItMatters: top.first.whyItMatters,
      steelmannedOpponentClaim: top.first.socialistClaimText,
      primaryClaimTitle: top.first.title,
      createdAt: DateTime.now(),
    );
  }

  CrusherResult _buildFallback(
    String input,
    InputAnalysis analysis,
    List<MatchedClaimRef> ranked,
  ) {
    final claims = ranked.map((r) => r.claim).toList();
    final primary = claims.isNotEmpty ? claims.first : null;
    return CrusherResult(
      id: _uuid.v4(),
      inputText: input,
      analysis: analysis,
      mode: CrusherResponseMode.composed,
      executiveSummary: primary != null
          ? 'Closest match: ${primary.title}. ${primary.executiveSummary}'
          : 'No exact curated match yet — browse the Topic Tree or rephrase with specific claims '
              '(e.g. exploitation, inequality, Nordic model). Markets coordinate dispersed knowledge; '
              'voluntary exchange raises living standards when property rights and rule of law hold.',
      evidenceBullets: primary?.evidenceBullets ??
          const [
            'Heritage Index of Economic Freedom correlates prosperity with rule of law and open markets.',
            'World Bank: extreme poverty fell dramatically as market participation expanded globally.',
          ],
      sources: primary?.sources ??
          const [
            Source(
              title: 'Heritage Foundation — Index of Economic Freedom',
              url: 'https://www.heritage.org/index',
              type: SourceType.academic,
            ),
            Source(
              title: 'World Bank — Poverty and Shared Prosperity',
              url: 'https://www.worldbank.org/en/publication/poverty-and-shared-prosperity',
              type: SourceType.government,
            ),
          ],
      fallacies: analysis.suspectedFallacies,
      relatedTopics: _relatedTopics(claims),
      matchedClaims: ranked.take(3).toList(),
      whyItMatters: primary?.whyItMatters ??
          'Unchallenged bad economics erodes support for the institutions that protect life, liberty, and property.',
      steelmannedOpponentClaim: primary?.socialistClaimText,
      primaryClaimTitle: primary?.title,
      createdAt: DateTime.now(),
    );
  }

  Future<CrusherResult> _attachRelatedClaims(
    CrusherResult result,
    Map<String, Claim> claimMap,
  ) async {
    final primary = result.primaryClaim;
    if (primary == null || primary.relatedClaimIds.isEmpty) return result;

    final existing = result.matchedClaims.map((m) => m.claim.id).toSet();
    final extra = <MatchedClaimRef>[];
    for (final id in primary.relatedClaimIds) {
      if (existing.contains(id)) continue;
      final c = claimMap[id];
      if (c == null) continue;
      extra.add(MatchedClaimRef(claim: c, score: 0.5, role: 'related'));
      if (extra.length >= 2) break;
    }
    if (extra.isEmpty) return result;

    return _copyWith(
      result,
      matchedClaims: [...result.matchedClaims, ...extra],
    );
  }

  List<RelatedTopicRef> _relatedTopics(List<Claim> claims) {
    final ids = claims.map((c) => c.topicId).toSet();
    return ids
        .map((id) => RelatedTopicRef(id: id, title: id))
        .take(6)
        .toList();
  }

  Future<List<RelatedTopicRef>> _resolveTopicRefs(
    List<MatchedClaimRef> matched,
    Map<String, Claim> claimMap,
  ) async {
    final roots = await _knowledge.getTopics();
    final flat = _flattenTopics(roots);
    final byId = {for (final t in flat) t.id: t};

    final ids = <String>{};
    for (final m in matched) {
      ids.add(m.claim.topicId);
      final related = m.claim.relatedClaimIds;
      for (final rid in related) {
        final rc = claimMap[rid];
        if (rc != null) ids.add(rc.topicId);
      }
    }

    return ids
        .where(byId.containsKey)
        .map(
          (id) => RelatedTopicRef(
            id: id,
            title: byId[id]!.title,
            description: byId[id]!.description,
          ),
        )
        .take(8)
        .toList();
  }

  List<Topic> _flattenTopics(List<Topic> roots) {
    final out = <Topic>[];
    void walk(Topic t) {
      out.add(t);
      for (final c in t.children) {
        walk(c);
      }
    }
    for (final r in roots) {
      walk(r);
    }
    return out;
  }

  List<String> _mergeFallacies(
    InputAnalysis analysis,
    List<MatchedClaimRef> ranked,
  ) {
    final fromClaims = ranked.expand((r) => r.claim.fallacies);
    return _uniqueFallacies([...analysis.suspectedFallacies, ...fromClaims]);
  }

  List<String> _uniqueFallacies(Iterable<String> raw) {
    final seen = <String>{};
    final out = <String>[];
    for (final f in raw) {
      final key = f.toLowerCase().trim();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      out.add(f);
    }
    return out;
  }

  List<Source> _dedupeSources(List<Source> sources) {
    final seen = <String>{};
    return sources.where((s) {
      final key = s.url;
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  CrusherResult _copyWith(
    CrusherResult r, {
    CrusherResponseMode? mode,
    String? executiveSummary,
    List<String>? evidenceBullets,
    String? whyItMatters,
    List<RelatedTopicRef>? relatedTopics,
    List<MatchedClaimRef>? matchedClaims,
  }) =>
      CrusherResult(
        id: r.id,
        inputText: r.inputText,
        analysis: r.analysis,
        mode: mode ?? r.mode,
        executiveSummary: executiveSummary ?? r.executiveSummary,
        evidenceBullets: evidenceBullets ?? r.evidenceBullets,
        sources: r.sources,
        fallacies: r.fallacies,
        relatedTopics: relatedTopics ?? r.relatedTopics,
        matchedClaims: matchedClaims ?? r.matchedClaims,
        whyItMatters: whyItMatters ?? r.whyItMatters,
        steelmannedOpponentClaim: r.steelmannedOpponentClaim,
        primaryClaimTitle: r.primaryClaimTitle,
        createdAt: r.createdAt,
      );
}