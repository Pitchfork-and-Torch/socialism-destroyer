import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/debate_session.dart';
import '../../../models/library_passage.dart';
import '../../../themes/themes.dart';
import '../../shared/router/app_router.dart';
import '../providers/debate_providers.dart';

/// Live evidence index: sources, claims, and library passage RAG hits.
class DebateEvidenceSidebar extends ConsumerWidget {
  const DebateEvidenceSidebar({
    super.key,
    required this.session,
    this.compact = false,
  });

  final DebateSession session;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sd = context.sd;
    final theme = Theme.of(context);
    final sources = session.allSources;
    final claimIds = session.allMatchedClaimIds;
    final avg = session.averageUserScore;
    final passagesAsync = ref.watch(debatePassagesProvider);

    return SdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance_rounded, color: sd.accentGold, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Evidence Sidebar',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: sd.accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            session.mode == DebateMode.challenge
                ? 'Challenge · sourced coaching + library RAG'
                : 'Spar · live counter-evidence + library RAG',
            style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
          ),
          if (session.llmAssisted) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Optional AI polish used on some turns — facts stay curated.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: sd.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (avg != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Avg score: ${avg.round()}/100',
              style: theme.textTheme.labelLarge?.copyWith(color: sd.accentGold),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Matched claims', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          if (claimIds.isEmpty)
            Text(
              'Claims appear after the first engine reply.',
              style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: claimIds.take(compact ? 6 : 12).map((id) {
                return ActionChip(
                  label: Text(id, style: theme.textTheme.labelSmall),
                  onPressed: () => context.push('/claim/$id'),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          const SizedBox(height: AppSpacing.md),
          Text('Library passages (offline RAG)', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          passagesAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Scanning library…',
                style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
              ),
            ),
            error: (_, _) => Text(
              'Passage search unavailable.',
              style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
            ),
            data: (passages) {
              if (passages.isEmpty) {
                return Text(
                  'Passages appear once the debate has topical text.',
                  style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
                );
              }
              return Column(
                children: passages
                    .take(compact ? 3 : 6)
                    .map((p) => _PassageTile(passage: p))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Sources in play', style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          if (sources.isEmpty)
            Text(
              'Sources accumulate from engine turns.',
              style: theme.textTheme.bodySmall?.copyWith(color: sd.textLow),
            )
          else
            ...sources.take(compact ? 5 : 10).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SourceCitation(source: s),
              ),
            ),
          if (session.seedClaimId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => context.push('/claim/${session.seedClaimId}'),
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: const Text('Open seed claim'),
            ),
          ],
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.library),
            icon: const Icon(Icons.local_library_outlined, size: 18),
            label: const Text('Browse library'),
          ),
        ],
      ),
    );
  }
}

class _PassageTile extends StatelessWidget {
  const _PassageTile({required this.passage});

  final LibraryPassageHit passage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sd = context.sd;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          AppRoutes.navigateToLibraryReader(
            context,
            bookId: passage.bookId,
            chapterId: passage.chapterId,
            claimId: passage.claimId,
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: sd.borderSubtle),
            borderRadius: BorderRadius.circular(8),
            color: sd.surfaceOverlay.withValues(alpha: 0.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passage.bookTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: sd.accentGold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                passage.author +
                    (passage.chapterTitle != null
                        ? ' · ${passage.chapterTitle}'
                        : ''),
                style: theme.textTheme.labelSmall?.copyWith(color: sd.textLow),
              ),
              const SizedBox(height: 4),
              Text(
                passage.snippet,
                style: theme.textTheme.bodySmall,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (passage.reason != null) ...[
                const SizedBox(height: 4),
                Text(
                  passage.reason!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: sd.textMedium,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
