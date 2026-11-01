import '../../../models/claim.dart';
import '../../../models/topic.dart';

/// In-memory index for fast topic-tree search, filtering, and claim lookup.
class TopicTreeIndex {
  TopicTreeIndex({
    required List<Topic> roots,
    required List<Claim> claims,
  })  : roots = List.unmodifiable(roots),
        _claims = List.unmodifiable(claims) {
    _titleById = {for (final c in _claims) c.id: c.title};
  }

  final List<Topic> roots;
  final List<Claim> _claims;
  late final Map<String, String> _titleById;

  int get topLevelCount => roots.length;

  String? claimTitle(String id) => _titleById[id];

  /// All claims under [topic] including subtopic descendants.
  List<Claim> claimsFor(Topic topic) {
    final ids = topic.descendantIds.toSet();
    return _claims.where((c) => ids.contains(c.topicId)).toList();
  }

  /// Direct claims assigned to this topic id only.
  List<Claim> directClaimsFor(String topicId) =>
      _claims.where((c) => c.topicId == topicId).toList();

  /// Whether [topic] or any descendant claims match [filter].
  bool matchesFilter(Topic topic, String filter) {
    final q = filter.trim().toLowerCase();
    if (q.isEmpty) return true;

    if (topic.title.toLowerCase().contains(q)) return true;
    if (topic.description.toLowerCase().contains(q)) return true;

    for (final claim in claimsFor(topic)) {
      if (_claimMatches(claim, q)) return true;
    }
    return false;
  }

  /// Topics visible under current filter (roots only).
  List<Topic> filteredRoots(String filter) =>
      roots.where((t) => matchesFilter(t, filter)).toList();

  /// Auto-expand topic ids that match an active filter.
  Set<String> autoExpandedForFilter(String filter) {
    final q = filter.trim().toLowerCase();
    if (q.isEmpty) return {};

    final out = <String>{};
    void walk(Topic topic) {
      if (matchesFilter(topic, q)) out.add(topic.id);
      for (final child in topic.children) {
        walk(child);
      }
    }

    for (final root in roots) {
      walk(root);
    }
    return out;
  }

  int totalClaimsFor(Topic topic) => claimsFor(topic).length;

  bool _claimMatches(Claim claim, String q) {
    if (claim.title.toLowerCase().contains(q)) return true;
    if (claim.socialistClaimText.toLowerCase().contains(q)) return true;
    if (claim.searchText.toLowerCase().contains(q)) return true;
    if (claim.tags.any((t) => t.toLowerCase().contains(q))) return true;
    return false;
  }
}