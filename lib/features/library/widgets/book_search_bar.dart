import 'package:flutter/material.dart';

import '../../../models/book_reading.dart';
import '../../../themes/themes.dart';

class BookSearchBar extends StatelessWidget {
  const BookSearchBar({
    super.key,
    required this.controller,
    required this.onQueryChanged,
    required this.matches,
    required this.activeMatchIndex,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final List<BookSearchMatch> matches;
  final int activeMatchIndex;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final hasMatches = matches.isNotEmpty;

    return Material(
      color: sd.surfaceRaised,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search in book…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.card,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                controller: controller,
                onChanged: onQueryChanged,
              ),
            ),
            if (controller.text.length >= 2) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                hasMatches
                    ? '${activeMatchIndex + 1}/${matches.length}'
                    : '0',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: hasMatches ? sd.accentGold : sd.textLow,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: 'Previous match',
                onPressed: hasMatches ? onPrevious : null,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: 'Next match',
                onPressed: hasMatches ? onNext : null,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close search',
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}