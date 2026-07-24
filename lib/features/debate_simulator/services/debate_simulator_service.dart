import 'package:uuid/uuid.dart';

import '../../../models/claim.dart';
import '../../../models/crusher_result.dart';
import '../../../models/debate_session.dart';
import '../../../services/knowledge_service.dart';
import '../../crusher/services/crusher_service.dart';
import '../../crusher/services/llm_crusher_backend.dart';
import 'debate_scoring_service.dart';
import 'debate_session_store.dart';

/// Multi-turn Debate Simulator — offline-first, sourced via [CrusherService].
class DebateSimulatorService {
  DebateSimulatorService({
    required CrusherService crusher,
    required KnowledgeService knowledge,
    DebateSessionStore? store,
    DebateScoringService? scoring,
    LlmCrusherBackend? llm,
  })  : _crusher = crusher,
        _knowledge = knowledge,
        _store = store ?? DebateSessionStore(),
        _scoring = scoring ?? DebateScoringService(),
        _llm = llm ?? LlmCrusherBackend();

  final CrusherService _crusher;
  final KnowledgeService _knowledge;
  final DebateSessionStore _store;
  final DebateScoringService _scoring;
  final LlmCrusherBackend _llm;
  static const _uuid = Uuid();

  DebateSessionStore get store => _store;

  bool get llmAvailable => _llm.isAvailable;

  /// Start a new session. In [DebateMode.challenge], opens with engine steelman.
  Future<DebateSession> start({
    required DebateMode mode,
    String? seedArgument,
    String? claimId,
    String? topicId,
    String? title,
  }) async {
    final now = DateTime.now();
    final turns = <DebateTurn>[];

    String resolvedTitle = title?.trim().isNotEmpty == true
        ? title!.trim()
        : (mode == DebateMode.challenge
            ? 'Challenge mode'
            : 'Sparring session');

    Claim? seedClaim;
    if (claimId != null && claimId.isNotEmpty) {
      seedClaim = await _knowledge.getClaimById(claimId);
      if (seedClaim != null) {
        resolvedTitle = seedClaim.title;
      }
    }

    // System intro always offline.
    turns.add(
      DebateTurn(
        id: _uuid.v4(),
        role: DebateRole.system,
        text: mode == DebateMode.challenge
            ? 'Challenge mode: I will open with a steelmanned socialist claim. '
                'Write your best sourced rebuttal. You will receive a score on '
                'evidence strength, specificity, and fallacy discipline. '
                'Core matching is offline; optional AI polish is labeled when used.'
            : 'Spar mode: paste opponent arguments (tweets, slogans, essays). '
                'I return steelmanned counters with curated evidence and sources. '
                'You can Challenge your own draft for coaching scores anytime.',
        createdAt: now,
        label: 'Briefing',
      ),
    );

    if (mode == DebateMode.challenge) {
      final opening = await _buildChallengeOpening(
        seedArgument: seedArgument,
        seedClaim: seedClaim,
        topicId: topicId,
      );
      turns.add(opening.turn);
      if (opening.titleHint != null && title == null) {
        resolvedTitle = opening.titleHint!;
      }
    } else if (seedArgument != null && seedArgument.trim().isNotEmpty) {
      // Spar: optionally auto-run first opponent argument.
      final result = await _crusher.crush(seedArgument.trim());
      final engineText = _formatEngineReply(result);
      turns.add(
        DebateTurn(
          id: _uuid.v4(),
          role: DebateRole.user,
          text: seedArgument.trim(),
          createdAt: now,
          label: 'Opening argument',
        ),
      );
      turns.add(
        DebateTurn(
          id: _uuid.v4(),
          role: DebateRole.engine,
          text: engineText,
          createdAt: DateTime.now(),
          crusherResult: result,
          label: 'Counter',
        ),
      );
      resolvedTitle = _titleFromInput(seedArgument);
    } else if (seedClaim != null) {
      turns.add(
        DebateTurn(
          id: _uuid.v4(),
          role: DebateRole.system,
          text:
              'Seeded from claim “${seedClaim.title}”. Paste a live argument '
              'on this topic, or ask the opponent’s strongest version of the claim.',
          createdAt: DateTime.now(),
          label: 'Claim seed',
        ),
      );
    }

    final session = DebateSession(
      id: _store.newId(),
      mode: mode,
      title: resolvedTitle,
      turns: turns,
      createdAt: now,
      updatedAt: DateTime.now(),
      seedArgument: seedArgument,
      seedClaimId: claimId ?? seedClaim?.id,
      topicId: topicId ?? seedClaim?.topicId,
      llmAssisted: false,
    );
    await _store.save(session);
    return session;
  }

  /// User sends a message; engine responds (and scores in challenge / when requested).
  Future<DebateSession> userTurn(
    DebateSession session,
    String rawText, {
    bool requestScore = false,
  }) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }
    // Soft cap for pathological paste — keep last 12k chars for analysis.
    final bounded = text.length > 12000 ? text.substring(0, 12000) : text;

    final userTurn = DebateTurn(
      id: _uuid.v4(),
      role: DebateRole.user,
      text: bounded,
      createdAt: DateTime.now(),
      label: session.mode == DebateMode.challenge ? 'Your rebuttal' : 'Opponent',
    );

    final shouldScore =
        requestScore || session.mode == DebateMode.challenge;
    TurnFeedback? feedback;
    if (shouldScore) {
      feedback = _scoring.score(
        userText: bounded,
        context: session.latestEngineTurn?.crusherResult,
        priorEngineEvidence: _priorEvidence(session),
      );
    }

    final scoredUser = DebateTurn(
      id: userTurn.id,
      role: userTurn.role,
      text: userTurn.text,
      createdAt: userTurn.createdAt,
      label: userTurn.label,
      feedback: feedback,
    );

    // Engine reply: crush the latest opponent text (spar) or coach after score (challenge).
    CrusherResult result;
    String engineLabel;
    String engineText;

    if (session.mode == DebateMode.challenge) {
      // After user rebuttal: coach with matched claims + improvement path.
      result = await _crusher.crush(bounded);
      engineLabel = 'Coach + sources';
      engineText = _formatCoachReply(result, feedback);
    } else {
      result = await _crusher.crush(bounded);
      engineLabel = 'Counter';
      engineText = _formatEngineReply(result);
    }

    var llmUsed = session.llmAssisted;
    if (_llm.isAvailable) {
      final enhanced = await _llm.enhanceDebateTurn(
        userMessage: bounded,
        draft: result,
        priorTurns: session.turns.length,
      );
      if (enhanced != null) {
        result = _mergeLlm(result, enhanced);
        engineText = session.mode == DebateMode.challenge
            ? _formatCoachReply(result, feedback)
            : _formatEngineReply(result);
        llmUsed = true;
      }
    }

    final engineTurn = DebateTurn(
      id: _uuid.v4(),
      role: DebateRole.engine,
      text: engineText,
      createdAt: DateTime.now(),
      crusherResult: result,
      label: engineLabel,
    );

    final next = session.copyWith(
      turns: [...session.turns, scoredUser, engineTurn],
      updatedAt: DateTime.now(),
      title: session.userTurnCount == 0
          ? _titleFromInput(bounded)
          : session.title,
      llmAssisted: llmUsed,
    );
    await _store.save(next);
    return next;
  }

  /// Append a new Challenge steelman opening (timed drills / multi-round).
  Future<DebateSession> appendChallengeOpening(
    DebateSession session, {
    required String seedArgument,
    String? claimId,
  }) async {
    Claim? seedClaim;
    if (claimId != null && claimId.isNotEmpty) {
      seedClaim = await _knowledge.getClaimById(claimId);
    }
    final opening = await _buildChallengeOpening(
      seedArgument: seedArgument,
      seedClaim: seedClaim,
    );
    final next = session.copyWith(
      turns: [...session.turns, opening.turn],
      updatedAt: DateTime.now(),
    );
    await _store.save(next);
    return next;
  }

  /// Score the last user draft without advancing a full engine crush (spar tool).
  Future<DebateSession> scoreLastUserTurn(DebateSession session) async {
    DebateTurn? lastUser;
    var lastUserIndex = -1;
    for (var i = session.turns.length - 1; i >= 0; i--) {
      if (session.turns[i].role == DebateRole.user) {
        lastUser = session.turns[i];
        lastUserIndex = i;
        break;
      }
    }
    if (lastUser == null || lastUserIndex < 0) {
      throw StateError('No user turn to score');
    }

    final feedback = _scoring.score(
      userText: lastUser.text,
      context: session.latestEngineTurn?.crusherResult,
      priorEngineEvidence: _priorEvidence(session),
    );
    final updated = DebateTurn(
      id: lastUser.id,
      role: lastUser.role,
      text: lastUser.text,
      createdAt: lastUser.createdAt,
      label: lastUser.label,
      crusherResult: lastUser.crusherResult,
      feedback: feedback,
    );
    final turns = [...session.turns];
    turns[lastUserIndex] = updated;
    final next = session.copyWith(turns: turns, updatedAt: DateTime.now());
    await _store.save(next);
    return next;
  }

  List<String> _priorEvidence(DebateSession session) {
    final out = <String>[];
    for (final t in session.turns) {
      out.addAll(t.evidenceBullets);
    }
    return out;
  }

  Future<({DebateTurn turn, String? titleHint})> _buildChallengeOpening({
    String? seedArgument,
    Claim? seedClaim,
    String? topicId,
  }) async {
    if (seedClaim != null) {
      final synthetic = CrusherResult(
        id: _uuid.v4(),
        inputText: seedClaim.socialistClaimText,
        analysis: InputAnalysis(
          normalizedInput: seedClaim.socialistClaimText.toLowerCase(),
          expandedQuery: seedClaim.socialistClaimText,
          keyPhrases: seedClaim.tags.take(4).toList(),
          detectedTopicIds: [seedClaim.topicId],
          suspectedFallacies: seedClaim.fallacies,
          matchConfidence: 1,
          intentLabel: seedClaim.title,
        ),
        mode: CrusherResponseMode.curated,
        executiveSummary: seedClaim.executiveSummary,
        evidenceBullets: seedClaim.evidenceBullets,
        sources: seedClaim.sources,
        fallacies: seedClaim.fallacies,
        relatedTopics: const [],
        matchedClaims: [
          MatchedClaimRef(claim: seedClaim, score: 1, role: 'primary'),
        ],
        whyItMatters: seedClaim.whyItMatters,
        steelmannedOpponentClaim: seedClaim.socialistClaimText,
        primaryClaimTitle: seedClaim.title,
        createdAt: DateTime.now(),
      );
      final text = _formatChallengePrompt(seedClaim.socialistClaimText, synthetic);
      return (
        turn: DebateTurn(
          id: _uuid.v4(),
          role: DebateRole.engine,
          text: text,
          createdAt: DateTime.now(),
          crusherResult: synthetic,
          label: 'Opening steelman',
        ),
        titleHint: seedClaim.title,
      );
    }

    final seed = seedArgument?.trim();
    if (seed != null && seed.isNotEmpty) {
      final result = await _crusher.crush(seed);
      final steelman = result.steelmannedOpponentClaim ?? seed;
      return (
        turn: DebateTurn(
          id: _uuid.v4(),
          role: DebateRole.engine,
          text: _formatChallengePrompt(steelman, result),
          createdAt: DateTime.now(),
          crusherResult: result,
          label: 'Opening steelman',
        ),
        titleHint: _titleFromInput(seed),
      );
    }

    // Topic or random claim from KB.
    final claims = await _knowledge.getClaims();
    Claim pick;
    if (topicId != null && topicId.isNotEmpty) {
      final filtered = claims
          .where(
            (c) =>
                c.topicId == topicId ||
                (c.topicPath?.contains(topicId) ?? false),
          )
          .toList();
      pick = filtered.isNotEmpty
          ? filtered[DateTime.now().millisecond % filtered.length]
          : claims[DateTime.now().second % claims.length];
    } else {
      pick = claims[DateTime.now().second % claims.length];
    }
    return _buildChallengeOpening(seedClaim: pick);
  }

  String _formatChallengePrompt(String steelman, CrusherResult context) {
    final buf = StringBuffer()
      ..writeln('**Their strongest case (steelmanned):**')
      ..writeln()
      ..writeln(steelman)
      ..writeln()
      ..writeln(
        'Your move: write a liberty-first rebuttal. Prefer primary data, '
        'mechanisms (incentives, calculation, rights), and historical outcomes. '
        'Avoid ad hominem.',
      );
    if (context.fallacies.isNotEmpty) {
      buf
        ..writeln()
        ..writeln(
          '_Common fallacies to watch for: ${context.fallacies.take(3).join(', ')}_',
        );
    }
    return buf.toString();
  }

  String _formatEngineReply(CrusherResult result) {
    final buf = StringBuffer()
      ..writeln(result.executiveSummary)
      ..writeln();
    if (result.evidenceBullets.isNotEmpty) {
      buf.writeln('**Key evidence**');
      for (final b in result.evidenceBullets.take(5)) {
        buf.writeln('• $b');
      }
      buf.writeln();
    }
    if (result.fallacies.isNotEmpty) {
      buf.writeln('**Fallacies:** ${result.fallacies.take(4).join(', ')}');
      buf.writeln();
    }
    if (result.sources.isNotEmpty) {
      buf.writeln('**Sources**');
      for (final s in result.sources.take(4)) {
        buf.writeln('• ${s.citation ?? s.title}');
      }
      buf.writeln();
    }
    buf.writeln(result.whyItMatters);
    buf.writeln();
    buf.write(
      '_${result.modeLabel} · '
      '${(result.analysis.matchConfidence * 100).round()}% match_',
    );
    return buf.toString();
  }

  String _formatCoachReply(CrusherResult result, TurnFeedback? feedback) {
    final buf = StringBuffer();
    if (feedback != null) {
      buf
        ..writeln('**Score: ${feedback.overallScore}/100 — ${feedback.gradeLabel}**')
        ..writeln(feedback.summary ?? '')
        ..writeln();
      if (feedback.strengths.isNotEmpty) {
        buf.writeln('**What worked**');
        for (final s in feedback.strengths) {
          buf.writeln('• $s');
        }
        buf.writeln();
      }
      if (feedback.improvements.isNotEmpty) {
        buf.writeln('**How to strengthen**');
        for (final s in feedback.improvements) {
          buf.writeln('• $s');
        }
        buf.writeln();
      }
    }
    buf
      ..writeln('**Sourced reinforcement**')
      ..writeln(result.executiveSummary)
      ..writeln();
    for (final b in result.evidenceBullets.take(4)) {
      buf.writeln('• $b');
    }
    if (result.sources.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('**Sources to cite next time**');
      for (final s in result.sources.take(4)) {
        buf.writeln('• ${s.citation ?? s.title}');
      }
    }
    return buf.toString();
  }

  CrusherResult _mergeLlm(CrusherResult base, LlmEnhancement enhanced) {
    return CrusherResult(
      id: base.id,
      inputText: base.inputText,
      analysis: base.analysis,
      mode: CrusherResponseMode.llmEnhanced,
      executiveSummary: enhanced.executiveSummary,
      evidenceBullets: enhanced.evidenceBullets.isNotEmpty
          ? enhanced.evidenceBullets
          : base.evidenceBullets,
      sources: base.sources,
      fallacies: base.fallacies,
      relatedTopics: base.relatedTopics,
      matchedClaims: base.matchedClaims,
      whyItMatters: enhanced.whyItMatters ?? base.whyItMatters,
      steelmannedOpponentClaim: base.steelmannedOpponentClaim,
      primaryClaimTitle: base.primaryClaimTitle,
      createdAt: base.createdAt,
    );
  }

  String _titleFromInput(String input) {
    final oneLine = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.length <= 48) return oneLine;
    return '${oneLine.substring(0, 45)}…';
  }
}

