import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../../shared/router/app_router.dart';
import '../providers/home_providers.dart';
import '../../shared/widgets/desktop_shortcuts.dart';
import '../../shared/providers/web_chrome_providers.dart';
import '../../sync/providers/knowledge_sync_providers.dart';
import '../../sync/widgets/intelligence_sheet.dart';
import '../../../models/knowledge_sync.dart';
import '../widgets/based_insight_card.dart';
import '../widgets/crush_argument_bar.dart';
import '../widgets/home_intelligence_section.dart';
import '../widgets/hub_nav_cards.dart';
import '../widgets/quick_category_chips.dart';
import '../widgets/streak_achievement_strip.dart';
import '../widgets/suggest_claim_cta.dart';
import '../../suggestions/widgets/my_suggestions_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _syncPanelKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openIntelligence(BuildContext context) {
    final compactWeb = kIsWeb && ResponsiveLayout.isCompact(context);
    if (compactWeb) {
      showIntelligenceSheet(context);
      return;
    }
    ref.read(webIntelligenceChromeProvider.notifier).expand();
    final target = _syncPanelKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openCrusher(BuildContext context, String query) {
    final encoded = Uri.encodeComponent(query);
    context.push('${AppRoutes.crusher}?q=$encoded');
  }

  void _openCategory(BuildContext context, QuickCategory category) {
    context.push('${AppRoutes.tree}?category=${category.topicId}');
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final progress = ref.watch(userProgressProvider);
    final insights = ref.watch(allInsightsProvider);
    final syncStatus = ref.watch(knowledgeSyncStateProvider);
    final isWide = ResponsiveLayout.useSplitPane(context);
    final compactWeb = kIsWeb && ResponsiveLayout.isCompact(context);
    final isCompact = ResponsiveLayout.isCompact(context);

    final updateAvailable = syncStatus.maybeWhen(
      data: (s) =>
          s.remoteKbVersion != null &&
          KnowledgeVersion.isNewer(s.remoteKbVersion!, s.effectiveKbVersion),
      orElse: () => false,
    );

    final dayIndex = insights.maybeWhen(
      data: (list) => DateTime.now().day % list.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: ResponsiveLayout.appBarHeight(context),
        title: Row(
          children: [
            Icon(Icons.bolt_rounded, color: context.sd.accentGold, size: 22),
            const SizedBox(width: AppSpacing.xs),
            const Expanded(
              child: Text(
                'Socialism Destroyer',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (DesktopShortcuts.isEnabled(context))
            IconButton(
              icon: const Icon(Icons.keyboard_outlined),
              tooltip: 'Keyboard shortcuts',
              onPressed: () => DesktopShortcuts.showHelp(context),
            ),
          IconButton(
            tooltip: 'Sync Latest Intelligence',
            onPressed: () => _openIntelligence(context),
            icon: Badge(
              isLabelVisible: updateAvailable,
              label: const Text(''),
              backgroundColor: context.sd.accentGold,
              child: const Icon(Icons.cloud_sync_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ResponsiveContent(
              child: ListView(
                controller: _scrollController,
                padding: ResponsiveLayout.pagePadding(context),
                children: [
                  progress.when(
                    data: (p) => SdFadeIn(
                      child: StreakAchievementStrip(progress: p),
                    ),
                    loading: () => const SizedBox(
                      height: 72,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: isWide ? AppSpacing.lg : AppSpacing.sm),
                  SdFadeIn(
                    delayIndex: 1,
                    child: CrushArgumentBar(
                      onSubmit: (q) => _openCrusher(context, q),
                      compact: isCompact,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 2,
                    child: QuickCategoryChips(
                      onCategoryTap: (c) => _openCategory(context, c),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  insights.when(
                    data: (list) => SdFadeIn(
                      delayIndex: 3,
                      child: BasedInsightCard(
                        insights: list,
                        initialIndex: dayIndex,
                      ),
                    ),
                    loading: () => const SdCard(
                      child: SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 4,
                    child: const SuggestClaimCta(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SdFadeIn(
                    delayIndex: 5,
                    child: const MySuggestionsPanel(),
                  ),
                  SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
                  const SdSectionHeader(title: 'Explore'),
                  SizedBox(height: isCompact ? AppSpacing.xs : AppSpacing.sm),
                  SdFadeIn(
                    delayIndex: 6,
                    child: HubNavCards(
                      onTree: () => context.go(AppRoutes.tree),
                      onLibrary: () => context.go(AppRoutes.library),
                      onStudyTools: () => context.push(AppRoutes.studyTools),
                      onDebate: () => context.push(AppRoutes.debate),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!compactWeb)
            HomeIntelligenceSection(syncPanelKey: _syncPanelKey),
        ],
      ),
    );
  }
}