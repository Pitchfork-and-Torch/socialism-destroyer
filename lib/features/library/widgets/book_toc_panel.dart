import 'package:flutter/material.dart';

import '../../../models/book.dart';
import '../../../themes/themes.dart';

class BookTocPanel extends StatelessWidget {
  const BookTocPanel({
    super.key,
    required this.chapters,
    required this.activeChapterId,
    required this.onChapterTap,
    this.progressFraction = 0,
  });

  final List<BookChapter> chapters;
  final String? activeChapterId;
  final void Function(BookChapter chapter) onChapterTap;
  final double progressFraction;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return Material(
      color: sd.surfaceRaised,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Contents',
              style: theme.textTheme.titleMedium?.copyWith(
                color: sd.accentGold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...chapters.map((chapter) {
            final isActive = chapter.id == activeChapterId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: ListTile(
                dense: true,
                selected: isActive,
                selectedTileColor: sd.accentGold.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
                leading: Icon(
                  isActive ? Icons.menu_book : Icons.article_outlined,
                  size: 20,
                  color: isActive ? sd.accentGold : sd.textLow,
                ),
                title: Text(
                  chapter.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? sd.textHigh : sd.textMedium,
                  ),
                ),
                onTap: () => onChapterTap(chapter),
              ),
            );
          }),
          if (progressFraction > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: ReadingProgressMini(fraction: progressFraction),
            ),
          ],
        ],
      ),
    );
  }
}

class ReadingProgressMini extends StatelessWidget {
  const ReadingProgressMini({super.key, required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your progress',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: sd.textLow,
              ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 4,
            backgroundColor: sd.borderSubtle,
            color: sd.accentGold,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${(fraction.clamp(0, 1) * 100).round()}% complete',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: sd.accentGold,
              ),
        ),
      ],
    );
  }
}