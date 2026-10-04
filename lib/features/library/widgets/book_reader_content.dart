import 'package:flutter/material.dart';

import '../../../models/book.dart';
import '../../../models/book_reading.dart';
import '../../../models/reader_settings.dart';
import '../../../themes/themes.dart';
import '../utils/book_content_parser.dart';
import '../utils/reader_theme.dart';

typedef HighlightCallback = void Function(int start, int end, String excerpt);

class BookReaderContent extends StatefulWidget {
  const BookReaderContent({
    super.key,
    required this.content,
    required this.chapters,
    required this.highlights,
    required this.scrollController,
    required this.onProgress,
    required this.onActiveChapter,
    required this.onHighlightRequest,
    this.searchQuery = '',
    this.activeSearchMatch,
    this.initialScrollOffset = 0,
    this.initialCharOffset,
    this.readerSettings = const ReaderSettings(),
  });

  final String content;
  final List<BookChapter> chapters;
  final List<BookHighlight> highlights;
  final ScrollController scrollController;
  final void Function(double offset, double fraction) onProgress;
  final void Function(String? chapterId) onActiveChapter;
  final HighlightCallback onHighlightRequest;
  final String searchQuery;
  final BookSearchMatch? activeSearchMatch;
  final double initialScrollOffset;
  /// Character offset in [content] to scroll to on first layout (e.g. linked chapter).
  final int? initialCharOffset;
  final ReaderSettings readerSettings;
  @override
  State<BookReaderContent> createState() => BookReaderContentState();
}

class BookReaderContentState extends State<BookReaderContent> {
  static const _maxScrollAttempts = 40;

  late List<BookContentBlock> _blocks;
  late List<GlobalKey> _blockKeys;
  bool _restoredScroll = false;
  int _restoreAttempts = 0;

  @override
  void initState() {
    super.initState();
    _blocks = BookContentParser.parse(widget.content, widget.chapters);
    _blockKeys = List.generate(_blocks.length, (_) => GlobalKey());
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreScroll());
  }

  @override
  void didUpdateWidget(BookReaderContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _blocks = BookContentParser.parse(widget.content, widget.chapters);
      _blockKeys = List.generate(_blocks.length, (_) => GlobalKey());
      _restoredScroll = false;
      _restoreAttempts = 0;
    }
    if (widget.activeSearchMatch != null &&
        widget.activeSearchMatch != oldWidget.activeSearchMatch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToOffset(
            widget.activeSearchMatch!.start,
          ));
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  int _blockIndexForCharOffset(int charOffset) {
    var index = 0;
    for (var i = 0; i < _blocks.length; i++) {
      if (_blocks[i].globalStart <= charOffset) {
        index = i;
      }
    }
    return index;
  }

  /// Scroll to [index], building lazy list children if needed. Returns true when done.
  bool _scrollToBlockIndex(int index, {bool animate = true}) {
    if (index < 0 || index >= _blockKeys.length) return true;
    final ctx = _blockKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: animate ? AppMotion.standard : Duration.zero,
        curve: AppMotion.standardCurve,
        alignment: 0.08,
      );
      return true;
    }
    if (!widget.scrollController.hasClients || _blocks.length <= 1) {
      return false;
    }
    final pos = widget.scrollController.position;
    final estimate = (index / (_blocks.length - 1)) * pos.maxScrollExtent;
    pos.jumpTo(estimate.clamp(0.0, pos.maxScrollExtent));
    return false;
  }

  void _restoreScroll() {
    if (_restoredScroll) return;
    if (!widget.scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreScroll());
      return;
    }

    final charOffset = widget.initialCharOffset;
    if (charOffset != null && charOffset > 0) {
      final index = _blockIndexForCharOffset(charOffset);
      if (!_scrollToBlockIndex(index, animate: false)) {
        _restoreAttempts++;
        if (_restoreAttempts < _maxScrollAttempts) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _restoreScroll());
        }
        return;
      }
    } else if (widget.initialScrollOffset > 0) {
      widget.scrollController.jumpTo(
        widget.initialScrollOffset.clamp(
          0,
          widget.scrollController.position.maxScrollExtent,
        ),
      );
    }

    _restoredScroll = true;
    _onScroll();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final pos = widget.scrollController.position;
    final fraction = pos.maxScrollExtent > 0
        ? pos.pixels / pos.maxScrollExtent
        : 0.0;
    widget.onProgress(pos.pixels, fraction);

    final charOffset = (fraction * widget.content.length).round();
    String? chapterId;
    for (final ch in widget.chapters.reversed) {
      if (charOffset >= ch.startOffset) {
        chapterId = ch.id;
        break;
      }
    }
    widget.onActiveChapter(chapterId);
  }

  void scrollToOffset(int charOffset) => _scrollToOffset(charOffset);

  void scrollToChapter(BookChapter chapter) {
    _scrollToOffset(chapter.startOffset);
  }

  void _scrollToOffset(int charOffset, {bool animate = true}) {
    final index = _blockIndexForCharOffset(charOffset);
    var attempts = 0;
    void attempt() {
      if (_scrollToBlockIndex(index, animate: animate)) {
        _onScroll();
        return;
      }
      attempts++;
      if (attempts < _maxScrollAttempts) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attempt());
      }
    }

    attempt();
  }

  Color _highlightColor(String key, ReaderThemeColors colors) => switch (key) {
        'blue' => Colors.blue.withValues(alpha: 0.35),
        'green' => Colors.green.withValues(alpha: 0.35),
        _ => colors.accent.withValues(alpha: 0.35),
      };

  TextSpan _buildSpan(
    String text,
    int globalStart, {
    required TextStyle baseStyle,
    required SdTheme sd,
    required ReaderThemeColors colors,
  }) {
    final spans = <InlineSpan>[];
    final localHighlights = widget.highlights
        .where((h) => h.end > globalStart && h.start < globalStart + text.length)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    var cursor = 0;
    for (final h in localHighlights) {
      final localStart = (h.start - globalStart).clamp(0, text.length);
      final localEnd = (h.end - globalStart).clamp(0, text.length);
      if (localStart > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, localStart),
          style: baseStyle,
        ));
      }
      if (localEnd > localStart) {
        spans.add(TextSpan(
          text: text.substring(localStart, localEnd),
          style: baseStyle.copyWith(
            backgroundColor: _highlightColor(h.colorKey, colors),
          ),
        ));
      }
      cursor = localEnd;
    }

    if (cursor < text.length) {
      var remaining = text.substring(cursor);
      if (widget.searchQuery.length >= 2) {
        spans.addAll(
          _searchSpans(remaining, globalStart + cursor, baseStyle, colors),
        );
      } else {
        spans.add(TextSpan(text: remaining, style: baseStyle));
      }
    }

    return TextSpan(children: spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans);
  }

  List<InlineSpan> _searchSpans(
    String text,
    int globalStart,
    TextStyle baseStyle,
    ReaderThemeColors colors,
  ) {
    final q = widget.searchQuery.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    var cursor = 0;
    while (cursor < text.length) {
      final idx = lower.indexOf(q, cursor);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
        break;
      }
      if (idx > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, idx), style: baseStyle));
      }
      final isActive = widget.activeSearchMatch != null &&
          widget.activeSearchMatch!.start == globalStart + idx;
      spans.add(TextSpan(
        text: text.substring(idx, idx + q.length),
        style: baseStyle.copyWith(
          backgroundColor: isActive
              ? colors.accent.withValues(alpha: 0.65)
              : colors.accent.withValues(alpha: 0.25),
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ));
      cursor = idx + q.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final colors = ReaderThemeColors.forMode(widget.readerSettings.themeMode);

    return ColoredBox(
      color: colors.background,
      child: SelectionArea(
        child: ListView.builder(
          controller: widget.scrollController,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md + (widget.readerSettings.fontScale - 1) * 8,
            AppSpacing.sm,
            AppSpacing.md + (widget.readerSettings.fontScale - 1) * 8,
            AppSpacing.xxl,
          ),
          itemCount: _blocks.length,
          itemBuilder: (context, index) {
            final block = _blocks[index];
            final TextStyle style;
            if (block.isHeader) {
              style = colors.headerStyle(
                widget.readerSettings,
                level: block.level == 0 ? 0 : block.level,
              );
            } else {
              style = colors.bodyStyle(widget.readerSettings);
            }

          final span = _buildSpan(
            block.text,
            block.globalStart,
            baseStyle: style,
            sd: sd,
            colors: colors,
          );

            return Padding(
              key: _blockKeys[index],
              padding: EdgeInsets.only(
                bottom: block.isHeader ? AppSpacing.md : AppSpacing.sm,
                top: block.isHeader ? AppSpacing.md : 0,
              ),
              child: _SelectableParagraph(
                textSpan: span,
                globalStart: block.globalStart,
                onHighlight: widget.onHighlightRequest,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectableParagraph extends StatelessWidget {
  const _SelectableParagraph({
    required this.textSpan,
    required this.globalStart,
    required this.onHighlight,
  });

  final TextSpan textSpan;
  final int globalStart;
  final HighlightCallback onHighlight;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      textSpan,
      contextMenuBuilder: (context, editableTextState) {
        final items = editableTextState.contextMenuButtonItems;
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: [
            ...items,
            ContextMenuButtonItem(
              onPressed: () {
                final sel = editableTextState.textEditingValue.selection;
                editableTextState.hideToolbar();
                if (!sel.isValid || sel.isCollapsed) return;
                final start = globalStart + sel.start;
                final end = globalStart + sel.end;
                final plain = textSpan.toPlainText();
                final excerpt = plain.substring(
                  sel.start.clamp(0, plain.length),
                  sel.end.clamp(0, plain.length),
                );
                onHighlight(start, end, excerpt);
              },
              label: 'Highlight',
            ),
          ],
        );
      },
    );
  }
}