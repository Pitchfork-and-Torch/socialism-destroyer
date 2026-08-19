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

## Suggested next-cycle pick order

1. Broader Flutter web a11y (contrast ratios, keyboard-only tree nav beyond focus tokens)
2. Promote remaining one-source legacy claims in small batches
3. Phase 8 store screenshots refresh
4. `dart:html` to `package:web` in binary_download_web
5. Battle Card attach-to-X compose helper (desktop tweet-ready pack)
