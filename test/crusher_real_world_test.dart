import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/crusher/services/claim_retrieval_backend.dart';
import 'package:socialism_destroyer/features/crusher/services/crusher_service.dart';
import 'package:socialism_destroyer/features/crusher/services/debate_history_service.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';
import 'package:socialism_destroyer/services/search_service.dart';

import 'test_helpers.dart';

/// Real-world leftist arguments — regression suite for Argument Crusher.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initTestEnvironment();
    await initTestHive();
  });

  late CrusherService crusher;
  late DebateHistoryService history;

  setUp(() {
    final knowledge = preloadedKnowledgeService();
    crusher = CrusherService(
      knowledge: knowledge,
      retrieval: HybridClaimRetrievalBackend(
        fts: FtsClaimRetrievalBackend(SearchService(knowledge)),
        embedding: EmbeddingOverlapRetrievalBackend(knowledge),
      ),
    );
    history = DebateHistoryService();
  });

  /// Shared assertions every crush must satisfy.
  void expectQualityResponse(CrusherResult result) {
    expect(result.executiveSummary.trim(), isNotEmpty);
    expect(result.evidenceBullets, isNotEmpty);
    expect(result.whyItMatters.trim(), isNotEmpty);
    expect(result.analysis.intentLabel, isNotNull);
    expect(result.analysis.matchConfidence, greaterThan(0.2));
    expect(
      result.mode,
      anyOf(CrusherResponseMode.curated, CrusherResponseMode.composed),
    );
  }

  group('Real-world Argument Crusher', () {
    test('1 — capitalism exploits the working class', () async {
      const input = 'capitalism exploits the working class';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.analysis.intentLabel, contains('exploitation'));
      expect(result.fallacies, isNotEmpty);
      expect(result.sources, isNotEmpty);
      expect(
        result.matchedClaimIds.any(
          (id) => id == 'exploitation-marx' || id == 'profit-is-theft',
        ),
        isTrue,
        reason: 'Got ${result.matchedClaimIds}',
      );
      expect(result.primaryClaim?.id, anyOf('exploitation-marx', 'profit-is-theft'));
    });

    test('2 — Nordic countries prove socialism works', () async {
      const input = 'Nordic countries prove socialism works';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.analysis.detectedTopicIds, contains('nordic-democratic-socialism'));
      expect(
        result.matchedClaimIds.any(
          (id) => id.startsWith('nordic'),
        ),
        isTrue,
        reason: 'Got ${result.matchedClaimIds}',
      );
      expect(result.fallacies, isNotEmpty);
    });

    test('3 — Venezuela only failed because of US sanctions', () async {
      const input = 'Venezuela only failed because of US sanctions';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.analysis.detectedTopicIds, contains('historical-socialism'));
      expect(result.fallacies, contains('single-cause fallacy'));
      expect(
        result.matchedClaimIds,
        contains('venezuela-sanctions'),
      );
    });

    test('4 — billionaires should not exist in a moral society', () async {
      const input = "billionaires shouldn't exist in a moral society";
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(
        result.matchedClaimIds.any(
          (id) => id.contains('billionaire') || id.contains('wealth'),
        ),
        isTrue,
        reason: 'Got ${result.matchedClaimIds}',
      );
      expect(result.sources, isNotEmpty);
    });

    test('5 — raising minimum wage to \$15 helps workers with no downsides', () async {
      const input =
          'raising the minimum wage to \$15 helps workers with no downsides';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.analysis.detectedTopicIds, contains('government-intervention'));
      expect(
        result.matchedClaimIds.any((id) => id.startsWith('minimum-wage')),
        isTrue,
        reason: 'Got ${result.matchedClaimIds}',
      );
    });

    test('6 — healthcare is a human right and Medicare for All is proven', () async {
      const input =
          'healthcare is a human right and Medicare for All is proven';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(
        result.matchedClaimIds.any((id) => id.startsWith('healthcare')),
        isTrue,
        reason: 'Got ${result.matchedClaimIds}',
      );
      expect(result.fallacies, isNotEmpty);
    });

    test('7 — rent control is the only way to keep housing affordable', () async {
      const input =
          'rent control is the only way to keep housing affordable';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(
        result.matchedClaimIds,
        contains('rent-control-helps'),
      );
    });

    test('8 — the USSR was not real socialism', () async {
      const input = "the USSR wasn't real socialism";
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.fallacies, contains('no true scotsman'));
      expect(
        result.matchedClaimIds,
        contains('ussr-not-real-socialism'),
      );
    });

    test('9 — America has no economic mobility anymore', () async {
      const input = 'America has no economic mobility anymore';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.analysis.detectedTopicIds, contains('wealth-inequality-mobility'));
      expect(
        result.matchedClaimIds.any(
          (id) => id.contains('mobility') || id.contains('chetty'),
        ),
        isTrue,
        reason: 'Got ${result.matchedClaimIds}',
      );
    });

    test('10 — profit is theft from workers', () async {
      const input = 'profit is theft from workers';
      final result = await crusher.crush(input);

      expectQualityResponse(result);
      expect(result.fallacies, contains('labor theory of value'));
      expect(result.matchedClaimIds, contains('profit-is-theft'));
      expect(result.sources, isNotEmpty);
    });

    test('saves all 10 examples to debate history', () async {
      const inputs = [
        'capitalism exploits the working class',
        'Nordic countries prove socialism works',
        'Venezuela only failed because of US sanctions',
        "billionaires shouldn't exist in a moral society",
        'raising the minimum wage to \$15 helps workers with no downsides',
        'healthcare is a human right and Medicare for All is proven',
        'rent control is the only way to keep housing affordable',
        "the USSR wasn't real socialism",
        'America has no economic mobility anymore',
        'profit is theft from workers',
      ];

      for (final input in inputs) {
        final result = await crusher.crush(input);
        await history.save(result);
      }

      final recent = history.listRecentMeta(limit: 15);
      expect(recent.length, greaterThanOrEqualTo(10));
      expect(recent.first.mode, isNotNull);
      expect(recent.first.matchConfidence, greaterThan(0));
    });
  });
}