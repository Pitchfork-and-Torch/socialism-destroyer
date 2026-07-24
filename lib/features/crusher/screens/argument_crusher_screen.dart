import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';

import '../../../models/crusher_result.dart';
import '../../../themes/themes.dart';
import '../../../utils/responsive_layout.dart';
import '../../home/providers/home_providers.dart';
import '../../home/widgets/crush_argument_bar.dart';
import '../../shared/providers/shell_providers.dart';
import '../../shared/router/app_router.dart';
import '../providers/crusher_providers.dart';
import '../services/debate_history_service.dart';
import '../widgets/crusher_result_panel.dart';

class ArgumentCrusherScreen extends ConsumerStatefulWidget {
  const ArgumentCrusherScreen({
    super.key,
    this.initialQuery,
    this.autofocusSearch = false,
  });

  final String? initialQuery;
  final bool autofocusSearch;

  @override
  ConsumerState<ArgumentCrusherScreen> createState() =>
      _ArgumentCrusherScreenState();
}

class _ArgumentCrusherScreenState extends ConsumerState<ArgumentCrusherScreen> {
  late final TextEditingController _controller;
  final _crushBarKey = GlobalKey<CrushArgumentBarState>();
  final _screenshotController = ScreenshotController();
  final _shareCardController = ScreenshotController();

  CrusherResult? _result;
  bool _loading = false;
  String? _error;
  bool _autoRan = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _crush());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _crush() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await ref.read(crusherActionsProvider).crush(text);
      await ref.read(userProgressProvider.notifier).recordCrush();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
        _autoRan = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _autoRan = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shellUiProvider, (previous, next) {
      if (previous?.searchFocusTick != next.searchFocusTick) {
        _crushBarKey.currentState?.requestFocus();
      }
    });

    final theme = Theme.of(context);
    final sd = context.sd;
    final history = ref.watch(debateHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Argument Crusher'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Recent debates',
              onPressed: () => _showHistory(context, history),
            ),
        ],
      ),
      body: ResponsiveContent(
        child: ListView(
          padding: ResponsiveLayout.pagePadding(context),
          children: [
            Text(
              'Destroy Bad Arguments',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: sd.accentGold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Semantic analysis maps opponent claims to curated, sourced counter-arguments — with fallacies, evidence, and export.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final q = _controller.text.trim();
                  final path = q.isEmpty
                      ? AppRoutes.debate
                      : '${AppRoutes.debate}?q=${Uri.encodeComponent(q)}&mode=spar';
                  context.push(path);
                },
                icon: const Icon(Icons.forum_outlined, size: 18),
                label: const Text('Open Debate Simulator (multi-turn)'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CrushArgumentBar(
              key: _crushBarKey,
              controller: _controller,
              compact: true,
              autofocus: widget.autofocusSearch &&
                  (widget.initialQuery == null ||
                      widget.initialQuery!.trim().isEmpty),
              onSubmit: (_) => _crush(),
            ),
            if (_loading) ...[
              const SizedBox(height: AppSpacing.lg),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Analyzing claim · searching knowledge base · detecting fallacies…',
                style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
                textAlign: TextAlign.center,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SdCard(
                accentColor: sd.accentRed,
                child: Text('Error: $_error', style: theme.textTheme.bodyMedium),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AnimatedSwitcher(
                duration: AppMotion.standard,
                child: CrusherResultPanel(
                  key: ValueKey(_result!.id),
                  result: _result!,
                  screenshotController: _screenshotController,
                  shareCardController: _shareCardController,
                ),
              ),
            ] else if (_autoRan && !_loading && _error == null) ...[
              const SizedBox(height: AppSpacing.lg),
              SdCard(
                child: Text(
                  'No response generated — try rephrasing or browse the Topic Tree.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context, List<DebateHistoryMeta> items) {
    final historyService = ref.read(debateHistoryServiceProvider);

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Recent debates', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (e) {
                final confidence = e.matchConfidence != null
                    ? '${(e.matchConfidence! * 100).round()}% match'
                    : null;
                final subtitle = [
                  if (e.intentLabel != null) e.intentLabel,
                  e.modeLabel,
                  confidence,
                ].whereType<String>().join(' · ');

                return ListTile(
                  title: Text(
                    e.inputText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: Theme.of(ctx).textTheme.labelSmall,
                        ),
                      Text(
                        e.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    final cached = historyService.loadResult(e.id);
                    if (cached != null) {
                      setState(() {
                        _controller.text = e.inputText;
                        _result = cached;
                        _error = null;
                        _autoRan = true;
                      });
                      return;
                    }
                    _controller.text = e.inputText;
                    _crush();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}