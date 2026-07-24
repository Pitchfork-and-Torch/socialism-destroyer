import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/crusher/services/argument_analyzer.dart';
import 'package:socialism_destroyer/services/claim_reading_service.dart';
import 'package:socialism_destroyer/features/crusher/services/debate_history_service.dart';
import 'package:socialism_destroyer/features/crusher/services/claim_retrieval_backend.dart';
import 'package:socialism_destroyer/features/crusher/services/crusher_service.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/services/search_service.dart';

import 'test_helpers.dart';

CrusherService _hybridCrusher(KnowledgeService knowledge) => CrusherService(
      knowledge: knowledge,
      retrieval: HybridClaimRetrievalBackend(
        fts: FtsClaimRetrievalBackend(SearchService(knowledge)),
        embedding: EmbeddingOverlapRetrievalBackend(knowledge),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initTestDatabase);

  group('ArgumentAnalyzer', () {
    test('detects exploitation topic, intent, and fallacies', () {
      final analysis = ArgumentAnalyzer().analyze(
        'capitalism exploits the working class',
      );
      expect(analysis.detectedTopicIds, contains('profit-exploitation'));
      expect(analysis.intentLabel, contains('exploitation'));
      expect(analysis.keyPhrases, isNotEmpty);
      expect(analysis.suspectedFallacies, contains('labor theory of value'));
    });
  });

  group('DebateHistoryService', () {
    setUpAll(() async {
      await initTestHive();
    });

    test('saves crusher result to hive', () async {
      final knowledge = KnowledgeService();
      final crusher = _hybridCrusher(knowledge);
      final history = DebateHistoryService();
      final result = await crusher.crush('capitalism exploits the working class');
      await history.save(result);
      final recent = history.listRecent();
      expect(recent, isNotEmpty);
      expect(recent.first.inputText, contains('exploits'));
    });
  });

  group('CrusherService', () {
    late CrusherService crusher;

    setUp(() {
      final knowledge = KnowledgeService();
      crusher = _hybridCrusher(knowledge);
    });

    test('maps "capitalism exploits the working class" to exploitation claims', () async {
      final result = await crusher.crush('capitalism exploits the working class');

      expect(result.executiveSummary, isNotEmpty);
      expect(result.evidenceBullets, isNotEmpty);
      expect(result.sources, isNotEmpty);
      expect(result.fallacies, isNotEmpty);
      expect(result.relatedTopics, isNotEmpty);
      expect(result.matchedClaimIds, isNotEmpty);
      expect(
        result.matchedClaimIds.any(
          (id) => id == 'exploitation-marx' || id == 'profit-is-theft',
        ),
        isTrue,
        reason: 'Expected exploitation-marx or profit-is-theft, got ${result.matchedClaimIds}',
      );
      expect(result.analysis.matchConfidence, greaterThan(0.45));
      expect(
        result.mode,
        anyOf(CrusherResponseMode.curated, CrusherResponseMode.composed),
      );
    });

    test('result serializes for debate history storage', () async {
      final result = await crusher.crush('the rich get richer while the poor get poorer');
      final json = result.toJson();
      expect(json['executiveSummary'], isA<String>());
      expect(json['matchedClaimIds'], isA<List<dynamic>>());
      expect(json['analysis'], isA<Map<String, dynamic>>());
    });

    test('primary matched claim exposes library reading links', () async {
      final knowledge = KnowledgeService();
      final result =
          await _hybridCrusher(knowledge).crush('profit is theft from workers');
      final primary = result.primaryClaim;
      expect(primary, isNotNull);

      final links = await ClaimReadingService().linksForClaim(primary!.id);
      expect(links, isNotEmpty);
      expect(links.any((l) => l.bookId == 'wealth-of-nations'), isTrue);
    });
  });
}