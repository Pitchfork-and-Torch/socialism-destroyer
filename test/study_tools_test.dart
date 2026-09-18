import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/services/study_tools_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('study tools catalog loads from bundled JSON', () async {
    final doc = await StudyToolsService().load();
    expect(doc.categories.length, greaterThanOrEqualTo(4));
    final names = doc.categories
        .expand((c) => c.tools)
        .map((t) => t.name)
        .toList();
    expect(names, contains('Project Gutenberg'));
    expect(names, contains('Wayback Machine'));
    expect(names, contains('Semantic Scholar'));
  });
}