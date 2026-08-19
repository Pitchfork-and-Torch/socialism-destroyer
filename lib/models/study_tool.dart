import 'package:equatable/equatable.dart';

class StudyTool extends Equatable {
  const StudyTool({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.tweetRef,
  });

  final String id;
  final String name;
  final String description;
  final String url;
  final int? tweetRef;

  factory StudyTool.fromJson(Map<String, dynamic> json) => StudyTool(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        url: json['url'] as String,
        tweetRef: json['tweetRef'] as int?,
      );

  @override
  List<Object?> get props => [id];
}

class StudyToolCategory extends Equatable {
  const StudyToolCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.tools,
  });

  final String id;
  final String title;
  final String icon;
  final List<StudyTool> tools;

  factory StudyToolCategory.fromJson(Map<String, dynamic> json) =>
      StudyToolCategory(
        id: json['id'] as String,
        title: json['title'] as String,
        icon: json['icon'] as String? ?? 'extension',
        tools: (json['tools'] as List<dynamic>)
            .map((e) => StudyTool.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id];
}

class StudyToolsDocument extends Equatable {
  const StudyToolsDocument({
    required this.categories,
    this.sourceNote,
  });

  final List<StudyToolCategory> categories;
  final String? sourceNote;

  factory StudyToolsDocument.fromJson(Map<String, dynamic> json) =>
      StudyToolsDocument(
        sourceNote: json['sourceNote'] as String?,
        categories: (json['categories'] as List<dynamic>)
            .map((e) => StudyToolCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [categories];
}