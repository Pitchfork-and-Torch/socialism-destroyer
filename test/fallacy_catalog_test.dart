import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/tree/data/fallacy_catalog.dart';

void main() {
  test('resolve exact id and label', () {
    expect(FallacyCatalog.resolve('zero-sum fallacy')?.label, 'Zero-Sum Fallacy');
    expect(FallacyCatalog.resolve('Zero-Sum Fallacy')?.id, 'zero-sum fallacy');
  });

  test('resolve rejects empty and short substring false positives', () {
    expect(FallacyCatalog.resolve(''), isNull);
    expect(FallacyCatalog.resolve('   '), isNull);
    // "no" previously matched "no true scotsman" via e.id.contains(key).
    expect(FallacyCatalog.resolve('no'), isNull);
    expect(FallacyCatalog.resolve('theory'), isNull);
    expect(FallacyCatalog.resolve('fallacy'), isNull);
  });

  test('resolve still matches when haystack contains a known id', () {
    expect(
      FallacyCatalog.resolve('opponent used zero-sum fallacy here')?.id,
      'zero-sum fallacy',
    );
  });
}
