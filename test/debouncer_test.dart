import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/utils/debouncer.dart';

void main() {
  test('Debouncer coalesces rapid calls', () async {
    var count = 0;
    final debouncer = Debouncer(delay: const Duration(milliseconds: 50));

    debouncer.run(() => count++);
    debouncer.run(() => count++);
    debouncer.run(() => count++);

    expect(count, 0);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(count, 1);

    debouncer.dispose();
  });
}