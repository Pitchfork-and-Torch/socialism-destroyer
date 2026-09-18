/// Deep links to free research tools (Internet Archive, Scholar, etc.).
abstract final class ResearchLinks {
  static String googleScholar(String query) =>
      'https://scholar.google.com/scholar?q=${Uri.encodeComponent(query)}';

  static String semanticScholar(String query) =>
      'https://www.semanticscholar.org/search?q=${Uri.encodeComponent(query)}';

  /// Wayback calendar/wildcard lookup. The target URL must stay unencoded —
  /// percent-encoding the whole URL makes archive.org miss the capture.
  static String waybackMachine(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return 'https://web.archive.org/web/*/';
    final target = trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
    return 'https://web.archive.org/web/*/$target';
  }

  static String archiveSaveNow(String url) =>
      'https://web.archive.org/save/${url.startsWith('http') ? url : 'https://$url'}';

  static String projectGutenbergSearch(String query) =>
      'https://www.gutenberg.org/ebooks/search/?query=${Uri.encodeComponent(query)}';

  static String openLibrarySearch(String query) =>
      'https://openlibrary.org/search?q=${Uri.encodeComponent(query)}';
}
