import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../providers/claim_suggestion_providers.dart';
import '../../../themes/themes.dart';
import '../../shared/router/app_router.dart';
import 'suggestion_status_chip.dart';

class MySuggestionsPanel extends ConsumerWidget {
  const MySuggestionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(myClaimSuggestionsProvider);

    return suggestionsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return SdCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your suggestions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No submissions yet on this device. Propose a steelmanned claim '
                  'with sourced counters — no account required.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.suggestClaim),
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Suggest New Claim'),
                ),
              ],
            ),
          );
        }

        final dateFmt = DateFormat.yMMMd();
        return SdCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your suggestions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.suggestClaim),
                    child: const Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...items.take(5).map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          s.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${dateFmt.format(s.createdAt.toLocal())} · ${s.topicId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: SuggestionStatusChip(status: s.status),
                      ),
                    ),
                  ),
              if (items.length > 5)
                Text(
                  '+ ${items.length - 5} more',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        );
      },
      loading: () => const SdCard(
        child: SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}