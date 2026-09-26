import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';
import 'package:socialism_destroyer/services/search_service.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initTestDatabase);

  group('SearchService', () {
    late SearchService search;

    setUp(() {
      search = SearchService(KnowledgeService());
    });

    test('finds wealth inequality claim', () async {
      final results = await search.search('wealth inequality capitalism broken');
      expect(results, isNotEmpty);
      expect(results.first.id, 'wealth-inequality-broken');
    });

    test('finds exploitation claims for worker exploit query', () async {
      final results = await search.search('capitalism exploits workers');
      expect(results.any((c) => c.id == 'exploitation-marx' || c.id == 'profit-is-theft'), isTrue);
    });

    test('returns empty for blank query', () async {
      final results = await search.search('   ');
      expect(results, isEmpty);
    });

    // Golden queries (search precision regression suite)
    test('golden: rent control ranks housing claims highly', () async {
      final results = await search.search('rent control keeps housing affordable');
      expect(results, isNotEmpty);
      expect(
        results.take(5).any(
          (c) =>
              c.id.contains('rent') ||
              c.id.contains('housing') ||
              c.topicId.contains('rent') ||
              c.topicId.contains('housing'),
        ),
        isTrue,
        reason: 'top ids: ${results.take(5).map((c) => c.id).toList()}',
      );
    });

    test('golden: nordic query finds nordic claims', () async {
      final results = await search.search('Nordic countries prove socialism works');
      expect(results, isNotEmpty);
      expect(
        results.take(5).any((c) => c.id.contains('nordic') || c.topicId.contains('nordic')),
        isTrue,
        reason: 'top ids: ${results.take(5).map((c) => c.id).toList()}',
      );
    });

    test('golden: medicare for all finds healthcare/m4a claims', () async {
      final results = await search.search('Medicare for All pays for itself');
      expect(results, isNotEmpty);
      expect(
        results.take(8).any(
          (c) =>
              c.id.contains('medicare') ||
              c.id.contains('healthcare') ||
              c.tags.any((t) => t.toLowerCase().contains('medicare')),
        ),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: mobility / american dream', () async {
      final results = await search.search('American Dream is dead no mobility');
      expect(results, isNotEmpty);
      expect(
        results.take(8).any(
          (c) =>
              c.id.contains('mobility') ||
              c.id.contains('american') ||
              c.tags.any((t) => t.toLowerCase().contains('mobility')),
        ),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: student loan pause finds debt claims', () async {
      final results =
          await search.search('permanent student loan pause is justice');
      expect(results, isNotEmpty);
      expect(
        results.take(8).any(
          (c) =>
              c.id.contains('loan') ||
              c.id.contains('student') ||
              c.id.contains('college') ||
              c.tags.any((t) => t.toLowerCase().contains('debt')),
        ),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: four-day workweek finds wave4 claim', () async {
      final results =
          await search.search('mandate four-day workweek full pay justice');
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'four-day-workweek-mandate'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: postal banking finds wave5 claim', () async {
      final results = await search.search(
        'postal banking is financial justice public checking',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'postal-banking-is-justice'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: electricity cap finds wave6 energy claim', () async {
      final results = await search.search(
        'cap electricity prices now utilities are gouging households',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'cap-electricity-prices-now'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: unrealized gains finds wave6 tax claim', () async {
      final results = await search.search(
        'tax unrealized capital gains every year billionaires paper wealth',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'tax-unrealized-gains-is-justice'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: PRO Act finds wave10 statute claim', () async {
      final results = await search.search(
        'pass the pro act h.r. 20 restores the right to organize',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(5).any((c) => c.id == 'pro-act-restores-organizing'),
        isTrue,
        reason: 'top ids: ${results.take(5).map((c) => c.id).toList()}',
      );
    });

    test('golden: debt ceiling finds wave10 statute claim', () async {
      final results = await search.search(
        'abolish the debt ceiling manufactured hostage crisis',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(5).any((c) => c.id == 'abolish-the-debt-ceiling'),
        isTrue,
        reason: 'top ids: ${results.take(5).map((c) => c.id).toList()}',
      );
    });

    test('golden: social wealth fund finds wave9 planning claim', () async {
      final results = await search.search(
        'a social wealth fund should own a slice of every large firm and pay a resident dividend',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(5).any((c) => c.id == 'social-wealth-fund-owns-the-market'),
        isTrue,
        reason: 'top ids: ${results.take(5).map((c) => c.id).toList()}',
      );
    });

    test('golden: codetermination finds wave9 board claim', () async {
      final results = await search.search(
        'codetermination workers must hold half the board as worker directors',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(5).any((c) => c.id == 'codetermination-half-the-board'),
        isTrue,
        reason: 'top ids: ${results.take(5).map((c) => c.id).toList()}',
      );
    });

    test('golden: cancel student debt finds wave8 household claim', () async {
      final results = await search.search(
        'cancel all federal student debt wipe the entire student loan book so a generation can buy homes',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'cancel-all-student-debt'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: junk fees finds wave8 household claim', () async {
      final results = await search.search(
        'ban junk fees so the advertised number is the real price surprise add-ons airlines landlords banks',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'ban-junk-fees-is-justice'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: buybacks finds wave8 household claim', () async {
      final results = await search.search(
        'ban stock buybacks so profits go to wages and factories instead of juicing the ticker',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'ban-stock-buybacks'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: LNG export ban finds wave7 energy claim', () async {
      final results = await search.search(
        'ban LNG exports until Americans can afford heat',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'ban-lng-exports-until-cheap'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: foreign farmland ban finds wave7 supply claim', () async {
      final results = await search.search(
        'ban foreign ownership of US farmland',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'ban-foreign-farmland'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: freight rail nationalize finds wave7 supply claim', () async {
      final results = await search.search(
        'nationalize freight railroads to fix supply chains',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'nationalize-freight-rail'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('golden: 25 dollar wage finds wave6 minimum-wage claim', () async {
      final results = await search.search(
        '25 dollar federal minimum wage is the living wage and will not cost jobs',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any((c) => c.id == 'twenty-five-dollar-minimum-wage'),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });

    test('precisionScore ranks student-debt claim above unrelated housing', () async {
      final knowledge = KnowledgeService();
      final debt = await knowledge.getClaimById('cancel-all-student-debt');
      final housing = await knowledge.getClaimById('rent-control-helps');
      expect(debt, isNotNull);
      expect(housing, isNotNull);
      const q = 'cancel all federal student debt wipe the entire student loan book';
      final terms = q.split(RegExp(r'\s+')).where((t) => t.length >= 2).toList();
      final debtScore = SearchService.precisionScore(debt!, q, terms);
      final housingScore = SearchService.precisionScore(housing!, q, terms);
      expect(debtScore, greaterThan(housingScore));
    });

    test('golden: private equity housing ban ranks housing claim', () async {
      final results = await search.search(
        'ban private equity from residential housing Wall Street landlords',
      );
      expect(results, isNotEmpty);
      expect(
        results.take(8).any(
          (c) =>
              c.id == 'ban-private-equity-housing' ||
              c.id.contains('housing') ||
              c.id.contains('rent'),
        ),
        isTrue,
        reason: 'top ids: ${results.take(8).map((c) => c.id).toList()}',
      );
    });
  });
}