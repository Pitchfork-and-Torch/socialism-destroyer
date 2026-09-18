import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/claim.dart';
import '../../../models/topic.dart';
import '../../../providers/app_providers.dart';
import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../providers/claim_detail_providers.dart';
import '../providers/topic_tree_providers.dart';
import '../widgets/claim_detail_hero.dart';
import '../widgets/claim_detail_skeleton.dart';
import '../widgets/claim_detail_toolbar.dart';
import '../widgets/claim_evidence_chart.dart';
import '../widgets/claim_section_nav.dart';
import '../widgets/fallacy_callout_panel.dart';
import '../../library/widgets/claim_reading_recommendations.dart';
import '../../study_tools/widgets/research_quick_actions.dart';

class ClaimDetailScreen extends ConsumerWidget {
  const ClaimDetailScreen({super.key, required this.claimId});

  final String claimId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimAsync = ref.watch(claimProvider(claimId));

    return AnimatedSwitcher(
      duration: AppMotion.standard,
      child: claimAsync.when(
        data: (claim) => claim == null
            ? Scaffold(
                key: const ValueKey('not-found'),
                appBar: AppBar(title: const Text('Claim Detail')),
                body: const Center(child: Text('Claim not found')),
              )
            : _ClaimDetailLoaded(
                key: ValueKey(claim.id),
                claim: claim,
              ),
        loading: () => Scaffold(
          key: const ValueKey('loading'),
          appBar: AppBar(title: const Text('Claim Detail')),
          body: const ClaimDetailSkeleton(),
        ),
        error: (e, _) => Scaffold(
          key: const ValueKey('error'),
          appBar: AppBar(title: const Text('Claim Detail')),
          body: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _ClaimDetailLoaded extends ConsumerStatefulWidget {
  const _ClaimDetailLoaded({super.key, required this.claim});

  final Claim claim;

  @override
  ConsumerState<_ClaimDetailLoaded> createState() => _ClaimDetailLoadedState();
}

class _ClaimDetailLoadedState extends ConsumerState<_ClaimDetailLoaded> {
  final _scrollController = ScrollController();
  final _sectionKeys = <String, GlobalKey>{
    for (final s in kClaimSections) s.id: GlobalKey(),
  };
  String _activeSection = 'claim';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Best-effort active section highlight during scroll.
    for (final section in kClaimSections.reversed) {
      final ctx = _sectionKeys[section.id]?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final offset = box.localToGlobal(Offset.zero).dy;
      if (offset < 160) {
        if (_activeSection != section.id) {
          setState(() => _activeSection = section.id);
        }
        break;
      }
    }
  }

  Future<void> _scrollToSection(String id) async {
    final ctx = _sectionKeys[id]?.currentContext;
    if (ctx == null) return;
    setState(() => _activeSection = id);
    await Scrollable.ensureVisible(
      ctx,
      duration: AppMotion.standard,
      curve: AppMotion.standardCurve,
      alignment: 0.08,
    );
  }

  Future<void> _showNoteDialog() async {
    final claim = widget.claim;
    final existing = ref.read(claimNoteProvider(claim.id)) ?? '';
    final controller = TextEditingController(text: existing);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personal Note'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Your talking points, debate prep, or reminders…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      await ref.read(claimNoteActionsProvider).save(claim.id, controller.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;
    final useSplit = ResponsiveLayout.useSplitPane(context);
    final indexAsync = ref.watch(topicTreeIndexProvider);
    final topicTitle = indexAsync.maybeWhen(
      data: (index) => _topicTitleFor(index.roots, claim.topicId),
      orElse: () => null,
    );

    final related = indexAsync.maybeWhen(
      data: (index) => claim.relatedClaimIds
          .map((id) => (id: id, title: index.claimTitle(id) ?? id))
          .toList(),
      orElse: () => <({String id, String title})>[],
    );

    final visibleSections = kClaimSections.where((s) {
      if (s.id == 'fallacies') return claim.fallacies.isNotEmpty;
      if (s.id == 'related') return claim.relatedClaimIds.isNotEmpty;
      if (s.id == 'reading') return true;
      return true;
    }).toList();

    final mainContent = ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(
        bottom: AppSpacing.xxl,
        left: useSplit ? AppSpacing.lg : 0,
        right: useSplit ? AppSpacing.lg : 0,
      ),
      children: [
        ClaimDetailHero(claim: claim, topicTitle: topicTitle),
        Padding(
          padding: ResponsiveLayout.pagePadding(context),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              _section(
                'claim',
                SdFadeIn(
                  child: SocialistClaimBox(
                    claimText: claim.socialistClaimText,
                    quote: claim.claimQuote,
                    quoteAttribution: claim.quoteAttribution,
                    title: 'Their Argument',
                  ),
                ),
              ),
              _section(
                'counter',
                SdFadeIn(
                  delayIndex: 1,
                  child: CounterArgumentHero(
                    headline: claim.title,
                    counterText: claim.executiveSummary,
                  ),
                ),
              ),
              _section(
                'evidence',
                SdFadeIn(
                  delayIndex: 2,
                  child: Column(
                    children: [
                      if (claim.chartData != null) ...[
                        ClaimEvidenceChart(chartData: claim.chartData!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      EvidenceListBox(
                        bullets: claim.evidenceBullets,
                        title: 'Why This Holds Up',
                      ),
                    ],
                  ),
                ),
              ),
              _section(
                'research',
                SdFadeIn(
                  delayIndex: 3,
                  child: ResearchQuickActions(
                    query: claim.title,
                  ),
                ),
              ),
              if (claim.fallacies.isNotEmpty)
                _section(
                  'fallacies',
                  SdFadeIn(
                    delayIndex: 4,
                    child: FallacyCalloutPanel(fallacies: claim.fallacies),
                  ),
                ),
              _section(
                'sources',
                SdFadeIn(
                  delayIndex: 5,
                  child: SdCard(
                    accentColor: context.sd.accentGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SdSectionHeader(
                          title: 'Full Source List',
                          accentColor: context.sd.accentGold,
                          icon: Icons.library_books_outlined,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${claim.sources.length} authoritative sources — tap to open',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SourceCitationList(sources: claim.sources),
                      ],
                    ),
                  ),
                ),
              ),
              _section(
                'america',
                SdFadeIn(
                  delayIndex: 6,
                  child: SdCard(
                    accentColor: context.sd.accentGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SdSectionHeader(
                          title: 'Why This Matters for America',
                          accentColor: AppColors.goldLight,
                          icon: Icons.flag_outlined,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          claim.whyItMatters,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _section(
                'reading',
                SdFadeIn(
                  delayIndex: 6,
                  child: ClaimReadingRecommendations(claimId: claim.id),
                ),
              ),
              if (claim.relatedClaimIds.isNotEmpty)
                _section(
                  'related',
                  SdFadeIn(
                    delayIndex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SdSectionHeader(
                          title: 'Related Claims',
                          icon: Icons.link_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...claim.relatedClaimIds.asMap().entries.map(
                              (e) => SdFadeIn(
                                delayIndex: 7 + e.key,
                                child: _RelatedClaimCard(relatedId: e.value),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          claim.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          ClaimDetailToolbar(
            claim: claim,
            onNote: _showNoteDialog,
          ),
        ],
      ),
      body: useSplit
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: ClaimSectionNav(
                    sections: visibleSections,
                    activeId: _activeSection,
                    onSectionTap: _scrollToSection,
                    relatedClaims: related,
                    onRelatedTap: (id) => context.push('/claim/$id'),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: ResponsiveContent(child: mainContent),
                ),
              ],
            )
          : ResponsiveContent(child: mainContent),
    );
  }

  Widget _section(String id, Widget child) {
    return Padding(
      key: _sectionKeys[id],
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: child,
    );
  }

  String? _topicTitleFor(List<Topic> roots, String topicId) {
    for (final root in roots) {
      if (root.id == topicId) return root.title;
      for (final child in root.children) {
        if (child.id == topicId) return child.title;
      }
    }
    return topicId;
  }
}

class _RelatedClaimCard extends ConsumerWidget {
  const _RelatedClaimCard({required this.relatedId});

  final String relatedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(claimProvider(relatedId));

    return relatedAsync.when(
      data: (claim) {
        if (claim == null) {
          return ListTile(
            title: Text(relatedId),
            onTap: () => context.push('/claim/$relatedId'),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ClaimCard(
            claim: claim,
            variant: ClaimCardVariant.standard,
            onTap: () => context.push('/claim/$relatedId'),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => ListTile(
        title: Text(relatedId),
        onTap: () => context.push('/claim/$relatedId'),
      ),
    );
  }
}