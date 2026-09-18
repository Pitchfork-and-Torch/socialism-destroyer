import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/debate_playlist.dart';
import '../../../models/debate_session.dart';
import '../../../themes/themes.dart';
import '../providers/debate_providers.dart';

class DebateSetupPanel extends ConsumerStatefulWidget {
  const DebateSetupPanel({
    super.key,
    required this.onStart,
    this.onStartDrill,
    this.initialSeed,
    this.initialClaimId,
    this.initialTopicId,
    this.initialMode,
  });

  final Future<void> Function({
    required DebateMode mode,
    String? seedArgument,
    String? claimId,
    String? topicId,
  }) onStart;

  final void Function(DebatePlaylist playlist)? onStartDrill;

  final String? initialSeed;
  final String? initialClaimId;
  final String? initialTopicId;
  final DebateMode? initialMode;

  @override
  ConsumerState<DebateSetupPanel> createState() => _DebateSetupPanelState();
}

class _DebateSetupPanelState extends ConsumerState<DebateSetupPanel> {
  late DebateMode _mode;
  late final TextEditingController _seedController;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode ?? DebateMode.spar;
    _seedController = TextEditingController(text: widget.initialSeed ?? '');
  }

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      await widget.onStart(
        mode: _mode,
        seedArgument: _seedController.text.trim().isEmpty
            ? null
            : _seedController.text.trim(),
        claimId: widget.initialClaimId,
        topicId: widget.initialTopicId,
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sd = context.sd;
    final playlists = ref.watch(debatePlaylistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Debate Simulator',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: sd.accentGold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Multi-turn training with steelmanned counters, library passage RAG, '
          'live evidence, timed drills, and optional scoring. Fully offline core.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        SegmentedButton<DebateMode>(
          segments: const [
            ButtonSegment(
              value: DebateMode.spar,
              label: Text('Spar'),
              icon: Icon(Icons.bolt_outlined),
            ),
            ButtonSegment(
              value: DebateMode.challenge,
              label: Text('Challenge'),
              icon: Icon(Icons.school_outlined),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        SdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mode == DebateMode.spar ? 'Spar mode' : 'Challenge mode',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _mode == DebateMode.spar
                    ? 'Paste opponent claims. Engine returns sourced counters each turn. Optional score on your drafts.'
                    : 'Engine opens with a steelmanned claim. Write a rebuttal; get scored on evidence and fallacy discipline.',
                style: theme.textTheme.bodySmall?.copyWith(color: sd.textMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _seedController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: _mode == DebateMode.challenge
                ? 'Optional opening claim (or leave blank for a random KB claim)'
                : 'Optional first opponent argument',
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
            hintText: 'e.g. “Capitalism exploits the working class.”',
          ),
        ),
        if (widget.initialClaimId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Seeded claim: ${widget.initialClaimId}',
            style: theme.textTheme.labelMedium?.copyWith(color: sd.accentGold),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _starting ? null : _start,
          icon: _starting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(_starting ? 'Opening floor…' : 'Start debate'),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SdSectionHeader(title: 'Timed drills & playlists'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Practice under the clock. Each prompt is scored in Challenge mode.',
          style: theme.textTheme.bodySmall?.copyWith(color: sd.textMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        playlists.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Playlists unavailable: $e'),
          data: (list) => Column(
            children: list.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: SdCard(
                  onTap: widget.onStartDrill == null
                      ? null
                      : () => widget.onStartDrill!(p),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: sd.accentGold),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: theme.textTheme.titleSmall),
                            Text(
                              '${p.prompts.length} rounds · ${p.defaultSeconds}s · ${p.difficulty}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: sd.textLow,
                              ),
                            ),
                            Text(
                              p.description,
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
