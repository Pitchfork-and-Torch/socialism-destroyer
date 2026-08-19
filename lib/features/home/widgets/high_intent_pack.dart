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
    id: 'unrealized-gains',
    label: 'Tax paper gains',
    query: 'Tax unrealized capital gains every year so billionaires cannot hoard paper wealth',
    claimId: 'tax-unrealized-gains-is-justice',
  ),
  HighIntentStarter(
    id: 'electricity-cap',
    label: 'Cap electricity',
    query: 'Cap electricity prices now utilities are gouging households',
    claimId: 'cap-electricity-prices-now',
  ),
  HighIntentStarter(
    id: 'windfall-oil',
    label: 'Oil windfall tax',
    query: 'Windfall profits tax on oil super-profits to fund rebates',
    claimId: 'windfall-profits-tax-oil',
  ),
  HighIntentStarter(
    id: 'data-centers',
    label: 'Pause data centers',
    query: 'Pause and tax AI data centers they steal power and water',
    claimId: 'tax-pause-ai-data-centers',
  ),
  HighIntentStarter(
    id: 'public-power',
    label: 'Public power',
    query: 'Municipalize the grid public power is cheaper and greener',
    claimId: 'public-power-is-justice',
  ),
  HighIntentStarter(
    id: 'ftt',
    label: 'Tax every trade',
    query: 'A tiny tax on every trade will fund care and stop speculation',
    claimId: 'financial-transaction-tax-justice',
  ),
  HighIntentStarter(
    id: 'estate-wipe',
    label: 'Abolish inheritance',
    query: 'Abolish inherited wealth with a 100 percent estate tax',
    claimId: 'abolish-inherited-wealth',
  ),
  HighIntentStarter(
    id: 'wage-25',
    label: r'$25 wage',
    query: 'A 25 dollar federal minimum wage is the living wage and will not cost jobs',
    claimId: 'twenty-five-dollar-minimum-wage',
  ),
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
  HighIntentStarter(
    id: 'four-day',
    label: '4-day week',
    query: 'Mandate a four-day workweek at full pay for justice',
    claimId: 'four-day-workweek-mandate',
  ),
  HighIntentStarter(
    id: 'pe-housing',
    label: 'Ban PE housing',
    query: 'Ban private equity from residential housing',
    claimId: 'ban-private-equity-housing',
  ),
  HighIntentStarter(
    id: 'cc-cap',
    label: 'Card APR cap',
    query: 'Cap credit card interest rates at 10 percent',
    claimId: 'cap-credit-card-interest',
  ),
  HighIntentStarter(
    id: 'free-transit',
    label: 'Free transit',
    query: 'Free public transit is a human right',
    claimId: 'free-public-transit-right',
  ),
  HighIntentStarter(
    id: 'ceo-cap',
    label: 'CEO pay cap',
    query: 'Cap CEO pay at 50 times median worker pay',
    claimId: 'executive-pay-ratio-cap',
  ),
  HighIntentStarter(
    id: 'public-grocery',
    label: 'Public grocery',
    query: 'State-owned grocery stores will end food deserts',
    claimId: 'state-owned-grocery-stores',
  ),
  HighIntentStarter(
    id: 'carbon-allowance',
    label: 'Carbon rations',
    query: 'Personal carbon allowances are climate justice',
    claimId: 'personal-carbon-allowances',
  ),
  HighIntentStarter(
    id: 'rent-moratorium',
    label: 'Rent moratorium',
    query: 'Nationwide rent moratorium is emergency justice',
    claimId: 'nationwide-rent-moratorium',
  ),
  HighIntentStarter(
    id: 'pe-hospitals',
    label: 'Ban PE hospitals',
    query: 'Ban private equity from owning hospitals',
    claimId: 'ban-pe-from-hospitals',
  ),
  HighIntentStarter(
    id: 'insulin-cap',
    label: 'Insulin cap',
    query: 'Nationwide insulin price caps are justice',
    claimId: 'insulin-price-cap-is-justice',
  ),
  HighIntentStarter(
    id: 'vacancy-tax',
    label: 'Vacancy tax',
    query: 'Tax empty homes until they fill',
    claimId: 'vacancy-tax-fills-homes',
  ),
  HighIntentStarter(
    id: 'postal-bank',
    label: 'Postal banking',
    query: 'Postal banking is financial justice',
    claimId: 'postal-banking-is-justice',
  ),
  HighIntentStarter(
    id: 'sectoral',
    label: 'Sectoral bargaining',
    query: 'Sectoral bargaining is economic democracy',
    claimId: 'sectoral-bargaining-is-democracy',
  ),
  HighIntentStarter(
    id: 'ai-utility',
    label: 'Nationalize AI',
    query: 'Nationalize AI compute as a public utility',
    claimId: 'nationalize-ai-compute',
  ),
  HighIntentStarter(
    id: 'baby-bonds',
    label: 'Baby bonds',
    query: 'Baby bonds will close the wealth gap',
    claimId: 'baby-bonds-close-the-gap',
  ),
  HighIntentStarter(
    id: 'ban-str',
    label: 'Ban Airbnbs',
    query: 'Ban short-term rentals for housing justice',
    claimId: 'ban-short-term-rentals',
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
                '193 claims',
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
