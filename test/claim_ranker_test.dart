import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/crusher/services/claim_retrieval_backend.dart';
import 'package:socialism_destroyer/models/claim.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';
import 'package:socialism_destroyer/models/source.dart';

Claim _claim({
  required String id,
  required String topicId,
  String? topicPath,
  String title = 'Title',
  String socialist = 'A socialist claim about markets.',
  List<String> tags = const ['tag'],
}) {
  return Claim(
    id: id,
    topicId: topicId,
    topicPath: topicPath,
    title: title,
    socialistClaimText: socialist,
    executiveSummary: 'Summary.',
    evidenceBullets: const ['Evidence.'],
    fallacies: const ['seen vs unseen'],
    sources: const [
      Source(
        title: 'BLS',
        url: 'https://www.bls.gov/',
        type: SourceType.government,
      ),
      Source(
        title: 'Census',
        url: 'https://www.census.gov/',
        type: SourceType.government,
      ),
    ],
    whyItMatters: 'It matters.',
    relatedClaimIds: const [],
    tags: tags,
    updatedAt: '2026-09-17',
    searchText: '$title $socialist $id',
  );
}

void main() {
  group('ClaimRanker.topicFamilyMatches', () {
    test('parent analyzer id matches child topicId via topicPath', () {
      final child = _claim(
        id: 'minimum-wage-no-harm',
        topicId: 'minimum-wage',
        topicPath: '/government-intervention/minimum-wage',
      );
      expect(
        ClaimRanker.topicFamilyMatches(child, ['government-intervention']),
        isTrue,
      );
    });

    test('planning-desk child matches government-intervention via topicPath', () {
      final claim = _claim(
        id: 'social-wealth-fund-owns-the-market',
        topicId: 'planning-desk',
        topicPath: '/government-intervention/planning',
      );
      expect(
        ClaimRanker.topicFamilyMatches(claim, ['government-intervention']),
        isTrue,
      );
      expect(
        ClaimRanker.topicFamilyMatches(claim, ['planning-desk']),
        isTrue,
      );
    });

    test('exact topicId match still counts', () {
      final claim = _claim(
        id: 'cancel-all-student-debt',
        topicId: 'household-capture',
        topicPath: '/government-intervention/household',
      );
      expect(
        ClaimRanker.topicFamilyMatches(claim, ['household-capture']),
        isTrue,
      );
    });

    test('unrelated family does not match', () {
      final claim = _claim(
        id: 'nordic-socialist',
        topicId: 'nordic-democratic-socialism',
        topicPath: '/nordic-democratic-socialism',
      );
      expect(
        ClaimRanker.topicFamilyMatches(claim, ['government-intervention']),
        isFalse,
      );
    });
  });

  group('ClaimRanker.rank topic family', () {
    test('does not penalize child topicId when parent is detected', () {
      final minWage = _claim(
        id: 'minimum-wage-no-harm',
        topicId: 'minimum-wage',
        topicPath: '/government-intervention/minimum-wage',
        title: 'Minimum Wage Has No Downsides',
        socialist: 'Raising the minimum wage to 15 dollars helps workers with no downsides.',
        tags: const ['minimum-wage'],
      );
      final nordic = _claim(
        id: 'nordic-socialist',
        topicId: 'nordic-democratic-socialism',
        topicPath: '/nordic-democratic-socialism',
        title: 'Nordic Socialism Works',
        socialist: 'Nordic countries prove socialism works.',
        tags: const ['nordic'],
      );
      final analysis = InputAnalysis(
        normalizedInput: 'raising the minimum wage to 15 helps workers',
        expandedQuery: 'raising the minimum wage to 15 helps workers wage floor',
        keyPhrases: const ['minimum wage'],
        detectedTopicIds: const ['government-intervention'],
        suspectedFallacies: const [],
        matchConfidence: 0,
        intentLabel: 'Government intervention',
      );
      final ranked = ClaimRanker.rank(
        hits: const [
          RetrievalHit(
            claimId: 'minimum-wage-no-harm',
            score: 0.5,
            method: RetrievalMethod.fts,
            rank: 0,
          ),
          RetrievalHit(
            claimId: 'nordic-socialist',
            score: 0.55,
            method: RetrievalMethod.fts,
            rank: 1,
          ),
        ],
        claimMap: {
          minWage.id: minWage,
          nordic.id: nordic,
        },
        input: 'raising the minimum wage to 15 helps workers',
        analysis: analysis,
      );

      expect(ranked, isNotEmpty);
      expect(ranked.first.claim.id, 'minimum-wage-no-harm');
      expect(
        ranked.first.score,
        greaterThan(ranked.firstWhere((r) => r.claim.id == 'nordic-socialist').score),
      );
    });
  });
}
