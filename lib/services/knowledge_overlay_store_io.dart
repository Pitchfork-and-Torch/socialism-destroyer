import 'dart:io';

/// File-backed overlay operations for native/desktop targets.
abstract final class OverlayFileOps {
  static Future<bool> exists(String path) => File(path).exists();

  static Future<String> read(String path) => File(path).readAsString();

  static Future<void> write(
    String path,
    String content, {
    bool createParent = false,
  }) async {
    final file = File(path);
    if (createParent) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  static Future<void> ensureDirectory(String path) =>
      Directory(path).create(recursive: true);

  static Future<void> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}