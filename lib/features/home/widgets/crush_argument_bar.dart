import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../themes/themes.dart';
import '../../crusher/widgets/voice_input_button.dart';

/// Prominent home-hub input — routes users into the Argument Crusher.
class CrushArgumentBar extends StatefulWidget {
  const CrushArgumentBar({
    super.key,
    required this.onSubmit,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.compact = false,
  });

  final void Function(String text) onSubmit;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool compact;

  @override
  State<CrushArgumentBar> createState() => CrushArgumentBarState();
}

class CrushArgumentBarState extends State<CrushArgumentBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  void requestFocus() => _focusNode.requestFocus();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final isCompact = widget.compact;

    return Semantics(
      label: 'Crush any argument',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              sd.accentGold.withValues(alpha: 0.55),
              sd.accentRed.withValues(alpha: 0.35),
              sd.accentGold.withValues(alpha: 0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: sd.accentGold.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: sd.surfaceOverlay,
            borderRadius: BorderRadius.circular(18.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? AppSpacing.sm + 2 : AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isCompact)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Crush Any Argument',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: sd.accentGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      _BoltIcon(animate: !MediaQuery.disableAnimationsOf(context)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crush Any Argument',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: sd.accentGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Paste, type, or speak a socialist claim — get sourced facts.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Material(
                  color: sd.surfaceRaised,
                  borderRadius: BorderRadius.circular(14),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    maxLines: isCompact ? 3 : 3,
                    minLines: isCompact ? 2 : 2,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _submit(),
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. "The Nordic countries prove democratic socialism works…"',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: sd.textLow,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    VoiceInputButton(
                      onTranscript: (t) {
                        _controller.text = t;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SdButton(
                        label: 'Crush It',
                        icon: Icons.bolt_rounded,
                        expand: true,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoltIcon extends StatelessWidget {
  const _BoltIcon({required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final icon = Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: sd.accentGold.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.bolt_rounded, color: sd.accentGold, size: 28),
    );
    if (!animate) return icon;
    return icon
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 2400.ms,
          color: sd.accentGold.withValues(alpha: 0.25),
        );
  }
}