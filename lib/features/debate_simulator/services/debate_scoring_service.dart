import '../../../models/crusher_result.dart';
import '../../../models/debate_session.dart';
import '../../crusher/services/argument_analyzer.dart';
import '../../tree/data/fallacy_catalog.dart';

/// Offline scoring of user rebuttals against curated evidence and debate hygiene.
///
/// Heuristics only — no network. Designed to coach, not grade identity.
class DebateScoringService {
  DebateScoringService({ArgumentAnalyzer? analyzer})
      : _analyzer = analyzer ?? ArgumentAnalyzer();

  final ArgumentAnalyzer _analyzer;

  static final _sourcePatterns = RegExp(
    r'\b(bls|bea|census|cbo|world bank|heritage|fraser|chetty|doi\.org|'
    r'fed\.|federal reserve|gao|nber|jstor|ssrn|oecd|imf|who |cdc |'
    r'bureau of labor|congressional budget|peer[- ]reviewed|primary source|'
    r'according to|data show|dataset|study finds?|paper shows)\b',
    caseSensitive: false,
  );

  static final _numberPattern = RegExp(r'\b\d+(\.\d+)?%?\b');

  static final _mechanismPatterns = RegExp(
    r'\b(incentive|trade[- ]off|opportunity cost|unintended|calculation problem|'
    r'subjective value|price signal|property rights|rule of law|mobility|'
    r'absolute poverty|consumption|productivity|innovation|risk|capital)\b',
    caseSensitive: false,
  );

  static final _adHominemPatterns = RegExp(
    r'\b(idiot|stupid|moron|brainwashed|sheep|npc|libtard|commie scum|'
    r'you people are|shut up)\b',
    caseSensitive: false,
  );

  /// Score a user's rebuttal relative to the active steelman / engine context.
  TurnFeedback score({
    required String userText,
    CrusherResult? context,
    List<String> priorEngineEvidence = const [],
  }) {
    final trimmed = userText.trim();
    final analysis = _analyzer.analyze(trimmed);
    final lower = trimmed.toLowerCase();

    final evidenceHits = _countEvidenceOverlap(
      lower,
      context: context,
      priorEngineEvidence: priorEngineEvidence,
    );
    final hasSourceLanguage = _sourcePatterns.hasMatch(trimmed);
    final numberCount = _numberPattern.allMatches(trimmed).length;
    final mechanismHits = _mechanismPatterns.allMatches(lower).length;
    final wordCount = trimmed
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final adHominem = _adHominemPatterns.hasMatch(lower);
    final fallaciesInUser = analysis.suspectedFallacies;

    // Evidence: cite sources, reuse curated facts, quantify.
    final sourceMentions = _sourcePatterns.allMatches(trimmed).length;
    var evidenceScore = 18;
    evidenceScore += (evidenceHits * 12).clamp(0, 40);
    if (hasSourceLanguage) evidenceScore += 22;
    evidenceScore += (sourceMentions * 6).clamp(0, 18);
    evidenceScore += (numberCount * 6).clamp(0, 18);
    if (context != null && context.sources.isNotEmpty && hasSourceLanguage) {
      evidenceScore += 8;
    }
    evidenceScore = evidenceScore.clamp(0, 100);

    // Specificity: length, mechanisms, topic lock.
    var specificityScore = 20;
    if (wordCount >= 40) specificityScore += 15;
    if (wordCount >= 80) specificityScore += 10;
    if (wordCount >= 140) specificityScore += 5;
    if (wordCount < 20) specificityScore -= 25;
    specificityScore += (mechanismHits * 10).clamp(0, 30);
    if (analysis.detectedTopicIds.isNotEmpty) specificityScore += 10;
    if (analysis.keyPhrases.length >= 2) specificityScore += 8;
    specificityScore = specificityScore.clamp(0, 100);

    // Fallacy awareness: avoid repeating opponent fallacies; name them; no ad hominem.
    var fallacyScore = 55;
    if (context != null) {
      final opponentFalls =
          context.fallacies.map((f) => f.toLowerCase()).toSet();
      final named = opponentFalls.where((f) => lower.contains(f)).length;
      fallacyScore += (named * 12).clamp(0, 24);
      // User text that re-introduces labor-theory style fallacies as if true loses points.
      for (final f in fallaciesInUser) {
        if (opponentFalls.contains(f.toLowerCase())) {
          fallacyScore -= 8;
        }
      }
    }
    if (adHominem) fallacyScore -= 35;
    if (fallaciesInUser.isEmpty && wordCount >= 30) fallacyScore += 10;
    fallacyScore = fallacyScore.clamp(0, 100);

    final overall = ((evidenceScore * 0.45) +
            (specificityScore * 0.30) +
            (fallacyScore * 0.25))
        .round()
        .clamp(0, 100);

    final strengths = <String>[];
    final improvements = <String>[];

    if (evidenceHits >= 2 || hasSourceLanguage) {
      strengths.add('Grounded the reply in data language or curated evidence.');
    }
    if (mechanismHits >= 1) {
      strengths.add('Used incentive / mechanism reasoning, not slogans.');
    }
    if (wordCount >= 60) {
      strengths.add('Enough length to develop a real counter-case.');
    }
    if (!adHominem) {
      strengths.add('Avoided ad hominem — stayed on institutions and evidence.');
    }
    if (context != null &&
        context.fallacies.any((f) => lower.contains(f.toLowerCase()))) {
      strengths.add('Named a logical fallacy in the opponent claim.');
    }

    if (!hasSourceLanguage && numberCount == 0) {
      improvements.add(
        'Cite a primary source (BLS, Census, CBO, peer-reviewed paper) or a concrete statistic.',
      );
    }
    if (evidenceHits == 0 && (context?.evidenceBullets.isNotEmpty ?? false)) {
      improvements.add(
        'Reuse or steelman one of the engine’s evidence bullets, then extend it.',
      );
    }
    if (wordCount < 40) {
      improvements.add(
        'Expand the rebuttal: steelman → mechanism → one data point → stakes.',
      );
    }
    if (adHominem) {
      improvements.add(
        'Drop personal attacks; socialism fails on incentives and history, not insults.',
      );
    }
    if (fallaciesInUser.isNotEmpty) {
      improvements.add(
        'Watch for: ${fallaciesInUser.take(2).join(', ')}. '
        'Name the fallacy and replace it with a market or historical mechanism.',
      );
    }
    if (context?.sources.isNotEmpty == true && !hasSourceLanguage) {
      final sample = context!.sources.first;
      improvements.add(
        'Anchor to a source already in play: ${sample.citation ?? sample.title}.',
      );
    }
    if (strengths.isEmpty) {
      strengths.add('Showed up to practice — keep iterating with sources.');
    }
    if (improvements.isEmpty) {
      improvements.add(
        'Optional polish: add a library primary (Bastiat, Sowell catalog, Federalist) for rhetorical force.',
      );
    }

    final matchedIds = <String>{
      ...?context?.matchedClaimIds,
      ...analysis.detectedTopicIds,
    };

    final summary =
        'Score $overall/100 (${_grade(overall)}). '
        'Evidence $evidenceScore · Specificity $specificityScore · '
        'Fallacy discipline $fallacyScore.';

    return TurnFeedback(
      overallScore: overall,
      evidenceScore: evidenceScore,
      specificityScore: specificityScore,
      fallacyAwarenessScore: fallacyScore,
      strengths: strengths.take(4).toList(),
      improvements: improvements.take(4).toList(),
      detectedFallacies: fallaciesInUser,
      matchedClaimIds: matchedIds.take(8).toList(),
      summary: summary,
    );
  }

  String _grade(int score) {
    if (score >= 85) return 'Debate-ready';
    if (score >= 70) return 'Strong';
    if (score >= 55) return 'Solid foundation';
    if (score >= 40) return 'Needs sources';
    return 'Rebuild with evidence';
  }

  int _countEvidenceOverlap(
    String lower, {
    CrusherResult? context,
    List<String> priorEngineEvidence = const [],
  }) {
    final corpus = <String>[
      ...?context?.evidenceBullets,
      ...?context?.executiveSummary.split(RegExp(r'[.!?]\s+')),
      ...priorEngineEvidence,
    ];
    var hits = 0;
    for (final bullet in corpus) {
      final tokens = bullet
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((t) => t.length > 4)
          .toSet();
      if (tokens.isEmpty) continue;
      var overlap = 0;
      for (final t in tokens) {
        if (lower.contains(t)) overlap++;
      }
      if (overlap >= 2) hits++;
    }
    return hits;
  }

  /// Human-readable fallacy tip for coaching chips.
  String? tipForFallacy(String fallacyId) {
    final entry = FallacyCatalog.resolve(fallacyId);
    return entry?.counterTip;
  }
}
