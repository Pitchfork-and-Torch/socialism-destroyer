import 'package:equatable/equatable.dart';

import 'knowledge_versioning.dart';

/// A node in the hierarchical topic tree.
///
/// v2 stores topics as a **flat list** with [parentId] and [path] for scalable
/// indexing (100+ claims, RAG chunk routing). [Topic.buildTree] reconstructs
/// nested [children] for UI. v1 nested JSON (inline `children[]`) is still parsed.
class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    this.parentId,
    this.path,
    this.depth = 0,
    this.children = const [],
    this.schemaVersion = 2,
    this.kbVersion = '2.0.0',
    this.revision = 1,
    this.contentHash = '',
    this.updatedAt = '',
  });

  final String id;
  final String? parentId;
  final String? path;
  final int depth;
  final String title;
  final String description;
  final String icon;
  final int order;
  final List<Topic> children;

  final int schemaVersion;
  final String kbVersion;
  final int revision;
  final String contentHash;
  final String updatedAt;

  bool get isRoot => parentId == null || parentId!.isEmpty;

  /// Backward-compatible alias used by legacy nested JSON.
  List<TopicChild> get childSummaries =>
      children.map(TopicChild.fromTopic).toList();

  /// Parses a flat v2 node or expands a v1 nested parent with inline children.
  factory Topic.fromJson(Map<String, dynamic> json) {
    final inlineChildren = json['children'] as List<dynamic>?;
    final parentId = json['parentId'] as String?;

    if (inlineChildren != null && parentId == null && json['path'] == null) {
      return Topic(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? 'folder',
        order: json['order'] as int? ?? 0,
        children: inlineChildren
            .map((e) => Topic.fromJson(e as Map<String, dynamic>))
            .toList(),
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        kbVersion: json['kbVersion'] as String? ?? '1.0.0',
        revision: json['revision'] as int? ?? 1,
        contentHash: json['contentHash'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
      );
    }

    return Topic(
      id: json['id'] as String,
      parentId: parentId,
      path: json['path'] as String?,
      depth: json['depth'] as int? ?? 0,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'folder',
      order: json['order'] as int? ?? 0,
      schemaVersion: json['schemaVersion'] as int? ?? 2,
      kbVersion: json['kbVersion'] as String? ?? '2.0.0',
      revision: json['revision'] as int? ?? 1,
      contentHash: json['contentHash'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson({bool flat = true}) {
    if (!flat) {
      return {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'order': order,
        'children': children.map((c) => c.toJson(flat: false)).toList(),
      };
    }
    return {
      'id': id,
      if (parentId != null) 'parentId': parentId,
      if (path != null) 'path': path,
      'depth': depth,
      'title': title,
      'description': description,
      'icon': icon,
      'order': order,
      'schemaVersion': schemaVersion,
      'kbVersion': kbVersion,
      'revision': revision,
      'contentHash': contentHash,
      'updatedAt': updatedAt,
    };
  }

  Topic copyWith({
    String? parentId,
    String? path,
    int? depth,
    List<Topic>? children,
  }) =>
      Topic(
        id: id,
        parentId: parentId ?? this.parentId,
        path: path ?? this.path,
        depth: depth ?? this.depth,
        title: title,
        description: description,
        icon: icon,
        order: order,
        children: children ?? this.children,
        schemaVersion: schemaVersion,
        kbVersion: kbVersion,
        revision: revision,
        contentHash: contentHash,
        updatedAt: updatedAt,
      );

  /// Reconstructs a nested tree from a flat v2 topic list.
  static List<Topic> buildTree(List<Topic> flatNodes) {
    final sorted = [...flatNodes]..sort((a, b) => a.order.compareTo(b.order));
    final byId = {for (final t in sorted) t.id: t};
    final childBuckets = <String, List<Topic>>{};

    for (final node in sorted) {
      final pid = node.parentId;
      if (pid != null && pid.isNotEmpty) {
        childBuckets.putIfAbsent(pid, () => []).add(node);
      }
    }

    for (final entry in childBuckets.entries) {
      final parent = byId[entry.key];
      if (parent != null) {
        entry.value.sort((a, b) => a.order.compareTo(b.order));
        byId[entry.key] = parent.copyWith(children: entry.value);
      }
    }

    return sorted
        .where((t) => t.isRoot)
        .map((t) => byId[t.id] ?? t)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// All topic ids in this subtree (self + descendants).
  Iterable<String> get descendantIds sync* {
    yield id;
    for (final child in children) {
      yield* child.descendantIds;
    }
  }

  @override
  List<Object?> get props => [id, parentId, path, order];
}

/// Envelope for `topics.json` / `v2/topics.json`.
class TopicDocument extends Equatable {
  const TopicDocument({required this.meta, required this.topics});

  final KnowledgeDocumentMeta meta;
  final List<Topic> topics;

  factory TopicDocument.fromJson(Map<String, dynamic> json) {
    final rawTopics = (json['topics'] as List<dynamic>)
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();

    final hasFlat = rawTopics.any((t) => t.path != null || t.parentId != null);
    final topics = hasFlat ? Topic.buildTree(rawTopics) : rawTopics;

    return TopicDocument(
      meta: KnowledgeDocumentMeta.fromJson(json),
      topics: topics,
    );
  }

  /// Flat list representation (for export / vector index routing).
  List<Topic> get flatNodes {
    final out = <Topic>[];
    void walk(Topic node, String? parentId, String parentPath, int depth) {
      final path = parentPath.isEmpty ? '/${node.id}' : '$parentPath/${node.id}';
      out.add(node.copyWith(
        children: const [],
        parentId: parentId,
        path: node.path ?? path,
        depth: node.depth > 0 ? node.depth : depth,
      ));
      for (final child in node.children) {
        walk(child, node.id, path, depth + 1);
      }
    }

    for (final root in topics) {
      walk(root, null, '', 0);
    }
    return out;
  }

  @override
  List<Object?> get props => [meta, topics];
}

/// Legacy child summary — retained for v1 JSON compatibility.
class TopicChild extends Equatable {
  const TopicChild({
    required this.id,
    required this.title,
    required this.order,
  });

  final String id;
  final String title;
  final int order;

  factory TopicChild.fromJson(Map<String, dynamic> json) => TopicChild(
        id: json['id'] as String,
        title: json['title'] as String,
        order: json['order'] as int? ?? 0,
      );

  factory TopicChild.fromTopic(Topic topic) => TopicChild(
        id: topic.id,
        title: topic.title,
        order: topic.order,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'order': order,
      };

  @override
  List<Object?> get props => [id];
}