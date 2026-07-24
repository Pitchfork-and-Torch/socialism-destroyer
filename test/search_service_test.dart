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
  });
}