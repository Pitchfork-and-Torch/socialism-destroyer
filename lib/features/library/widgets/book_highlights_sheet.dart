import 'package:flutter/material.dart';

import '../../../models/book_reading.dart';
import '../../../themes/themes.dart';

class BookHighlightsSheet extends StatelessWidget {
  const BookHighlightsSheet({
    super.key,
    required this.highlights,
    required this.onHighlightTap,
    required this.onDelete,
    required this.onEditNote,
  });

  final List<BookHighlight> highlights;
  final void Function(BookHighlight highlight) onHighlightTap;
  final void Function(BookHighlight highlight) onDelete;
  final void Function(BookHighlight highlight) onEditNote;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Material(
          color: sd.surfaceRaised,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sd.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.highlight, color: sd.accentGold, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Highlights & notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${highlights.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: sd.accentGold,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: highlights.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'Select text and tap Highlight in the menu to mark passages.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: sd.textLow,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: highlights.length,
                        itemBuilder: (context, i) {
                          final h = highlights[i];
                          return SdCard(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            accentColor: sd.accentGold,
                            onTap: () => onHighlightTap(h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (h.note != null && h.note!.isNotEmpty) ...[
                                  Text(
                                    h.note!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                ],
                                Text(
                                  'Offset ${h.start}–${h.end}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: sd.textLow,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => onEditNote(h),
                                      child: const Text('Edit note'),
                                    ),
                                    TextButton(
                                      onPressed: () => onDelete(h),
                                      child: Text(
                                        'Remove',
                                        style: TextStyle(color: sd.accentRed),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}