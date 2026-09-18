import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/utils/research_links.dart';

void main() {
  test('archiveSaveNow prefixes bare hosts with https://', () {
    expect(
      ResearchLinks.archiveSaveNow('example.com/path'),
      'https://web.archive.org/save/https://example.com/path',
    );
  });

  test('archiveSaveNow keeps real http(s) schemes', () {
    expect(
      ResearchLinks.archiveSaveNow('https://example.com/x'),
      'https://web.archive.org/save/https://example.com/x',
    );
    expect(
      ResearchLinks.archiveSaveNow('http://example.com/x'),
      'https://web.archive.org/save/http://example.com/x',
    );
  });

  test('archiveSaveNow does not treat httpexample as schemed', () {
    expect(
      ResearchLinks.archiveSaveNow('httpexample.com'),
      'https://web.archive.org/save/https://httpexample.com',
    );
  });

  test('archiveSaveNow trims and handles empty', () {
    expect(
      ResearchLinks.archiveSaveNow('  example.com  '),
      'https://web.archive.org/save/https://example.com',
    );
    expect(ResearchLinks.archiveSaveNow(''), 'https://web.archive.org/save/');
  });
}
