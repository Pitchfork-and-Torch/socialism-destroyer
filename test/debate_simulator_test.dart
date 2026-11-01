import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/crusher/services/claim_retrieval_backend.dart';
import 'package:socialism_destroyer/features/crusher/services/crusher_service.dart';
import 'package:socialism_destroyer/features/debate_simulator/services/debate_export_service.dart';
import 'package:socialism_destroyer/features/debate_simulator/services/debate_scoring_service.dart';
import 'package:socialism_destroyer/features/debate_simulator/services/debate_session_store.dart';
import 'package:socialism_destroyer/features/debate_simulator/services/debate_simulator_service.dart';
import 'package:socialism_destroyer/features/library/services/library_passage_rag_service.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';
import 'package:socialism_destroyer/models/debate_session.dart';
import 'package:socialism_destroyer/services/debate_playlist_service.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/services/search_service.dart';

import 'test_helpers.dart';

CrusherService _crusher(KnowledgeService knowledge) => CrusherService(
      knowledge: knowledge,
      retrieval: HybridClaimRetrievalBackend(
        fts: FtsClaimRetrievalBackend(SearchService(knowledge)),
        embedding: EmbeddingOverlapRetrievalBackend(knowledge),
        vector: VectorClaimRetrievalBackend(knowledge: knowledge, enabled: true),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initTestDatabase);

  group('DebateScoringService', () {
    final scoring = DebateScoringService();

    test('rewards sourced, specific rebuttals', () {
      const weak = 'Socialism bad.';
      const strong =
          'According to BLS and Census data, real consumption has risen '
          'even as inequality ratios moved. Profit rewards risk and coordination; '
          'the labor theory of value is a zero-sum fallacy. Mobility studies (Chetty) '
          'show absolute gains matter more than static Gini snapshots.';

      final weakScore = scoring.score(userText: weak);
      final strongScore = scoring.score(userText: strong);

      expect(strongScore.overallScore, greaterThan(weakScore.overallScore));
      expect(strongScore.evidenceScore, greaterThan(45));
      expect(strongScore.overallScore, greaterThan(55));
      expect(weakScore.improvements, isNotEmpty);
      expect(strongScore.strengths, isNotEmpty);
    });

    test('penalizes ad hominem', () {
      final clean = scoring.score(
        userText:
            'Markets use price signals to solve the calculation problem that central plans cannot.',
      );
      final toxic = scoring.score(
        userText: 'You people are idiots and brainwashed sheep.',
      );
      expect(clean.fallacyAwarenessScore, greaterThan(toxic.fallacyAwarenessScore));
      expect(toxic.overallScore, lessThan(clean.overallScore));
    });
  });

  group('DebateSimulatorService', () {
    late DebateSimulatorService service;

    setUpAll(() async {
      await initTestHive();
    });

    setUp(() {
      final knowledge = KnowledgeService();
      service = DebateSimulatorService(
        crusher: _crusher(knowledge),
        knowledge: knowledge,
        store: DebateSessionStore(),
      );
    });

    test('spar mode multi-turn persists and accumulates sources', () async {
      final session = await service.start(
        mode: DebateMode.spar,
        seedArgument: 'capitalism exploits the working class',
      );

      expect(session.mode, DebateMode.spar);
      expect(session.turns.length, greaterThanOrEqualTo(3)); // briefing + user + engine
      expect(session.latestEngineTurn, isNotNull);
      expect(session.latestEngineTurn!.crusherResult, isNotNull);
      expect(session.allSources, isNotEmpty);

      final next = await service.userTurn(
        session,
        'Actually the Nordic model proves democratic socialism works.',
      );
      expect(next.userTurnCount, greaterThanOrEqualTo(2));
      expect(next.turns.last.role, DebateRole.engine);
      expect(next.allMatchedClaimIds, isNotEmpty);

      final reloaded = service.store.load(next.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.turnCount, next.turnCount);
    });

    test('challenge mode opens with steelman and scores rebuttal', () async {
      final session = await service.start(
        mode: DebateMode.challenge,
        seedArgument: 'profit is theft from workers',
      );

      expect(session.mode, DebateMode.challenge);
      final opening = session.turns.where((t) => t.role == DebateRole.engine);
      expect(opening, isNotEmpty);
      expect(opening.first.label, contains('steelman'));

      final after = await service.userTurn(
        session,
        'Profit compensates capital risk and coordination. BLS productivity series '
        'and subjective value theory refute the labor theory of value. '
        'Historical socialist experiments faced the calculation problem.',
      );

      final userTurns =
          after.turns.where((t) => t.role == DebateRole.user).toList();
      expect(userTurns.last.feedback, isNotNull);
      expect(userTurns.last.feedback!.overallScore, greaterThan(30));
      expect(after.turns.last.role, DebateRole.engine);
    });

    test('handles very long user paste without throwing', () async {
      final session = await service.start(mode: DebateMode.spar);
      final long = List.filled(500, 'capitalism fails workers ').join();
      final next = await service.userTurn(session, long);
      expect(next.turns.last.role, DebateRole.engine);
      expect(next.turns.where((t) => t.role == DebateRole.user).last.text.length,
          lessThanOrEqualTo(12000));
    });

    test('export markdown includes transcript and evidence index', () async {
      final session = await service.start(
        mode: DebateMode.spar,
        seedArgument: 'the rich get richer while the poor get poorer',
      );
      final md = DebateExportService.toMarkdown(session);
      expect(md, contains('Debate Simulator Transcript'));
      expect(md, contains('Evidence index'));
      expect(md, contains(session.title));
    });

    test('session JSON round-trip', () async {
      final session = await service.start(
        mode: DebateMode.challenge,
        claimId: null,
        seedArgument: 'rent control helps the poor',
      );
      final json = session.toJson();
      final restored = DebateSession.fromJson(json);
      expect(restored.id, session.id);
      expect(restored.turns.length, session.turns.length);
      expect(restored.mode, DebateMode.challenge);
    });

    test('appendChallengeOpening adds engine steelman turn', () async {
      final session = await service.start(
        mode: DebateMode.challenge,
        seedArgument: 'profit is theft',
      );
      final before = session.turns.length;
      final next = await service.appendChallengeOpening(
        session,
        seedArgument: 'the Nordic model proves democratic socialism works',
      );
      expect(next.turns.length, greaterThan(before));
      expect(next.turns.last.role, DebateRole.engine);
      expect(next.turns.last.label, contains('steelman'));
    });
  });

  group('VectorClaimRetrievalBackend', () {
    test('returns ranked hits offline for exploitation query', () async {
      final knowledge = KnowledgeService();
      final vector = VectorClaimRetrievalBackend(
        knowledge: knowledge,
        enabled: true,
      );
      final hits = await vector.retrieve(
        'capitalism exploits workers with surplus value',
        limit: 5,
      );
      expect(hits, isNotEmpty);
      expect(hits.first.method, RetrievalMethod.vector);
      expect(hits.first.score, greaterThan(0));
    });
  });

  group('LibraryPassageRagService', () {
    test('returns passages for exploitation claims', () async {
      final rag = LibraryPassageRagService(knowledge: KnowledgeService());
      final hits = await rag.retrieve(
        query: 'profit exploitation labor surplus value markets',
        claimIds: ['profit-is-theft', 'exploitation-marx'],
        limit: 4,
      );
      expect(hits, isNotEmpty);
      expect(hits.first.bookId, isNotEmpty);
      expect(hits.first.snippet, isNotEmpty);
    });
  });

  group('DebatePlaylistService', () {
    test('loads curated timed drill playlists', () async {
      final playlists = await DebatePlaylistService().getPlaylists();
      expect(playlists.length, greaterThanOrEqualTo(4));
      expect(playlists.first.prompts, isNotEmpty);
      expect(playlists.first.defaultSeconds, greaterThan(0));
    });
  });
}
