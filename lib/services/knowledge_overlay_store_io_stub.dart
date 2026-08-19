/// Web stub — file overlay is never used when [KnowledgeOverlayStore] uses Hive.
abstract final class OverlayFileOps {
  static Future<bool> exists(String path) async => false;

  static Future<String> read(String path) async =>
      throw UnsupportedError('File overlay is unavailable on web');

  static Future<void> write(
    String path,
    String content, {
    bool createParent = false,
  }) async =>
      throw UnsupportedError('File overlay is unavailable on web');

  static Future<void> ensureDirectory(String path) async {}

  static Future<void> deleteDirectory(String path) async {}
}