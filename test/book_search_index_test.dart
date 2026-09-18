import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/library/widgets/book_search_bar.dart';

void main() {
  test('book search index stays inside the hit list', () {
    expect(bookSearchShownIndex(0, 0), 0);
    expect(bookSearchShownIndex(-2, 4), 0);
    expect(bookSearchShownIndex(1, 4), 1);
    expect(bookSearchShownIndex(10, 3), 2);
  });
}
