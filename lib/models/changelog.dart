import 'package:equatable/equatable.dart';

import 'knowledge_sync.dart';

/// Versioned changelog for knowledge-base releases (bundled + synced overlay).
class ChangelogDocument extends Equatable {
  const ChangelogDocument({
    required this.currentVersion,
    required this.lastUpdated,
    required this.entries,
  });

  final String currentVersion;
  final String lastUpdated;
  final List<ChangelogEntry> entries;

  factory ChangelogDocument.fromJson(Map<String, dynamic> json) =>
      ChangelogDocument(
        currentVersion: json['currentVersion'] as String? ?? '1.0.0',
        lastUpdated: json['lastUpdated'] as String? ?? '',
        entries: (json['entries'] as List<dynamic>? ?? [])
            .map((e) => ChangelogEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'currentVersion': currentVersion,
        'lastUpdated': lastUpdated,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  /// Merges [other] entries by version, preferring newer titles/changes.
  ChangelogDocument merge(ChangelogDocument other) {
    final byVersion = <String, ChangelogEntry>{};
    for (final e in entries) {
      byVersion[e.version] = e;
    }
    for (final e in other.entries) {
      byVersion[e.version] = e;
    }
    final merged = byVersion.values.toList()
      ..sort((a, b) => b.version.compareTo(a.version));
    final latest = merged.isEmpty
        ? currentVersion
        : _maxVersion(currentVersion, other.currentVersion, merged.first.version);
    return ChangelogDocument(
      currentVersion: latest,
      lastUpdated: other.lastUpdated.isNotEmpty ? other.lastUpdated : lastUpdated,
      entries: merged,
    );
  }

  static String _maxVersion(String a, String b, String c) {
    final versions = [a, b, c];
    versions.sort((x, y) => KnowledgeVersion.compare(y, x));
    return versions.first;
  }

  @override
  List<Object?> get props => [currentVersion, lastUpdated, entries];
}

class ChangelogEntry extends Equatable {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.title,
    required this.changes,
  });

  final String version;
  final String date;
  final String title;
  final List<String> changes;

  factory ChangelogEntry.fromJson(Map<String, dynamic> json) => ChangelogEntry(
        version: json['version'] as String,
        date: json['date'] as String? ?? '',
        title: json['title'] as String,
        changes: (json['changes'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'date': date,
        'title': title,
        'changes': changes,
      };

  @override
  List<Object?> get props => [version, date, title, changes];
}