import 'package:flutter/material.dart';

import '../../../themes/themes.dart';
import '../../../utils/debouncer.dart';

/// Search + filter controls for the topic tree (debounced for performance).
class TopicSearchBar extends StatefulWidget {
  const TopicSearchBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    this.onExpandAll,
    this.onCollapseAll,
    this.resultCount,
    this.focusNode,
  });

  final String filter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onExpandAll;
  final VoidCallback? onCollapseAll;
  final int? resultCount;
  final FocusNode? focusNode;

  @override
  State<TopicSearchBar> createState() => TopicSearchBarState();
}

class TopicSearchBarState extends State<TopicSearchBar> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.filter);
  }

  @override
  void didUpdateWidget(TopicSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != _controller.text) {
      _controller.text = widget.filter;
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void focusSearch() => widget.focusNode?.requestFocus();

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;

    return Semantics(
      label: 'Search topics and claims',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            onChanged: (value) =>
                _debouncer.run(() => widget.onFilterChanged(value)),
            decoration: InputDecoration(
              hintText: 'Search topics & claims…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.filter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _controller.clear();
                        widget.onFilterChanged('');
                      },
                    )
                  : null,
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              if (widget.resultCount != null && widget.filter.isNotEmpty)
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      '${widget.resultCount} match${widget.resultCount == 1 ? '' : 'es'}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: sd.accentGold,
                          ),
                    ),
                  ),
                )
              else
                const Spacer(),
              TextButton.icon(
                onPressed: widget.onExpandAll,
                icon: const Icon(Icons.unfold_more, size: 18),
                label: const Text('Expand'),
              ),
              TextButton.icon(
                onPressed: widget.onCollapseAll,
                icon: const Icon(Icons.unfold_less, size: 18),
                label: const Text('Collapse'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}