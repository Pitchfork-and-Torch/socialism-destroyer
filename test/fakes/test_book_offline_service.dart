import 'package:socialism_destroyer/models/book.dart';
import 'package:socialism_destroyer/services/book_offline_service.dart';

/// Skips disk copies in widget tests — content comes from [bookContentProvider].
class TestBookOfflineService extends BookOfflineService {
  @override
  Future<bool> isDownloaded(String bookId) async => true;

  @override
  Future<String> downloadBook(Book book) async => '';
}