import 'package:equatable/equatable.dart';

enum SourceType { government, academic, primary, thinkTank, other }

/// A citable reference attached to a [Claim].
///
/// [id] enables stable cross-references in RAG citations. [accessedAt]
/// records when the link was last verified during content updates.
class Source extends Equatable {
  const Source({
    required this.title,
    required this.url,
    required this.type,
    this.id,
    this.doi,
    this.accessedAt,
    this.citation,
  });

  final String? id;
  final String title;
  final String url;
  final String? doi;
  final SourceType type;
  final String? accessedAt;
  final String? citation;

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        id: json['id'] as String?,
        title: json['title'] as String,
        url: json['url'] as String,
        doi: json['doi'] as String?,
        type: _parseType(json['type'] as String?),
        accessedAt: json['accessedAt'] as String?,
        citation: json['citation'] as String?,
      );

  static SourceType _parseType(String? raw) => switch (raw) {
        'government' => SourceType.government,
        'academic' => SourceType.academic,
        'primary' => SourceType.primary,
        'think_tank' => SourceType.thinkTank,
        _ => SourceType.other,
      };

  String get typeKey => switch (type) {
        SourceType.thinkTank => 'think_tank',
        _ => type.name,
      };

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'url': url,
        if (doi != null) 'doi': doi,
        'type': typeKey,
        if (accessedAt != null) 'accessedAt': accessedAt,
        if (citation != null) 'citation': citation,
      };

  @override
  List<Object?> get props => [id, title, url, doi];
}