import 'package:share_plus/share_plus.dart';

import '../../../models/book.dart';
import '../../../models/claim.dart';
import '../../../services/claim_export_service.dart';

/// Centralized share/export text builders for surfaces across the app.
abstract final class ShareActions {
  static Future<void> shareText(
    String text, {
    String? subject,
  }) =>
      Share.share(text, subject: subject);

  static Future<void> shareInsight(Map<String, String> insight) {
    final quote = insight['quote'] ?? '';
    final author = insight['author'] ?? '';
    final data = insight['dataPoint'] ?? '';
    final source = insight['source'] ?? '';
    return shareText(
      '"$quote"\n— $author\n\n$data\nSource: $source\n\n— Socialism Destroyer',
      subject: "Today's Based Insight",
    );
  }

  static Future<void> shareClaim(Claim claim) => shareText(
        ClaimExportService.toMarkdown(claim),
        subject: claim.title,
      );

  static Future<void> shareBook(Book book) => shareText(
        '${book.title} by ${book.author}\n\n${book.description}\n\n'
        'Read offline in Socialism Destroyer — Public Domain Library.',
        subject: book.title,
      );

  static Future<void> shareBookExcerpt({
    required Book book,
    required String excerpt,
    String? chapterTitle,
  }) {
    final chapter = chapterTitle != null ? ' ($chapterTitle)' : '';
    return shareText(
      'From ${book.title} by ${book.author}$chapter:\n\n'
      '"$excerpt"\n\n— Shared from Socialism Destroyer Library',
      subject: book.title,
    );
  }

  static Future<void> shareHighlights({
    required Book book,
    required List<String> excerpts,
  }) {
    final body = excerpts
        .take(12)
        .map((e) => '• $e')
        .join('\n');
    return shareText(
      'Highlights from ${book.title} by ${book.author}:\n\n$body\n\n'
      '— Socialism Destroyer',
      subject: '${book.title} highlights',
    );
  }
}