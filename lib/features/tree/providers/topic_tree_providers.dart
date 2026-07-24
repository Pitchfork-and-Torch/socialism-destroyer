import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/claim.dart';
import '../../../models/topic.dart';
import '../../../providers/app_providers.dart';
import '../services/topic_tree_index.dart';

/// Combined topics + claims index for the navigable tree UI.
final topicTreeIndexProvider = FutureProvider<TopicTreeIndex>((ref) async {
  final knowledge = ref.watch(knowledgeServiceProvider);
  final topics = await knowledge.getTopics();
  final claims = await knowledge.getClaims();
  return TopicTreeIndex(roots: topics, claims: claims);
});

class TopicTreeUiState {
  const TopicTreeUiState({
    this.filter = '',
    this.expandedIds = const {},
    this.selectedTopicId,
    this.categoryFilter,
  });

  final String filter;
  final Set<String> expandedIds;
  final String? selectedTopicId;
  final String? categoryFilter;

  TopicTreeUiState copyWith({
    String? filter,
    Set<String>? expandedIds,
    String? selectedTopicId,
    String? categoryFilter,
    bool clearSelection = false,
    bool clearCategory = false,
  }) =>
      TopicTreeUiState(
        filter: filter ?? this.filter,
        expandedIds: expandedIds ?? this.expandedIds,
        selectedTopicId:
            clearSelection ? null : (selectedTopicId ?? this.selectedTopicId),
        categoryFilter:
            clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      );
}

class TopicTreeUiNotifier extends StateNotifier<TopicTreeUiState> {
  TopicTreeUiNotifier() : super(const TopicTreeUiState());

  void setFilter(String value) => state = state.copyWith(filter: value);

  void setCategory(String? topicId) => state = state.copyWith(
        categoryFilter: topicId,
        clearCategory: topicId == null,
      );

  void selectTopic(String? topicId) => state = state.copyWith(
        selectedTopicId: topicId,
        clearSelection: topicId == null,
      );

  void toggleExpanded(String topicId) {
    final next = Set<String>.from(state.expandedIds);
    if (next.contains(topicId)) {
      next.remove(topicId);
    } else {
      next.add(topicId);
    }
    state = state.copyWith(expandedIds: next);
  }

  void expandAll(TopicTreeIndex index) {
    final ids = <String>{};
    void walk(Topic t) {
      ids.add(t.id);
      for (final c in t.children) {
        walk(c);
      }
    }

    for (final root in index.roots) {
      walk(root);
    }
    state = state.copyWith(expandedIds: ids);
  }

  void collapseAll() => state = state.copyWith(expandedIds: {});

  void applyFilterExpansion(TopicTreeIndex index) {
    if (state.filter.trim().isEmpty) return;
    final auto = index.autoExpandedForFilter(state.filter);
    state = state.copyWith(
      expandedIds: {...state.expandedIds, ...auto},
    );
  }
}

final topicTreeUiProvider =
    StateNotifierProvider<TopicTreeUiNotifier, TopicTreeUiState>(
  (ref) => TopicTreeUiNotifier(),
);

/// Selected topic object resolved from index + UI state.
final selectedTopicProvider = Provider<AsyncValue<Topic?>>((ref) {
  final indexAsync = ref.watch(topicTreeIndexProvider);
  final ui = ref.watch(topicTreeUiProvider);

  return indexAsync.when(
    data: (index) {
      if (ui.selectedTopicId == null) return const AsyncData(null);
      return AsyncData(_findTopic(index.roots, ui.selectedTopicId!));
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

/// Claims for the selected topic (includes subtopics).
final selectedTopicClaimsProvider = Provider<AsyncValue<List<Claim>>>((ref) {
  final indexAsync = ref.watch(topicTreeIndexProvider);
  final ui = ref.watch(topicTreeUiProvider);

  return indexAsync.when(
    data: (index) {
      final topic = ui.selectedTopicId != null
          ? _findTopic(index.roots, ui.selectedTopicId!)
          : null;
      if (topic == null) return const AsyncData([]);
      var claims = index.claimsFor(topic);
      final q = ui.filter.trim().toLowerCase();
      if (q.isNotEmpty) {
        claims = claims
            .where(
              (c) =>
                  c.title.toLowerCase().contains(q) ||
                  c.searchText.toLowerCase().contains(q) ||
                  c.tags.any((t) => t.toLowerCase().contains(q)),
            )
            .toList();
      }
      return AsyncData(claims);
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

Topic? _findTopic(List<Topic> roots, String id) {
  for (final root in roots) {
    if (root.id == id) return root;
    final found = _findTopic(root.children, id);
    if (found != null) return found;
  }
  return null;
}