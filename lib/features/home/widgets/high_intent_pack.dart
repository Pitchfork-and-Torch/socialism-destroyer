import 'package:flutter/material.dart';

import '../../../themes/themes.dart';

/// A crush-ready high-intent argument starter for the home hub.
class HighIntentStarter {
  const HighIntentStarter({
    required this.id,
    required this.label,
    required this.query,
    required this.claimId,
  });

  final String id;
  final String label;
  final String query;
  final String claimId;
}

/// Curated 2026 high-intent openers - steelman phrases for Argument Crusher.
const highIntentStarters = <HighIntentStarter>[
  HighIntentStarter(
    id: 'm4a',
    label: 'Medicare for All',
    query: 'Medicare for All pays for itself and ends insurance waste',
    claimId: 'medicare-for-all-pays-for-itself',
  ),
  HighIntentStarter(
    id: 'rent-freeze',
    label: 'Rent freeze',
    query: 'Citywide rent freezes solve the housing crisis',
    claimId: 'rent-freeze-solves-city-housing',
  ),
  HighIntentStarter(
    id: 'wealth-tax',
    label: 'Wealth tax',
    query: 'European wealth taxes prove we can tax the rich fairly',
    claimId: 'wealth-tax-europe-proves-it-works',
  ),
  HighIntentStarter(
    id: 'gnd',
    label: 'Green jobs',
    query: 'A green jobs guarantee ends unemployment and climate risk',
    claimId: 'green-new-deal-jobs-guarantee',
  ),
  HighIntentStarter(
    id: 'gig',
    label: 'Gig economy',
    query: 'The gig economy is pure exploitation of workers',
    claimId: 'gig-economy-is-exploitation',
  ),
  HighIntentStarter(
    id: 'buybacks',
    label: 'Buybacks',
    query: 'Stock buybacks are theft from workers',
    claimId: 'stock-buybacks-are-theft',
  ),
  HighIntentStarter(
    id: 'big-tech',
    label: 'Big Tech',
    query: 'Break up Big Tech to save democracy',
    claimId: 'break-up-big-tech-for-democracy',
  ),
  HighIntentStarter(
    id: 'college',
    label: 'Free college',
    query: 'College must be free for everyone as a basic right',
    claimId: 'free-college-is-a-right',
  ),
  HighIntentStarter(
    id: 'late-stage',
    label: 'Late-stage',
    query: 'We are in late-stage capitalism collapse',
    claimId: 'late-stage-capitalism-is-collapsing',
  ),
  HighIntentStarter(
    id: 'industrial',
    label: 'Industrial policy',
    query: 'Industrial policy beats free markets for national strength',
    claimId: 'industrial-policy-beats-markets',
  ),
  HighIntentStarter(
    id: 'loan-pause',
    label: 'Loan pause',
    query: 'Permanent student loan pause is economic justice',
    claimId: 'student-loan-pause-is-justice',
  ),
  HighIntentStarter(
    id: 'dei',
    label: 'DEI mandates',
    query: 'DEI mandates are required for justice in hiring',
    claimId: 'dei-mandates-are-justice',
  ),
  HighIntentStarter(
    id: 'grocery-caps',
    label: 'Grocery caps',
    query: 'Grocery price controls will stop greedflation',
    claimId: 'grocery-price-controls-now',
  ),
];

/// Horizontal pack of high-intent debate openers under the crush bar.
class HighIntentPack extends StatelessWidget {
  const HighIntentPack({
    super.key,
    required this.onCrush,
    this.onOpenClaim,
  });

  final void Function(String query) onCrush;
  final void Function(String claimId)? onOpenClaim;

  @override
  Widget build(BuildContext context) {
    final sd = context.sd;
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'High-intent debate pack. Tap a slogan to open Argument Crusher.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 18, color: sd.accentGold),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'High-intent debate pack',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: sd.accentGold,
                  ),
                ),
              ),
              Text(
                '160+ claims',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap a live slogan to crush it with steelman-first, sourced rebuttals.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: highIntentStarters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final item = highIntentStarters[index];
                return Semantics(
                  button: true,
                  label: 'Crush argument: ${item.label}',
                  child: Tooltip(
                    message: onOpenClaim == null
                        ? item.query
                        : '${item.query}\nLong-press for full claim',
                    child: GestureDetector(
                      onLongPress: onOpenClaim == null
                          ? null
                          : () => onOpenClaim!(item.claimId),
                      child: ActionChip(
                        avatar: Icon(
                          Icons.gavel_rounded,
                          size: 16,
                          color: sd.accentGold,
                        ),
                        label: Text(item.label),
                        onPressed: () => onCrush(item.query),
                        side: BorderSide(
                          color: sd.accentGold.withValues(alpha: 0.45),
                        ),
                        backgroundColor: sd.accentGold.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
