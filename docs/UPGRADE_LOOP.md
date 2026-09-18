# Upgrade & Enhancement Loop

**Socialism Destroyer - Liberty Argument Engine**  
Durable playbook for weekly/bi-weekly improvement cycles.  
Companion skill: `.grok/skills/routine-upgrade/SKILL.md` (also `socialism-destroyer-upgrade` in agent skills).  
Project rules: `AGENTS.md`.

---

## Purpose

Keep the product **truth-first, steelman-first, offline-first, and free forever** while routinely:

1. Refreshing citations and government data
2. Expanding high-intent claims with ≥2 primary sources each
3. Improving retrieval, UX, performance, and accessibility
4. Advancing tests, docs, and Phase 8 distribution readiness
5. Shipping reviewable diffs that never weaken design principles

---

## Cadence & Triggers

| Cadence | What to run |
|---------|-------------|
| **Weekly (default)** | Full loop Phases 0 - 7 (content + light UX) |
| **Bi-weekly** | Same + deeper feature/perf/a11y item |
| **Monthly** | Full loop + citation freshness deep pass + Flutter upgrade check + store prep skim |

**Run immediately when:**

- BLS / Census / BEA / CBO / Fed / World Bank release major series used in claims
- High-intent public debate spikes (rent control, wealth tax, Nordic model, AI planning, China, greeflation/degrowth, industrial policy)
- User suggestions accumulate via in-app Suggest / GitHub Issues
- Flutter SDK major/minor bump or security-sensitive dependency advisory
- Live site health fails (`version.json`, loading hang, KB manifest 404)
- Live KB version **diverges** from git `knowledge_manifest.json` (must reconcile same cycle)

---

## Impact × Effort prioritization

Score each backlog item **1 - 5** on each axis; ship highest **impact/effort** first within philosophy rails.

| Weight | Axis | Prefer |
|--------|------|--------|
| **5** | Philosophy alignment | Stronger steelman, more primary sources, offline-first, no tracking |
| **4** | High-intent topics | Rent control, Nordic, wealth tax, AI/calculation, China state capitalism, greeflation, degrowth, industrial policy, housing supply |
| **3** | Retrieval / Crusher / Debate quality | Hybrid search precision, evidence sidebar, export fidelity |
| **2** | UX / a11y / web perf | Semantic labels, contrast, keyboard, LCP, PWA polish |
| **1** | Phase 8 distribution | Store assets, screenshots, verify scripts (never block truth work) |

**Reject or redesign** if the item:

- Adds accounts, paywalls, telemetry, or third-party tracking
- Bloates the offline bundle without clear debate value
- Softens steelman quality or drops below ≥2 primary/government sources
- Is a large rewrite when a small seed/schema fix would do

---

## Multi-phase cycle

### Phase 0 - Orient (5 - 10 min)

```powershell
cd $env:USERPROFILE\socialism-destroyer   # or your clone root
git status -sb
git log -5 --oneline
# Versions
Select-String -Path pubspec.yaml -Pattern '^version:'
(Get-Content assets\data\v2\knowledge_manifest.json -Raw | ConvertFrom-Json).kbVersion
(Get-Content assets\data\changelog.json -Raw | ConvertFrom-Json).currentVersion
# Live health
Invoke-WebRequest https://destroyer.jonbailey.xyz/version.json -UseBasicParsing
Invoke-WebRequest https://destroyer.jonbailey.xyz/assets/assets/data/v2/knowledge_manifest.json -UseBasicParsing
```

**Success criteria:** Local vs live versions recorded; dirty tree understood; no surprise secrets staged.

---

### Phase 1 - Audit

Checklist:

- [ ] Live home HTTP 200; `version.json` matches intended app version
- [ ] Live `knowledge_manifest.json` `kbVersion` matches or is intentionally ahead of git (reconcile)
- [ ] Every `claimBundles[].asset` file exists and is listed (no orphan seed files)
- [ ] `node tools/check_citation_freshness.mjs --limit 40` (or full sample)
- [ ] Skim recent GitHub Issues / local suggestion themes
- [ ] Note Flutter analyze debt, web perf, a11y, mobile polish pain points
- [ ] Confirm design principles still hold on last ship

Optional:

```powershell
node tools/check_citation_freshness.mjs --json > tools/reports/citation-freshness.json
.\tools\prepublish_checklist.ps1 -SkipBuild   # when available
```

**Success criteria:** Written audit notes (5 - 15 bullets) + known gaps list.

---

### Phase 2 - Prioritize

Produce a **ranked backlog of 5 - 10 items**. Prefer small, reviewable changes.

Template:

| Rank | Item | Type | Impact | Effort | Cycle? |
|------|------|------|--------|--------|--------|
| 1 | ... | content/fix/feat/docs | H/M/L | S/M/L | Y/N |

**Success criteria:** Top 1 - 4 items selected for this cycle; rest deferred to `docs/UPGRADE_BACKLOG.md` or next-cycle prompt.

---

### Phase 3 - Implement

#### Content (claims)

1. Follow `docs/ADDING-CLAIMS.md` and exact seed schema (`socialistClaimText` steelman first).
2. New claims: **≥2** government/primary/academic sources with live URLs.
3. Prefer new bundle `assets/data/v2/seeds/<name>.json` or append to topic bundle.
4. Wire bundle in `assets/data/v2/knowledge_manifest.json`.
5. Bump `kbVersion` (semver), `updatedAt`, recompute hashes:

```powershell
node tools/bump_kb_manifest.mjs
# or full checklist:
.\tools\prepublish_checklist.ps1 -SkipBuild
```

6. Update `assets/data/changelog.json` (`currentVersion`, new entry first).
7. If user-facing counts change: `web/index.html` meta + `web/llms.txt` (UTF-8 **without BOM**, no mojibake).

#### Product / code

- Match existing Riverpod / go_router / Hive patterns
- No new tracking SDKs
- Keep navy/gold visual language
- Prefer incremental diffs

#### Tooling

- Extend `tools/check_citation_freshness.mjs`, seed helpers, verify scripts as needed
- Keep scripts PowerShell/Node/Python consistent with repo

**Success criteria:** Diff is reviewable; philosophy rails intact; every new claim has steelman + ≥2 sources.

---

### Phase 4 - Validate

```powershell
$flutter = "C:\flutter\bin\flutter.bat"   # adjust if needed
& $flutter pub get
& $flutter analyze --no-fatal-infos --no-fatal-warnings
& $flutter test --reporter compact --concurrency=1
node tools/check_citation_freshness.mjs --limit 30
# Optional deeper:
.\tools\verify.ps1
```

Manual / smoke:

- [ ] Topic Tree loads new claims
- [ ] Argument Crusher retrieves a new claim by distinctive phrase
- [ ] Claim detail shows sources (≥2) and steelman text first
- [ ] Debate Simulator still opens Evidence sidebar
- [ ] No accounts/paywalls/tracking introduced

**Success criteria:** Analyze clean of errors; tests green (or documented pre-existing failures only); content QA checklist checked.

---

### Phase 5 - Document

- [ ] `assets/data/changelog.json` updated
- [ ] Manifest `kbVersion` / `contentHash` / bundles aligned
- [ ] `docs/UPGRADE_LOOP.md` lessons only if process changed
- [ ] ADR only for architectural decisions
- [ ] `web/llms.txt` / meta if surface counts or features changed
- [ ] Next-cycle prompt snippet saved (see bottom of this doc / skill)

Conventional commit prefixes: `feat:`, `content:`, `fix:`, `docs:`, `chore:`.

---

### Phase 6 - Publish (web)

```powershell
# Pitchfork-and-Torch only for product GitHub
gh auth switch --user Pitchfork-and-Torch

# Secret scan before any commit/push
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.grok\scripts\scan-secrets-before-commit.ps1 -Path $PWD

# Deploy Cloudflare Pages (build + knowledge CDN folder + wrangler)
.\tools\publish-web.ps1
# Build only:
.\tools\publish-web.ps1 -BuildOnly
```

Public GitHub hygiene (product repo): single-commit main history policy, MIT license, author Pitchfork-and-Torch - see machine `STANDING-GITHUB-PRACTICE.md` / skill `public-github-hygiene`.

After live ship:

1. Probe `https://destroyer.jonbailey.xyz/version.json` and knowledge manifest
2. Update `~\.grok\LIVE-SITES.md` + `live-sites-registry.json`
3. Continuity note if operator expects it:

```powershell
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.grok\scripts\Sync-KnockContinuity.ps1 -Note "destroyer KB x.y.z ship"
```

**Success criteria:** Live version + KB match ship intent; no Loading... hang from missing assets.

---

### Phase 7 - Close cycle

- [ ] Record what shipped vs deferred
- [ ] Paste **Next-cycle prompt** for the following session
- [ ] Leave working tree intentional (committed or clearly noted dirty files)

---

## Commands cheatsheet

| Task | Command |
|------|---------|
| Analyze | `flutter analyze --no-fatal-infos --no-fatal-warnings` |
| Test | `flutter test --reporter compact --concurrency=1` |
| Citation freshness | `node tools/check_citation_freshness.mjs` |
| Pre-publish | `.\tools\prepublish_checklist.ps1` |
| Bump manifest hash | `node tools/bump_kb_manifest.mjs` |
| Sitemap | `node tools/generate-sitemap.mjs` |
| Publish web | `.\tools\publish-web.ps1` |
| Knowledge CDN only | `.\tools\publish_knowledge.ps1 -CdnRoot <path> -KbVersion x.y.z` |
| Full verify | `.\tools\verify.ps1` |

---

## Content quality bar (non-negotiable)

1. **Steelman first** - `socialistClaimText` is the strongest opposing formulation.
2. **≥2 sources** - government, academic (DOI preferred), or primary historical; live URLs.
3. **Evidence over ideology theater** - incentives, calculation, historical outcomes, data.
4. **No ad hominem**.
5. **Offline-first** - full KB bundled; CDN is optional delta only.
6. **Free forever** - no accounts, paywalls, or tracking.

---

## High-intent topic queue (refresh often)

Rent control / housing supply · Nordic model · Wealth tax · AI + calculation problem · China state capitalism · Greedflation / price controls · Degrowth · Industrial policy · Student debt · Single-payer cost · Worker co-ops · Soft despotism / welfare state · Cultural subversion claims · Public-domain steelmans (Veblen, Sinclair, Luxemburg, Lenin, Wells)

---

## Next-cycle prompt template

Copy, fill brackets, paste into a new Grok Build session:

```text
Run the Socialism Destroyer routine-upgrade cycle.

Project: ~/socialism-destroyer · live https://destroyer.jonbailey.xyz/
Follow: docs/UPGRADE_LOOP.md + AGENTS.md + skill routine-upgrade / socialism-destroyer-upgrade

Last cycle: [DATE]
Shipped: App [X.Y.Z] · KB [A.B.C]
Deferred backlog:
- [item]
- [item]

Lessons:
- [e.g. always wire seed files into knowledge_manifest; UTF-8 no BOM for web/index.html]

This cycle priorities:
1. [from backlog or new]
2. ...
3. ...

Execute Phases 0 - 7. Prefer small reviewable diffs. Do not weaken steelman/source/offline rails.
End with: validate results, changelog, next-cycle prompt, publish notes.
```

---

## Related docs

- [ADDING-CLAIMS.md](ADDING-CLAIMS.md)
- [content-pipeline.md](content-pipeline.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [TESTING.md](TESTING.md)
- [DISTRIBUTION.md](DISTRIBUTION.md) / [STORE-SUBMISSION.md](STORE-SUBMISSION.md) (Phase 8)
- [BUILD.md](BUILD.md)
