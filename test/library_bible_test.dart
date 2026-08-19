import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/services/claim_reading_service.dart';
import 'package:socialism_destroyer/services/knowledge_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Library bible content', () {
    test('catalog includes American canon and economics classics', () async {
      final books = await KnowledgeService().getBooks();
      expect(books.length, greaterThanOrEqualTo(35));
      for (final id in [
        'declaration-of-independence',
        'us-constitution',
        'common-sense',
        'federalist-10-51',
        'second-treatise',
        'the-law',
        'wealth-of-nations',
        'seen-and-unseen',
      ]) {
        expect(
          books.any((b) => b.id == id && b.fullTextPath != null),
          isTrue,
          reason: 'Expected loadable full text for $id',
        );
      }
    });

    test('every bundled book loads full text without abridgments', () async {
      final books = await KnowledgeService().getBooks();
      const minFullTextChars = <String, int>{
        'second-treatise': 80000,
        'democracy-in-america': 500000,
        'on-liberty': 200000,
        'wealth-of-nations': 1000000,
        'economic-sophisms': 200000,
        'rights-of-man': 200000,
        'age-of-reason': 200000,
        'frederick-douglass': 100000,
        'lenin-state-and-revolution': 50000,
        'franklin-autobiography': 150000,
      };
      for (final book in books) {
        if (book.fullTextPath == null || book.fullTextPath!.isEmpty) {
          continue;
        }
        expect(book.excerptPath, isNull, reason: '${book.id} must not use excerptPath');
        expect(book.title, isNot(contains('Key Sections')), reason: book.id);
        final content = await rootBundle.loadString(book.fullTextPath!);
        expect(content, isNot(contains('Key Sections')), reason: book.id);
        final minChars = minFullTextChars[book.id] ?? 200;
        expect(content.length, greaterThan(minChars), reason: book.id);
      }
    });

    test('The Law full text is searchable for legal plunder', () async {
      final books = await KnowledgeService().getBooks();
      final law = books.firstWhere((b) => b.id == 'the-law');
      final content = await rootBundle.loadString(law.fullTextPath!);
      expect(content.length, greaterThan(50000));
      expect(content.toLowerCase(), contains('legal plunder'));
      expect(law.chapters.length, greaterThanOrEqualTo(10));
    });

    test('Wealth of Nations full text includes invisible hand', () async {
      final books = await KnowledgeService().getBooks();
      final won = books.firstWhere((b) => b.id == 'wealth-of-nations');
      final content = await rootBundle.loadString(won.fullTextPath!);
      expect(content.toLowerCase(), contains('invisible hand'));
      expect(won.chapters.length, greaterThanOrEqualTo(5));
    });

    test('Seen and Unseen includes broken window fallacy', () async {
      final books = await KnowledgeService().getBooks();
      final book = books.firstWhere((b) => b.id == 'seen-and-unseen');
      final content = await rootBundle.loadString(book.fullTextPath!);
      expect(content.toLowerCase(), contains('broken window'));
      expect(book.chapters.length, greaterThanOrEqualTo(5));
    });
  });

  group('Claim reading links', () {
    test('profit-is-theft links to wealth of nations', () async {
      final links = await ClaimReadingService().linksForClaim('profit-is-theft');
      expect(links, isNotEmpty);
      expect(links.any((l) => l.bookId == 'wealth-of-nations'), isTrue);
    });

    test('rent-control-helps links to seen-and-unseen', () async {
      final links =
          await ClaimReadingService().linksForClaim('rent-control-helps');
      expect(links.any((l) => l.bookId == 'seen-and-unseen'), isTrue);
    });
  });

}