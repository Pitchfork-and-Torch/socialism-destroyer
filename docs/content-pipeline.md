# Content Pipeline — Curated Knowledge Updates

This document describes how to author, version, publish, and sync the Socialism Destroyer knowledge base without shipping a full app update.

## Overview

```
┌─────────────┐    hash & bundle    ┌──────────────┐    CDN / Storage    ┌─────────────┐
│ Edit seeds  │ ──────────────────► │ Publish tool │ ──────────────────► │ Remote CDN  │
│ topics.json │                     │ (tools/)     │                     │ manifest +  │
│ books.json  │                     └──────────────┘                     │ deltas      │
└─────────────┘                                                          └──────┬──────┘
                                                                                │
                     ┌──────────────────────────────────────────────────────────┘
                     ▼
              ┌──────────────┐    overlay merge    ┌──────────────────┐
              │ Flutter app  │ ◄────────────────── │ KnowledgeService │
              │ (bundled v2) │                     │ + FTS reindex    │
              └──────────────┘                     └──────────────────┘
```

The app always ships a **bundled baseline** (`assets/data/v2/`). When `KNOWLEDGE_CDN_URL` is configured, the client checks the remote manifest on launch (toggleable) or when the user taps **Sync Latest Intelligence**.

## Directory Layout

| Path | Role |
|------|------|
| `assets/data/v2/knowledge_manifest.json` | Root manifest — lists topic, book, and claim bundle assets |
| `assets/data/v2/topics.json` | Topic tree |
| `assets/data/v2/books.json` | Library catalog |
| `assets/data/v2/seeds/*.json` | Curated claim bundles (priority-ordered) |
| `assets/data/claims_seed.json` | Legacy baseline bundle (priority 0) |
| `assets/data/changelog.json` | Human-readable release notes |
| `tools/generate_claims_seed.mjs` | Regenerate legacy seed from sources |
| `tools/process_the_law.py` | Regenerate Bastiat full text |

## Versioning Fields

Every knowledge document includes:

| Field | Purpose |
|-------|---------|
| `schemaVersion` | JSON schema generation (currently `2`) |
| `kbVersion` | Semantic release version (`2.0.0`, `2.1.0`, …) |
| `contentHash` | `sha256:…` fingerprint for delta detection |
| `updatedAt` | ISO-8601 timestamp |
| `revision` | Per-claim integer bump on edits |

Bump **`kbVersion`** for user-visible releases. Bump **`revision`** on individual claim edits. Recompute **`contentHash`** whenever file bytes change.

## Authoring Workflow

1. **Edit content** — Modify seed JSON, topics, or books under `assets/data/`.
2. **Validate sources** — Each new claim needs ≥2 primary/government sources (project rule).
3. **Update hashes** — Run the publish script (below) or manually set `contentHash` on changed files.
4. **Bump manifest** — Update `kbVersion`, `updatedAt`, and manifest `contentHash` in `knowledge_manifest.json`.
5. **Update changelog** — Add an entry to `assets/data/changelog.json`.
6. **Test locally** — `flutter test` and spot-check Topic Tree + Crusher.
7. **Publish to CDN** — Upload changed files preserving the `data/…` path prefix.
8. **Ship app** (optional) — Include updated assets in the next store build so offline users get the baseline.

## Publishing to CDN

Set `KNOWLEDGE_CDN_URL` in `.env` to your public bucket root, e.g.:

```
KNOWLEDGE_CDN_URL=https://xyz.supabase.co/storage/v1/object/public/knowledge
```

Remote paths mirror bundled assets (without the `assets/` prefix):

```
{CDN}/data/v2/knowledge_manifest.json
{CDN}/data/changelog.json
{CDN}/data/v2/topics.json
{CDN}/data/v2/books.json
{CDN}/data/v2/seeds/wealth_inequality.json
…
```

Optional per-file hash sidecars for precise delta detection:

```
{CDN}/data/v2/seeds/wealth_inequality.json.sha256
```

Run the publish helper:

```powershell
.\tools\publish_knowledge.ps1 -CdnRoot "C:\path\to\cdn\upload" -KbVersion "2.1.0"
```

This copies changed assets, writes hash sidecars, and updates the manifest `contentHash`.

## Client Sync Behavior

| Scenario | Behavior |
|----------|----------|
| No CDN configured | Bundled assets only; sync UI explains configuration |
| Offline | Bundled + any prior overlay; no error blocking usage |
| Remote newer `kbVersion` | Downloads changed assets only, writes overlay, reindexes FTS |
| Auto-check on launch (default on) | Quiet check; auto-downloads when update available |
| Manual **Sync Now** | Check → download → apply → show snackbar result |

Overlay files live at:

```
{ApplicationDocuments}/knowledge_overlay/
  knowledge_manifest.json
  changelog.json
  sync_state.json
  asset_hashes.json
  data/v2/…
```

`KnowledgeService` prefers overlay paths over bundled assets. User favorites, notes, and debate history are unaffected.

## Changelog Discipline

Every `kbVersion` bump requires a `changelog.json` entry:

```json
{
  "version": "2.1.0",
  "date": "2026-10-01",
  "title": "Rent Control Evidence Pack",
  "changes": [
    "6 new claims on rent control outcomes",
    "Updated mobility chart data through 2025"
  ]
}
```

The app merges bundled and synced changelogs, sorted newest-first.

## Testing Sync Locally

1. Copy `assets/` subset to a local folder.
2. Serve via any static file server on port 8080.
3. Set `KNOWLEDGE_CDN_URL=http://localhost:8080` in `.env`.
4. Bump remote `kbVersion` above installed version.
5. Tap **Sync Now** or relaunch with auto-check enabled.

## Related Code

| Component | File |
|-----------|------|
| Overlay persistence | `lib/services/knowledge_overlay_store.dart` |
| Delta sync | `lib/services/knowledge_sync_service.dart` |
| Asset loading | `lib/services/knowledge_service.dart` |
| FTS reindex | `lib/services/database_service.dart` |
| UI | `lib/features/sync/` |

## Community Suggestions (Moderated)

Any visitor can submit ideas via **Suggest New Claim** (Home, Topic Tree) — no account. Submissions save locally in Hive with `pending` status. Curators merge approved entries into seed JSON after out-of-band review — see **[ADDING-CLAIMS.md](ADDING-CLAIMS.md)** for the full curator + community loop.

## Long-Term Curation Process

This is the routine discipline for keeping the knowledge base current as **government data releases**, **new scholarship**, and **community suggestions** arrive — without requiring users to wait for an app store update.

### Cadence

| Rhythm | What happens |
|--------|----------------|
| **Weekly** | Glance at community submissions received out-of-band; triage spam |
| **Monthly** | Spot-check high-traffic claims for broken source URLs |
| **Quarterly** | Full evidence refresh + `kbVersion` release to CDN |
| **Ad hoc** | Major reports (CBO scores, Census SCF, World Bank poverty) → targeted bundle patch within 48h |

### Government & primary data sources (watch list)

| Agency / dataset | Typical release | Claims to refresh |
|------------------|-----------------|-------------------|
| **CBO** | Minimum wage, healthcare, deficit reports | `government-intervention` seeds |
| **BLS / BEA** | Wages, productivity, CPI | `profit-exploitation`, wealth inequality |
| **Census / Fed SCF** | Income, wealth distribution | Gini, mobility, Fed wealth charts |
| **World Bank** | Global poverty ($2.15/day) | `absolute-poverty-world-bank` |
| **Heritage / Fraser** | Economic freedom indices | Nordic myth, founding principles |
| **IMF / national archives** | Historical GDP, hyperinflation | Historical socialism bundle |

When a new report drops:

1. Download the primary PDF or data table (not news summaries).
2. Extract 1–3 quotable statistics with page/table citations.
3. Update the relevant claim in `assets/data/v2/seeds/<bundle>.json` — bump `revision`, `updatedAt`, and source `retrievedAt`.
4. If chart data changed, update `chartData` arrays on the claim.
5. Add a changelog bullet naming the agency and report year.
6. Run `publish_knowledge.ps1` and upload — users with **auto-check on launch** receive the delta silently.

### Scholarship & PD classics

| Type | Process |
|------|---------|
| **New PD excerpt** | Add under `assets/data/books/`, register in `books.json`, link from `claim_reading_links.json` |
| **New curated claim** | Author in seed JSON; ≥2 sources; executive summary first |
| **Community suggestion** | Review contributor submission → merge into seed JSON |

### Curator roles (solo or small team)

1. **Evidence editor** — verifies sources, updates statistics, maintains charts.
2. **Bundle maintainer** — runs publish script, checks manifest hashes, uploads CDN.
3. **Release captain** — writes changelog, runs `flutter test`, spot-checks Crusher + Tree.

One person can wear all three hats; the checklist below stays the same.

### In-app user experience

| Control | Location | Behavior |
|---------|----------|----------|
| **Sync Latest Intelligence** | Home intelligence section (bottom panel) | Check → delta download → FTS reindex → snackbar |
| **Auto-check on launch** | Toggle on sync panel (Home) | Quiet check; auto-download when remote `kbVersion` is newer |
| **Changelog** | Button on sync panel; home **Latest intelligence** strip | Merged bundled + synced entries, newest first |
| **App bar cloud icon** | Home | Badge when update available; scrolls to sync panel |

Offline users always retain the **bundled baseline** plus any previously synced overlay. Sync failures never block reading, Crusher, or Library.

## Public-Domain Library Heartbeat (Forever)

Bundled library texts (`assets/data/books/*.txt`) are maintained by a **perpetual pipeline** that verifies full texts, repairs failures, snapshots offline fallbacks, and surfaces topic-relevant books to add.

```
┌────────────────────┐     weekly / on-demand     ┌─────────────────────────┐
│ library_sources    │ ─────────────────────────► │ library_pipeline.py     │
│ library_candidates │                            │  verify → refresh →     │
└────────────────────┘                            │  discover → snapshot    │
                                                  └───────────┬─────────────┘
                                                              │
                    ┌─────────────────────────────────────────┼─────────────────────────┐
                    ▼                                         ▼                         ▼
           assets/data/books/*.txt              _source_cache/ (offline)      library_run_state.json
           assets/data/v2/books.json            manifest + SHA-256 hashes       last status + hashes
```

### Registry files

| Path | Role |
|------|------|
| `assets/data/v2/library_sources.json` | Canonical download URLs, PG ids, MIA chapters, `minChars`, content `needles`, `wrongContent` guards |
| `assets/data/v2/library_candidates.json` | Topic-mapped wishlist of works to evaluate when they enter the public domain |
| `assets/data/v2/library_run_state.json` | Last heartbeat timestamp, failures, per-book SHA-256 fingerprints |
| `assets/data/books/_source_cache/` | Verified-text mirror used when live fetch fails (Gutenberg down, etc.) |

### Commands

```powershell
# Full heartbeat: verify → repair failures → discover gaps → snapshot cache
py -3 tools/library_pipeline.py heartbeat

# Scheduled wrapper (Task Scheduler / manual)
.\tools\run_library_heartbeat.ps1
.\tools\run_library_heartbeat.ps1 -Commit   # auto-commit if texts changed

# Individual steps
py -3 tools/library_pipeline.py verify
py -3 tools/library_pipeline.py refresh --only civil-disobedience --force
py -3 tools/library_pipeline.py discover
py -3 tools/library_pipeline.py snapshot-cache
```

### Automation

| Trigger | What runs |
|---------|-----------|
| **GitHub Actions** `library.yml` | `verify` on push/PR; weekly `heartbeat` + cache commit on `main` |
| **Flutter CI** | `library_pipeline.py verify` before analyze/test |
| **Local verify** | `.\tools\verify.ps1` includes library verify |
| **Windows Task Scheduler** | `run_library_heartbeat.ps1` weekly (recommended: Sunday 09:00 local) |

### Adding a new public-domain book

1. Confirm PD status and locate a canonical source (Gutenberg, Avalon, MIA).
2. Add an entry to `library_sources.json` with `minChars` and `needles` where helpful.
3. Add catalog row in `books.json` with `fullTextPath` and topic `recommendations`.
4. Run `py -3 tools/library_pipeline.py heartbeat`.
5. Move matching row in `library_candidates.json` to `"status": "installed"` if applicable.
6. Bump `kbVersion` / changelog when shipping to CDN.

### Candidate queue discipline

`library_candidates.json` holds works that are **not yet bundled** but are relevant to topic bundles. On each heartbeat, `discover` prints:

- Topic coverage gaps (topics with zero bundled recommendations)
- Catalog entries missing `fullTextPath` (copyrighted — link Open Library)
- Pending candidates with `searchQueries` for manual or agent-assisted PD checks

When a candidate clears PD review, promote it through the steps above.

## Quarterly Drop Checklist

- [ ] Claims reviewed for source freshness (CBO, BLS, Census, World Bank)
- [ ] Community submissions reviewed and responded
- [ ] Stale URLs replaced; `revision` bumped per edited claim
- [ ] `kbVersion` and `changelog.json` updated with agency/report callouts
- [ ] `.\tools\publish_knowledge.ps1` run; CDN upload verified
- [ ] `flutter test` green (includes `knowledge_sync_integration_test.dart`)
- [ ] Test device: toggle auto-check, manual sync, offline airplane mode
- [ ] Store build includes new bundled baseline (for offline-first users)