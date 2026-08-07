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
  });
}