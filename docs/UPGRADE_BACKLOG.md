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

## Suggested next-cycle pick order

1. Broader Flutter web a11y (contrast ratios, visible focus rings, keyboard-only tree nav)
2. Continue CBO 403 mitigations when rewriting remaining CBO-only cites
3. Phase 8 store screenshots refresh
4. High-intent wave4 if debate topics spike
