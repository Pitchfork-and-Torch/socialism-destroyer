import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';

/// Caches bundled book text to app documents for explicit offline reading.
class BookOfflineService {
  BookOfflineService();

  static const _subdir = 'library_offline';

  bool get _offlineAvailable => !kIsWeb;

  Future<Directory?> _booksDir() async {
    if (!_offlineAvailable) return null;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, _subdir));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } on MissingPluginException {
      // Widget tests and some desktop targets lack path_provider.
      return null;
    }
  }

  String _fileName(String bookId) => '$bookId.txt';

  Future<bool> isDownloaded(String bookId) async {
    if (!_offlineAvailable) return false;
    final dir = await _booksDir();
    if (dir == null) return false;
    final file = File(p.join(dir.path, _fileName(bookId)));
    return file.exists();
  }

  Future<Set<String>> downloadedBookIds() async {
    if (!_offlineAvailable) return {};
    final dir = await _booksDir();
    if (dir == null || !await dir.exists()) return {};
    final ids = <String>{};
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.txt')) {
        ids.add(p.basenameWithoutExtension(entity.path));
      }
    }
    return ids;
  }

  /// Copies bundled asset text to documents — returns local path.
  Future<String> downloadBook(Book book) async {
    if (!_offlineAvailable) {
      throw UnsupportedError('Offline book download is not available on web');
    }
    final dir = await _booksDir();
    if (dir == null) {
      throw UnsupportedError('Offline book cache is not available on this platform');
    }
    final sourcePath =
        book.fullTextPath ?? book.excerptPath ?? book.assetPath;
    if (sourcePath.isEmpty) {
      throw StateError('No text asset for ${book.id}');
    }
    final content = await rootBundle.loadString(sourcePath);
    final file = File(p.join(dir.path, _fileName(book.id)));
    await file.writeAsString(content);
    return file.path;
  }

  /// Reads cached text if present.
  Future<String?> readCached(String bookId) async {
    if (!_offlineAvailable) return null;
    final dir = await _booksDir();
    if (dir == null) return null;
    final file = File(p.join(dir.path, _fileName(bookId)));
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> removeDownload(String bookId) async {
    if (!_offlineAvailable) return;
    final dir = await _booksDir();
    if (dir == null) return;
    final file = File(p.join(dir.path, _fileName(bookId)));
    if (await file.exists()) await file.delete();
  }
}