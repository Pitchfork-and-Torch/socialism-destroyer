import 'package:equatable/equatable.dart';

import 'knowledge_versioning.dart';

enum PdStatus { publicDomain, copyrighted, unknown }

/// Reading recommendation linking a book to a topic with rationale.
class BookRecommendation extends Equatable {
  const BookRecommendation({
    required this.topicId,
    required this.reason,
    this.priority = 0,
  });

  final String topicId;
  final String reason;
  final int priority;

  factory BookRecommendation.fromJson(Map<String, dynamic> json) =>
      BookRecommendation(
        topicId: json['topicId'] as String,
        reason: json['reason'] as String,
        priority: json['priority'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'topicId': topicId,
        'reason': reason,
        'priority': priority,
      };

  @override
  List<Object?> get props => [topicId, priority];
}

/// Public-domain or excerpted work in the in-app library.
class Book extends Equatable implements VersionedEntity {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.pdStatus,
    this.excerptPath,
    this.fullTextPath,
    this.externalUrl,
    this.chapters = const [],
    this.recommendations = const [],
    this.recommendedTopicIds = const [],
    this.schemaVersion = 2,
    this.kbVersion = '2.0.0',
    this.revision = 1,
    this.contentHash = '',
    this.updatedAt = '',
    this.publishedAt,
    String? assetPath,
  }) : assetPath = assetPath ?? excerptPath ?? fullTextPath ?? '';

  final String id;
  final String title;
  final String author;
  final String description;
  final PdStatus pdStatus;
  final String? excerptPath;
  final String? fullTextPath;

  /// Borrow/buy link for copyrighted works not bundled in-app.
  final String? externalUrl;

  /// Legacy single-path field — maps to [excerptPath] when present.
  final String assetPath;

  final List<BookChapter> chapters;
  final List<BookRecommendation> recommendations;
  final List<String> recommendedTopicIds;

  @override
  final int schemaVersion;
  @override
  final String kbVersion;
  @override
  final int revision;
  @override
  final String contentHash;
  @override
  final String updatedAt;
  @override
  final String? publishedAt;

  factory Book.fromJson(Map<String, dynamic> json) {
    final excerptPath =
        json['excerptPath'] as String? ?? json['assetPath'] as String?;
    final recs = (json['recommendations'] as List<dynamic>? ?? [])
        .map((e) => BookRecommendation.fromJson(e as Map<String, dynamic>))
        .toList();
    final legacyTopicIds =
        (json['recommendedTopicIds'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList();

    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      pdStatus: _parsePdStatus(json['pdStatus'] as String?),
      excerptPath: excerptPath,
      fullTextPath: json['fullTextPath'] as String?,
      externalUrl: json['externalUrl'] as String?,
      assetPath: excerptPath,
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((e) => BookChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: recs,
      recommendedTopicIds: legacyTopicIds.isNotEmpty
          ? legacyTopicIds
          : recs.map((r) => r.topicId).toList(),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      kbVersion: json['kbVersion'] as String? ?? '1.0.0',
      revision: json['revision'] as int? ?? 1,
      contentHash: json['contentHash'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      publishedAt: json['publishedAt'] as String?,
    );
  }

  static PdStatus _parsePdStatus(String? raw) => switch (raw) {
        'public_domain' => PdStatus.publicDomain,
        'copyrighted' => PdStatus.copyrighted,
        _ => PdStatus.unknown,
      };

  String get pdStatusKey => switch (pdStatus) {
        PdStatus.publicDomain => 'public_domain',
        PdStatus.copyrighted => 'copyrighted',
        PdStatus.unknown => 'unknown',
      };

  bool get isExternal =>
      externalUrl != null &&
      externalUrl!.isNotEmpty &&
      (fullTextPath == null || fullTextPath!.isEmpty) &&
      (excerptPath == null || excerptPath!.isEmpty);

  bool get isReadableInApp =>
      (fullTextPath != null && fullTextPath!.isNotEmpty) ||
      (excerptPath != null && excerptPath!.isNotEmpty);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'pdStatus': pdStatusKey,
        if (excerptPath != null) 'excerptPath': excerptPath,
        if (fullTextPath != null) 'fullTextPath': fullTextPath,
        if (externalUrl != null) 'externalUrl': externalUrl,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'recommendedTopicIds': recommendedTopicIds,
        'schemaVersion': schemaVersion,
        'kbVersion': kbVersion,
        'revision': revision,
        'contentHash': contentHash,
        'updatedAt': updatedAt,
        if (publishedAt != null) 'publishedAt': publishedAt,
      };

  @override
  List<Object?> get props => [id, title, revision];
}

class BookDocument extends Equatable {
  const BookDocument({required this.meta, required this.books});

  final KnowledgeDocumentMeta meta;
  final List<Book> books;

  factory BookDocument.fromJson(Map<String, dynamic> json) => BookDocument(
        meta: KnowledgeDocumentMeta.fromJson(json),
        books: (json['books'] as List<dynamic>)
            .map((e) => Book.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [meta, books];
}

class BookChapter extends Equatable {
  const BookChapter({
    required this.id,
    required this.title,
    required this.startOffset,
  });

  final String id;
  final String title;
  final int startOffset;

  factory BookChapter.fromJson(Map<String, dynamic> json) => BookChapter(
        id: json['id'] as String,
        title: json['title'] as String,
        startOffset: json['startOffset'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startOffset': startOffset,
      };

  @override
  List<Object?> get props => [id];
}