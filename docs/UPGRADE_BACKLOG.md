# Upgrade backlog (living)

Items deferred from routine-upgrade cycles. Prefer small ships from this list.

## Cycle 1 deferred (2026-07-28)

| Rank | Item | Notes |
|------|------|-------|
| 1 | Legacy `claims_seed.json` under-sourced claims (~38 with 1 source) | Pre-existing; promote into v2 seeds with second primary when editing |
| 2 | CBO URL 403s under bot UA | Legitimate URLs; freshness script flakes - add alternate gov URLs when rewriting claims |
| 3 | BLS finance IAG 404 (`finance-parasitic`) | Replace with live BLS series URL |
| 4 | Flutter web a11y pass (semantics, contrast, keyboard) | Phase bi-weekly feature slot |
| 5 | Hybrid search precision tuning | Ranking weights + golden queries suite |
| 6 | Debate export: more formats / evidence sidebar polish | UX |
| 7 | Phase 8 store screenshots refresh | DISTRIBUTION / STORE-SUBMISSION |
| 8 | Flutter upgrade when stable channel moves | After analyzing breaking changes |
| 9 | `dart:html` deprecation in binary_download_web | Migrate to package:web |
| 10 | Pre-existing journey test flakes (if any remain after KB bump) | Investigate separately from content |

## Shipped in 3.13.0 (2026-08-01)

- Primary-flow a11y: Topic Tree filters/panel, Crusher live regions, Debate composer/turns
- High-intent wave3 (6 claims): loan pause, public option, DEI, climate reparations, grocery caps, public housing
- More CBO 403 mitigations (non-CBO gov primaries)
- 169 unique claims / 16 bundles

## Shipped in 3.12.0 (2026-08-01)

- All 15 under-sourced winning legacy claims now >=2 sources
- CBO bot-UA 403s: alternate non-CBO primaries on high-traffic claims
- SearchService phrase-precision ranking + golden query suite
- Home a11y Semantics on category chips + high-intent pack

## Shipped in 3.11.0 massive (2026-08-01)

- Hard BLS 404s fixed (finance IAG NAICS 52, youth employment table)
- PD steelman under-sourced claims enriched to >=2 sources
- High-intent packs wired (2026 + wave2) + home debate pack UI
- Crusher phrase/synonym precision pass

## Shipped in 3.14.0 (2026-08-08)

- Battle Brief one-tap steelman-first dossier on claim detail
- High-intent wave4 (8 claims): workweek, PE housing, APR cap, free transit, CEO ratio, public grocery, carbon allowances, rent moratorium
- Crusher phrase boosts + home pack chips for wave4
- Gold focus/hover theme tokens; 177 unique claims / 17 bundles; App 2.3.0

## Shipped in 3.15.0 (2026-08-13)

- Battle Card 1200x630 PNG (steelman-first) on claim detail
- High-intent wave5 (8 claims): PE hospitals, insulin cap, vacancy tax, postal banking, sectoral bargaining, nationalize AI, baby bonds, STR ban
- Crusher phrase boosts + home pack chips for wave5
- 185 unique claims / 18 bundles; App 2.4.0

## Shipped in 3.16.0 (2026-08-18)

- High-intent wave6 (8 claims): unrealized gains, electricity caps, oil windfall tax, AI data-center pause, public power, FTT, abolish inheritance, $25 minimum wage
- Energy & Utilities topic child; Crusher phrase boosts + home pack chips
- CBO 403 mitigations (Treasury / BLS / Census twins) on remaining high-traffic CBO-heavy claims
- CSP allowlist for hits.jonbailey.xyz visitor counter
- 193 unique claims / 19 bundles; App 2.5.0

## Shipped in 3.17.0 (2026-08-28)

- High-intent wave7 Supply Desk (8 claims): LNG export ban, oil/gas lease freeze, private water ban, CAFO ban, freight-rail nationalization, foreign-farmland ban, food-export ban, municipal broadband
- Supply, Trade & Infrastructure topic child; Crusher phrase boosts + home pack chips
- 201 unique claims / 20 bundles; App 2.6.0

## Shipped in app 2.6.1 (2026-09-01)

- Honesty pass only: version constants, README, onboarding, home hub, AEO/llms match the shipped engine
- KB unchanged at 3.17.0 (201 unique claims, 11 topic families)

## Shipped in 3.18.0 (2026-09-05)

- High-intent wave8 Household Capture (8 claims): student-debt cancellation, junk fees, public childcare, private prisons, Congress stock ban, payday ban, medical-debt wipe, buyback ban
- 209 unique claims / 21 bundles; App 2.7.0

## Shipped in 3.18.1 (2026-09-17)

- Engine: ClaimRanker topic-family match; analyzer longest-keyword intent; SearchService FTS re-rank
- Sources: wave8 + related student-debt URLs pointed at FSA portfolio, NCES Fast Facts, CFPB/FTC junk-fee pages, BJS Prisoners 2023, FDIC household survey, CFPB medical collections, SEC vacated buyback rule, BEA profits, Fed Z.1
- Tests: `claim_ranker_test.dart`, analyzer intent, precisionScore, wave8 crusher/knowledge asserts
- Mobile X-follow chip CSS (left on narrow viewports)
- CUT: CF Pages + GitHub latest-only; App 2.7.0 / KB 3.18.1; OG ?v=3.18.1

## Shipped in 3.19.0 (2026-09-21)

- High-intent wave9 Planning Desk (8 claims): social wealth fund, federal job guarantee, spend-first deficits, tariff wall, national investment bank, codetermination, Vienna social housing, capital controls for a wealth tax
- Hearing Brief on the crusher export bar (ranked multi-claim steelman copy)
- 217 unique claims / 22 bundles; App 2.8.0; OG ?v=3.19.0

## Suggested next-cycle pick order

1. Broader Flutter web a11y (contrast ratios, keyboard-only tree nav beyond focus tokens)
2. Promote remaining Wikipedia-bearing cultural-subversion claims with archive/primary twins
3. CBO bot-UA 403s: keep human URLs; twins already present (do not treat 403 as dead)
4. Phase 8 store screenshots refresh
5. `dart:html` to `package:web` in binary_download_web
6. Battle Card attach-to-X compose helper (desktop tweet-ready pack)
