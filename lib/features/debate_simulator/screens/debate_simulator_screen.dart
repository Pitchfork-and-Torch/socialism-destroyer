import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import '../../../models/debate_playlist.dart';
import '../../../models/debate_session.dart';
import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../providers/debate_providers.dart';
import '../services/debate_export_service.dart';
import '../widgets/debate_drill_panel.dart';
import '../widgets/debate_evidence_sidebar.dart';
import '../widgets/debate_setup_panel.dart';
import '../widgets/debate_share_card.dart';
import '../widgets/debate_transcript.dart';

class DebateSimulatorScreen extends ConsumerStatefulWidget {
  const DebateSimulatorScreen({
    super.key,
    this.initialQuery,
    this.initialClaimId,
    this.initialTopicId,
    this.initialMode,
  });

  final String? initialQuery;
  final String? initialClaimId;
  final String? initialTopicId;
  final DebateMode? initialMode;

  @override
  ConsumerState<DebateSimulatorScreen> createState() =>
      _DebateSimulatorScreenState();
}

class _DebateSimulatorScreenState
    extends ConsumerState<DebateSimulatorScreen> {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  final _shareCardController = ScreenshotController();
  bool _scoreNext = false;
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;
    final score = _scoreNext ||
        (ref.read(activeDebateProvider).valueOrNull?.mode ==
            DebateMode.challenge);
    _composer.clear();
    setState(() {
      _scoreNext = false;
      _sending = true;
    });
    try {
      await ref.read(activeDebateProvider.notifier).send(
            text,
            requestScore: score,
          );
      if (_scrollController.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AppMotion.standard,
            curve: Curves.easeOut,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _exportMd(DebateSession session) async {
    await DebateExportService.copyMarkdown(session);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debate transcript copied as Markdown'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportImage(DebateSession session) async {
    var bytes = await DebateExportService.captureShareCard(
      context: context,
      session: session,
    );
    bytes ??= await DebateExportService.captureImage(
      controller: _shareCardController,
    );
    if (!mounted) return;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not render image card — try Copy Markdown or PDF'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final how = await DebateExportService.shareImage(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          how == 'downloaded'
              ? 'Image card downloaded (debate-simulator.png)'
              : 'Image card ready to share',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _startDrill(DebatePlaylist playlist) async {
    final first = playlist.prompts.first;
    ref.read(debateDrillProvider.notifier).start(playlist);
    await ref.read(activeDebateProvider.notifier).start(
          mode: DebateMode.challenge,
          seedArgument: first.text,
          claimId: first.claimId,
          topicId: playlist.topicId,
          title: 'Drill: ${playlist.title}',
        );
  }

  Future<void> _drillSubmit(String text) async {
    setState(() => _sending = true);
    try {
      await ref.read(activeDebateProvider.notifier).send(
            text,
            requestScore: true,
          );
      ref.read(debateDrillProvider.notifier).next();
      final drill = ref.read(debateDrillProvider);
      if (drill.active && drill.playlist != null) {
        final prompt = drill.playlist!.prompts[drill.promptIndex];
        await ref.read(activeDebateProvider.notifier).appendChallengeOpening(
              seedArgument: prompt.text,
              claimId: prompt.claimId,
            );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncSession = ref.watch(activeDebateProvider);
    final history = ref.watch(debateSessionsListProvider);
    final drill = ref.watch(debateDrillProvider);
    final wide = ResponsiveLayout.useSplitPane(context);
    final theme = Theme.of(context);
    final sd = context.sd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debate Simulator'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Session history',
              icon: const Icon(Icons.history),
              onPressed: () => _showHistory(context, history),
            ),
          asyncSession.maybeWhen(
            data: (session) {
              if (session == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                tooltip: 'Export & session',
                onSelected: (value) async {
                  switch (value) {
                    case 'copy':
                      await _exportMd(session);
                    case 'share':
                      await DebateExportService.shareMarkdown(session);
                    case 'pdf':
                      await DebateExportService.exportPdf(session);
                    case 'image':
                      await _exportImage(session);
                    case 'new':
                      ref.read(debateDrillProvider.notifier).exit();
                      ref.read(activeDebateProvider.notifier).clear();
                    case 'score':
                      await ref.read(activeDebateProvider.notifier).scoreLast();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Text('Copy Markdown'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share transcript'),
                  ),
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Text('Export PDF'),
                  ),
                  const PopupMenuItem(
                    value: 'image',
                    child: Text('Share image card'),
                  ),
                  if (session.mode == DebateMode.spar)
                    const PopupMenuItem(
                      value: 'score',
                      child: Text('Score my last reply'),
                    ),
                  const PopupMenuItem(
                    value: 'new',
                    child: Text('New debate'),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncSession.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: ResponsiveLayout.pagePadding(context),
            child: SdCard(
              accentColor: sd.accentRed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: $e', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () {
                      ref.read(debateDrillProvider.notifier).exit();
                      ref.read(activeDebateProvider.notifier).clear();
                    },
                    child: const Text('Back to setup'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (session) {
          if (session == null) {
            return ResponsiveContent(
              child: ListView(
                padding: ResponsiveLayout.pagePadding(context),
                children: [
                  DebateSetupPanel(
                    initialSeed: widget.initialQuery,
                    initialClaimId: widget.initialClaimId,
                    initialTopicId: widget.initialTopicId,
                    initialMode: widget.initialMode,
                    onStart: ({
                      required mode,
                      seedArgument,
                      claimId,
                      topicId,
                    }) {
                      return ref.read(activeDebateProvider.notifier).start(
                            mode: mode,
                            seedArgument: seedArgument,
                            claimId: claimId,
                            topicId: topicId,
                          );
                    },
                    onStartDrill: _startDrill,
                  ),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const SdSectionHeader(title: 'Recent sessions'),
                    const SizedBox(height: AppSpacing.sm),
                    ...history.take(8).map(
                      (s) => ListTile(
                        leading: Icon(
                          s.mode == DebateMode.challenge
                              ? Icons.school_outlined
                              : Icons.bolt_outlined,
                          color: sd.accentGold,
                        ),
                        title: Text(
                          s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${s.mode.name} · ${s.turnCount} turns'
                          '${s.averageUserScore != null ? ' · avg ${s.averageUserScore!.round()}' : ''}',
                        ),
                        onTap: () => ref
                            .read(activeDebateProvider.notifier)
                            .load(s.id),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // Offstage share card for PNG capture.
          final shareOffstage = Offstage(
            child: Screenshot(
              controller: _shareCardController,
              child: DebateShareCard(session: session),
            ),
          );

          final transcript = DebateTranscript(
            session: session,
            scrollController: wide ? _scrollController : null,
          );
          final sidebar = DebateEvidenceSidebar(
            session: session,
            compact: !wide,
          );

          final drillPanel = drill.active && drill.playlist != null
              ? DebateDrillPanel(
                  playlist: drill.playlist!,
                  promptIndex: drill.promptIndex,
                  onSubmit: _drillSubmit,
                  onSkip: () => ref.read(debateDrillProvider.notifier).next(),
                  onExit: () => ref.read(debateDrillProvider.notifier).exit(),
                )
              : null;

          return Column(
            children: [
              shareOffstage,
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: ResponsiveLayout.pagePadding(context),
                              child: Column(
                                children: [
                                  if (drillPanel != null) ...[
                                    drillPanel,
                                    const SizedBox(height: AppSpacing.md),
                                  ],
                                  Expanded(child: transcript),
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(width: 1, color: sd.borderSubtle),
                          Expanded(
                            flex: 2,
                            child: ListView(
                              padding: ResponsiveLayout.pagePadding(context),
                              children: [sidebar],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        controller: _scrollController,
                        padding: ResponsiveLayout.pagePadding(context),
                        children: [
                          if (drillPanel != null) ...[
                            drillPanel,
                            const SizedBox(height: AppSpacing.md),
                          ],
                          ...session.turns.asMap().entries.map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _CompactTurn(
                                turn: e.value,
                                index: e.key,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          sidebar,
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
              ),
              if (!drill.active)
                _ComposerBar(
                  controller: _composer,
                  loading: _sending,
                  scoreNext: _scoreNext,
                  showScoreToggle: session.mode == DebateMode.spar,
                  onToggleScore: () =>
                      setState(() => _scoreNext = !_scoreNext),
                  onSend: _send,
                  hint: session.mode == DebateMode.challenge
                      ? 'Write your rebuttal…'
                      : 'Paste the next opponent claim…',
                ),
            ],
          );
        },
      ),
    );
  }

  void _showHistory(BuildContext context, List<DebateSession> items) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Debate sessions',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (s) => ListTile(
                title: Text(
                  s.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${s.mode.name} · ${s.turnCount} turns'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(activeDebateProvider.notifier)
                        .delete(s.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                onTap: () {
                  ref.read(activeDebateProvider.notifier).load(s.id);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactTurn extends StatelessWidget {
  const _CompactTurn({required this.turn, required this.index});

  final DebateTurn turn;
  final int index;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final isUser = turn.role == DebateRole.user;
    final isSystem = turn.role == DebateRole.system;
    final who = switch (turn.role) {
      DebateRole.user => 'You',
      DebateRole.engine => 'Engine',
      DebateRole.system => 'System',
    };
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          '${index + 1}. $who${turn.label != null ? ' · ${turn.label}' : ''}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: isUser ? sd.accentRed : sd.accentGold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSystem
                ? sd.surfaceOverlay.withValues(alpha: 0.6)
                : (isUser
                    ? sd.accentRed.withValues(alpha: 0.12)
                    : sd.accentGold.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSystem
                  ? sd.borderSubtle
                  : (isUser
                      ? sd.accentRed.withValues(alpha: 0.45)
                      : sd.accentGold),
            ),
          ),
          child: SelectableText(turn.text, style: theme.textTheme.bodyMedium),
        ),
        if (turn.feedback != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SdCard(
            child: Text(
              'Score ${turn.feedback!.overallScore}/100 — ${turn.feedback!.gradeLabel}',
              style: theme.textTheme.labelLarge?.copyWith(color: sd.accentGold),
            ),
          ),
        ],
      ],
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.onSend,
    required this.loading,
    required this.scoreNext,
    required this.showScoreToggle,
    required this.onToggleScore,
    required this.hint,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;
  final bool scoreNext;
  final bool showScoreToggle;
  final VoidCallback onToggleScore;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    return Material(
      elevation: 8,
      color: sd.surfaceRaised,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showScoreToggle)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Score this reply'),
                    selected: scoreNext,
                    onSelected: (_) => onToggleScore(),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: loading ? null : onSend,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
