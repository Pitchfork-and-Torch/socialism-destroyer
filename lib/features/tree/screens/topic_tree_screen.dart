import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/claim.dart';
import '../../../models/topic.dart';
import '../../../themes/themes.dart';
import '../../shared/router/app_router.dart';
import '../services/topic_tree_index.dart';
import '../../../utils/responsive_layout.dart';
import '../../home/providers/home_providers.dart';
import '../../shared/providers/shell_providers.dart';
import '../../shared/widgets/desktop_shortcuts.dart';
import '../providers/topic_tree_providers.dart';
import '../widgets/topic_category_chips.dart';
import '../widgets/topic_claims_panel.dart';
import '../widgets/topic_search_bar.dart';
import '../widgets/topic_tree_branch.dart';

class TopicTreeScreen extends ConsumerStatefulWidget {
  const TopicTreeScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  ConsumerState<TopicTreeScreen> createState() => _TopicTreeScreenState();
}

class _TopicTreeScreenState extends ConsumerState<TopicTreeScreen> {
  final _searchKey = GlobalKey<TopicSearchBarState>();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final categoryId = widget.initialCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProgressProvider.notifier).recordTreeVisit();
      if (categoryId != null) {
        ref.read(topicTreeUiProvider.notifier).setCategory(categoryId);
        ref.read(topicTreeUiProvider.notifier).selectTopic(categoryId);
        ref.read(topicTreeUiProvider.notifier).toggleExpanded(categoryId);
      }
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shellUiProvider, (previous, next) {
      if (previous?.searchFocusTick != next.searchFocusTick) {
        _searchKey.currentState?.focusSearch();
      }
    });
    final indexAsync = ref.watch(topicTreeIndexProvider);
    final ui = ref.watch(topicTreeUiProvider);
    final selectedTopic = ref.watch(selectedTopicProvider);
    final selectedClaims = ref.watch(selectedTopicClaimsProvider);
    final useSplit = ResponsiveLayout.useSplitPane(context);

    final categoryForSuggest = ui.categoryFilter ?? widget.initialCategoryId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic Tree'),
        actions: [
          if (useSplit)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Select a topic to preview claims',
              onPressed: () => _showSplitHelp(context),
            ),
          if (DesktopShortcuts.isEnabled(context))
            IconButton(
              icon: const Icon(Icons.keyboard_outlined),
              tooltip: 'Keyboard shortcuts',
              onPressed: () => DesktopShortcuts.showHelp(context),
            ),
        ],
      ),
      body: indexAsync.when(
        data: (index) {
          final visibleRoots = _visibleRoots(index, ui);
          final matchCount = ui.filter.isEmpty
              ? null
              : visibleRoots
                  .map((t) => index.claimsFor(t))
                  .expand((c) => c)
                  .where((c) => _claimMatchesFilter(c, ui.filter))
                  .length;

          final searchHeader = Padding(
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              bottom: AppSpacing.sm,
              top: AppSpacing.sm,
            ),
            child: Column(
              children: [
                TopicSearchBar(
                  key: _searchKey,
                  focusNode: _searchFocus,
                  filter: ui.filter,
                  resultCount: matchCount,
                  onFilterChanged: (v) {
                    ref.read(topicTreeUiProvider.notifier).setFilter(v);
                    ref.read(topicTreeUiProvider.notifier).applyFilterExpansion(
                          index,
                        );
                  },
                  onExpandAll: () =>
                      ref.read(topicTreeUiProvider.notifier).expandAll(index),
                  onCollapseAll: () =>
                      ref.read(topicTreeUiProvider.notifier).collapseAll(),
                ),
                const SizedBox(height: AppSpacing.sm),
                TopicCategoryChips(
                  topics: index.roots,
                  selectedId: ui.categoryFilter,
                  onSelected: (id) {
                    ref.read(topicTreeUiProvider.notifier).setCategory(id);
                    if (id != null) {
                      ref.read(topicTreeUiProvider.notifier).selectTopic(id);
                      ref.read(topicTreeUiProvider.notifier).toggleExpanded(id);
                    }
                  },
                ),
              ],
            ),
          );

          final treeList = ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            itemCount: visibleRoots.length,
            itemBuilder: (context, i) => TopicTreeBranch(
              topic: visibleRoots[i],
              index: index,
              filter: ui.filter,
              expandedIds: ui.expandedIds,
              selectedTopicId: ui.selectedTopicId,
              animationIndex: i,
              onToggle: (id) =>
                  ref.read(topicTreeUiProvider.notifier).toggleExpanded(id),
              onSelect: (id) =>
                  ref.read(topicTreeUiProvider.notifier).selectTopic(id),
              onClaimTap: (claimId) => _openClaim(context, claimId, useSplit),
            ),
          );

          if (useSplit) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchHeader,
                Expanded(
                  child: AdaptiveSplitLayout(
                    sidebarWidth: 380,
                    sidebar: treeList,
                    body: selectedTopic.when(
                      data: (topic) => selectedClaims.when(
                        data: (claims) => TopicClaimsPanel(
                          topic: topic,
                          claims: claims,
                          filter: ui.filter,
                          onClaimTap: (id) => context.push('/claim/$id'),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              searchHeader,
              Expanded(child: treeList),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final path = categoryForSuggest != null
              ? '${AppRoutes.suggestClaim}?topic=$categoryForSuggest'
              : AppRoutes.suggestClaim;
          context.push(path);
        },
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Suggest claim'),
      ),
    );
  }

  List<Topic> _visibleRoots(TopicTreeIndex index, TopicTreeUiState ui) {
    var roots = index.filteredRoots(ui.filter);
    if (ui.categoryFilter != null) {
      roots = roots.where((t) => t.id == ui.categoryFilter).toList();
    }
    return roots;
  }

  bool _claimMatchesFilter(Claim claim, String filter) {
    final q = filter.toLowerCase();
    return claim.title.toLowerCase().contains(q) ||
        claim.searchText.toLowerCase().contains(q);
  }

  void _openClaim(BuildContext context, String claimId, bool useSplit) {
    context.push('/claim/$claimId');
  }

  void _showSplitHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Split view'),
        content: const Text(
          'Select a topic in the left pane to preview sourced claims on the right. '
          'Use Ctrl+K to focus search, or ? for all keyboard shortcuts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}