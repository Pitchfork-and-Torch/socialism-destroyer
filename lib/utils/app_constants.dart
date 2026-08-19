abstract final class AppConstants {
  static const String appName = 'Socialism Destroyer';
  static const String appSubtitle = 'The Pro-America Liberty Argument Engine';
  static const String knowledgeBaseVersion = '3.1.1';
  static const String knowledgeBaseUpdated = '2026-07-05';

  /// Public knowledge delta host (Cloudflare Pages `/knowledge` static tree).
  static const String defaultKnowledgeCdnUrl =
      'https://destroyer.jonbailey.xyz/knowledge';

  static const String knowledgeManifestAsset =
      'assets/data/v2/knowledge_manifest.json';
  static const String claimsAsset = 'assets/data/claims_seed.json';
  static const String topicsAsset = 'assets/data/v2/topics.json';
  static const String insightsAsset = 'assets/data/daily_insights.json';
  static const String changelogAsset = 'assets/data/changelog.json';
  static const String booksAssetDir = 'assets/data/books/';

  static const Duration searchDebounce = Duration(milliseconds: 200);
  static const int maxSearchResults = 50;
  static const int minClaimsTarget = 90;
  static const int knowledgeSchemaVersion = 2;

  static const String githubIssuesUrl =
      'https://github.com/Pitchfork-and-Torch/socialism-destroyer/issues';

}