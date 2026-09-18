/// Deep links to free research tools (Internet Archive, Scholar, etc.).
abstract final class ResearchLinks {
  static String googleScholar(String query) =>
      'https://scholar.google.com/scholar?q=${Uri.encodeComponent(query)}';

  static String semanticScholar(String query) =>
      'https://www.semanticscholar.org/search?q=${Uri.encodeComponent(query)}';

  static String waybackMachine(String url) =>
      'https://web.archive.org/web/*/${Uri.encodeComponent(url)}';

  /// Save Page Now. Bare hosts get https://; only real http(s) schemes skip the prefix.
  /// `startsWith('http')` alone treated `httpexample.com` as already-schemed.
  static String archiveSaveNow(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return 'https://web.archive.org/save/';
    final hasScheme = trimmed.startsWith('http://') || trimmed.startsWith('https://');
    final target = hasScheme ? trimmed : 'https://$trimmed';
    return 'https://web.archive.org/save/$target';
  }

  static String projectGutenbergSearch(String query) =>
      'https://www.gutenberg.org/ebooks/search/?query=${Uri.encodeComponent(query)}';

  static String openLibrarySearch(String query) =>
      'https://openlibrary.org/search?q=${Uri.encodeComponent(query)}';
}
