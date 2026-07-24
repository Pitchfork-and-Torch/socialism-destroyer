import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';

/// Regression: web must load from bundled assets when offline cache is skipped.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled asset path loads without offline cache', () async {
    final books = await KnowledgeService().getBooks();
    final law = books.firstWhere((b) => b.id == 'the-law');
    final path = law.fullTextPath!;
    final content = await rootBundle.loadString(path);
    expect(content.toLowerCase(), contains('legal plunder'));
  });

  test('American founding texts are bundled', () async {
    final books = await KnowledgeService().getBooks();
    final decl = books.firstWhere((b) => b.id == 'declaration-of-independence');
    final content = await rootBundle.loadString(decl.fullTextPath!);
    expect(
      content.toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
      contains('unalienable rights'),
    );
  });
}