import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/debate_playlist.dart';
import '../../../themes/themes.dart';

/// Timed drill controller UI for playlist-based challenge practice.
class DebateDrillPanel extends StatefulWidget {
  const DebateDrillPanel({
    super.key,
    required this.playlist,
    required this.promptIndex,
    required this.onSubmit,
    required this.onSkip,
    required this.onExit,
  });

  final DebatePlaylist playlist;
  final int promptIndex;
  final Future<void> Function(String text) onSubmit;
  final VoidCallback onSkip;
  final VoidCallback onExit;

  @override
  State<DebateDrillPanel> createState() => _DebateDrillPanelState();
}

class _DebateDrillPanelState extends State<DebateDrillPanel> {
  late final TextEditingController _controller;
  Timer? _timer;
  late int _remaining;
  bool _submitting = false;

  DebatePlaylistPrompt get _prompt =>
      widget.playlist.prompts[widget.promptIndex];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _remaining = _prompt.seconds ?? widget.playlist.defaultSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant DebateDrillPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.promptIndex != widget.promptIndex ||
        oldWidget.playlist.id != widget.playlist.id) {
      _timer?.cancel();
      _controller.clear();
      _remaining = _prompt.seconds ?? widget.playlist.defaultSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining <= 0) {
        t.cancel();
        setState(() {});
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(text);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sd = context.sd;
    final total = widget.playlist.prompts.length;
    final urgent = _remaining <= 15;

    return SdCard(
      accentColor: urgent ? sd.accentRed : sd.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Drill · ${widget.playlist.title}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: sd.accentGold,
                  ),
                ),
              ),
              Text(
                'Round ${widget.promptIndex + 1}/$total',
                style: theme.textTheme.labelMedium,
              ),
              IconButton(
                tooltip: 'Exit drill',
                onPressed: widget.onExit,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: urgent ? sd.accentRed : sd.accentGold,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(_remaining),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: urgent ? sd.accentRed : sd.accentGold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              Text(
                widget.playlist.difficulty,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: sd.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: total == 0
                ? 0
                : (widget.promptIndex + 1) / total,
            minHeight: 4,
            color: sd.accentGold,
            backgroundColor: sd.borderSubtle,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Opponent claim (steelman target)',
            style: theme.textTheme.labelLarge?.copyWith(color: sd.accentRed),
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            _prompt.text,
            style: theme.textTheme.bodyLarge,
          ),
          if (_prompt.hint != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hint: ${_prompt.hint}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: sd.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Your timed rebuttal',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton(
                onPressed: _submitting ? null : widget.onSkip,
                child: const Text('Skip'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_remaining <= 0 ? 'Submit late' : 'Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
