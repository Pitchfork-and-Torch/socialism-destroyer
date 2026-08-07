import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/services/database_service.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initTestEnvironment);

  test('FTS index returns claim ids for socialism query', () async {
    final ids = await DatabaseService.instance.searchClaimIds('venezuela socialism');
    expect(ids, isNotEmpty);
    expect(ids.any((id) => id.contains('venezuela')), isTrue);
  });
}