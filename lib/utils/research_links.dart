/// Deep links to free research tools (Internet Archive, Scholar, etc.).
abstract final class ResearchLinks {
  static String googleScholar(String query) =>
      'https://scholar.google.com/scholar?q=${Uri.encodeComponent(query)}';

  static String semanticScholar(String query) =>
      'https://www.semanticscholar.org/search?q=${Uri.encodeComponent(query)}';

  static String waybackMachine(String url) =>
      'https://web.archive.org/web/*/${Uri.encodeComponent(url)}';

  static String archiveSaveNow(String url) =>
      'https://web.archive.org/save/${url.startsWith('http') ? url : 'https://$url'}';

  static String projectGutenbergSearch(String query) =>
      'https://www.gutenberg.org/ebooks/search/?query=${Uri.encodeComponent(query)}';

  static String openLibrarySearch(String query) =>
      'https://openlibrary.org/search?q=${Uri.encodeComponent(query)}';
}