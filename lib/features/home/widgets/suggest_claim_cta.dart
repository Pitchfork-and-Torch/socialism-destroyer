import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../themes/themes.dart';
import '../../shared/router/app_router.dart';

/// Prompts engaged users to contribute moderated claim ideas.
class SuggestClaimCta extends StatelessWidget {
  const SuggestClaimCta({super.key});

  @override
  Widget build(BuildContext context) {
    return SdCard(
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: context.sd.accentGold, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help us grow the arsenal',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Spot a missing socialist claim? Submit sources for curator review.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(AppRoutes.suggestClaim),
            child: const Text('Suggest'),
          ),
        ],
      ),
    );
  }
}