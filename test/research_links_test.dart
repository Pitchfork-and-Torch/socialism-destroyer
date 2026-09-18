import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/utils/research_links.dart';

void main() {
  test('waybackMachine keeps scheme/host unencoded', () {
    final link = ResearchLinks.waybackMachine('https://example.com/path?q=1');
    expect(link, 'https://web.archive.org/web/*/https://example.com/path?q=1');
    expect(link.contains('%3A'), isFalse);
    expect(link.contains('%2F'), isFalse);
  });

  test('waybackMachine prefixes bare hosts', () {
    expect(
      ResearchLinks.waybackMachine('example.com/x'),
      'https://web.archive.org/web/*/https://example.com/x',
    );
  });

  test('scholar still encodes query', () {
    expect(
      ResearchLinks.googleScholar('labor theory'),
      contains('q=labor%20theory'),
    );
  });

  test('waybackWikipediaSearch leaves target URL unencoded', () {
    final link = ResearchLinks.waybackWikipediaSearch('labor theory');
    expect(
      link.startsWith(
        'https://web.archive.org/web/*/https://en.wikipedia.org/',
      ),
      isTrue,
    );
    expect(link.contains('%3A'), isFalse);
    expect(link.contains('%2F'), isFalse);
    expect(link, contains('search=labor%20theory'));
  });
}
