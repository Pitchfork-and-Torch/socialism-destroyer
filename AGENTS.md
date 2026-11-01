# AGENTS.md - Socialism Destroyer

Standing rules for **any** AI agent or human operator working in this repository.

Live site: https://destroyer.jonbailey.xyz/  
GitHub: https://github.com/Pitchfork-and-Torch/socialism-destroyer (MIT)  
Creator: Jon Bailey / Pitchfork-and-Torch

---

## Non-negotiable design principles

1. **Truth-first** - Prefer primary government sources (Census, BLS, BEA, CBO, Fed, World Bank, GAO, etc.), peer-reviewed research, historical archives, and public-domain classics.
2. **Steelman first** - State the strongest socialist/collectivist claim before the rebuttal. Never strawman.
3. **No ideology theater** - No ad hominem, no slogans without evidence, no culture-war performance.
4. **No accounts / paywalls / tracking** on the free product surface. Offline-first; CDN is optional delta only.
5. **Free forever** - Do not introduce monetization gates on core argument tools.
6. **Every new claim needs ≥2 primary/government/academic sources** with working URLs.
7. **Preserve visual language** - Navy/gold theme and existing typography; no random redesigns.

If a change conflicts with these principles, **stop and redesign**.

---

## Routine upgrade loop (default maintenance path)

When asked to improve, update, refresh, or "run a cycle" on this project:

1. Read `docs/UPGRADE_LOOP.md` (authoritative playbook).
2. Load skill **routine-upgrade** / **socialism-destroyer-upgrade** if available.
3. Execute Phases 0 - 7 (orient → audit → prioritize → implement → validate → document → publish notes → close).
4. Prefer small, reviewable diffs over rewrites.

Cadence target: **weekly or bi-weekly**. Triggers: data releases, high-intent claims, user suggestions, Flutter bumps, live/git KB skew.

---

## Repository map (critical paths)

| Path | Role |
|------|------|
| `assets/data/v2/knowledge_manifest.json` | KB version + claim bundle list |
| `assets/data/v2/seeds/*.json` | Curated claim bundles |
| `assets/data/claims_seed.json` | Legacy baseline claims |
| `assets/data/changelog.json` | User-visible KB changelog (must update on content) |
| `assets/data/v2/topics.json` | Topic tree |
| `assets/data/v2/books.json` | Library catalog |
| `assets/data/books/` | Bundled public-domain full texts |
| `lib/` | Flutter app (Riverpod, go_router, Hive) |
| `web/` | Web shell, SEO/AEO, PWA, projects panel |
| `tools/publish-web.ps1` | Production Cloudflare Pages deploy |
| `tools/check_citation_freshness.mjs` | Source URL health |
| `tools/prepublish_checklist.ps1` | Pre-ship gate |
| `tools/bump_kb_manifest.mjs` | Manifest hash / version helper |
| `docs/UPGRADE_LOOP.md` | This loop's playbook |
| `docs/ADDING-CLAIMS.md` | Claim authoring |

**Orphan seed rule:** Every file under `assets/data/v2/seeds/` that is meant to ship **must** appear in `knowledge_manifest.json` `claimBundles`. Live and git must not diverge on this without an intentional ship plan.

---

## Claim schema (do not invent fields)

Match existing seeds. Minimum fields:

- `id`, `topicId`, `topicPath`, `title`
- `socialistClaimText` - steelman (strongest opposing formulation)
- `executiveSummary`, `evidenceBullets[]`, `fallacies[]`
- `sources[]` - each with `id`, `title`, `url`, `type`, `accessedAt`, `citation` (≥2)
- `whyItMatters`, `relatedClaimIds[]`, `tags[]`
- `schemaVersion` (2), `revision`, `updatedAt`, `embeddingText`, `searchText`, `kbVersion`

Optional: `relatedBookIds`, `claimQuote`, `quoteAttribution`, `chartData`.

---

## Versioning

| Surface | File / field | When to bump |
|---------|--------------|--------------|
| App | `pubspec.yaml` `version` | Code/UI release |
| Knowledge | `knowledge_manifest.json` `kbVersion` | Any claim/topic/book content ship |
| Changelog | `changelog.json` `currentVersion` + new entry | Same as KB content ships |
| Per-claim | `revision` | Edits to an existing claim |

App and KB versions are **independent** (e.g. App 2.1.1 + KB 3.10.0 is normal).

After content edits always:

1. Bump KB version fields
2. Recompute content hashes (`node tools/bump_kb_manifest.mjs`)
3. Update `changelog.json`
4. Align `web/index.html` / `llms.txt` counts if user-visible

---

## Validation gate (before "done")

```powershell
$flutter = "C:\flutter\bin\flutter.bat"  # or PATH flutter
& $flutter analyze --no-fatal-infos --no-fatal-warnings
& $flutter test --reporter compact --concurrency=1
node tools/check_citation_freshness.mjs --limit 30
```

Do not claim completion if analyze has **errors** or new claims fail the source bar.

---

## Web / UTF-8 hygiene

- Write `web/index.html`, meta, and JSON as **UTF-8 without BOM**.
- Prefer ASCII punctuation in ops scripts; keep proper Unicode (em dash, ·, ö) only when intentional and correctly encoded.
- After editing HTML, search for mojibake patterns (`â€`, `Ã¶`) and fix before publish.
- Cache-bust bootstrap when needed: `flutter_bootstrap.js?v=N`.

---

## Deploy

```powershell
.\tools\publish-web.ps1
```

Verify:

1. https://destroyer.jonbailey.xyz/version.json
2. https://destroyer.jonbailey.xyz/assets/assets/data/v2/knowledge_manifest.json
3. Spot-check a new claim in Topic Tree / Crusher
4. Confirm no infinite "Loading..." (missing assets return SPA HTML 200 - check Network carefully)

---

## GitHub / license

- Public product: **MIT**, Pitchfork-and-Torch account for product work.
- Secret-scan before commit/push (machine standing practice).
- Never commit `.env` secrets, PATs, or API keys. Use `.env.web.publish` for public web builds.
- Prefer incremental commits with conventional prefixes: `feat:`, `content:`, `fix:`, `docs:`, `chore:`.

---

## Explicitly out of scope

- Weakening steelman or source requirements
- Adding analytics, ads, or forced accounts
- Mass-rewriting the library or claim corpus without reviewable batches
- Relicensing away from MIT for the public product
- Shipping claims with only one weak secondary source

---

## Quick start for a new session

```text
1. Read AGENTS.md + docs/UPGRADE_LOOP.md
2. Compare local KB vs live knowledge_manifest
3. Run citation freshness sample
4. Rank 5 - 10 backlog items; implement top few
5. Validate; changelog; publish notes
```

For the full automated path: invoke skill **routine-upgrade** / say **"run routine-upgrade"**.
