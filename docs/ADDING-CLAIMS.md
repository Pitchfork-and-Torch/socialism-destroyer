# Adding & Updating Claims

A simple, repeatable process for keeping the Socialism Destroyer knowledge base accurate and **routinely updated** — without shipping a full app release when CDN sync is configured.

## Two Paths

| Path | Who | Result |
|------|-----|--------|
| **Curator** | You / maintainers | Claims land in bundled JSON + CDN immediately after review |
| **Community** | Any visitor (no account) | Local submission queue on device → curator manually merges into JSON |

Nothing from community submissions is published until a curator approves sources and merges JSON.

---

## Curator Workflow (JSON → CDN)

### 1. Edit structured data

| File | When to edit |
|------|----------------|
| `assets/data/v2/seeds/<topic>.json` | New or updated claim bundles (wealth, profit, government, historical, nordic, human_nature, founding) |
| `tools/seeds_v22/*.mjs` | Modular claim authoring for expansion builds |
| `tools/build_kb_v22.mjs` | Assembles v2.2+ bundles, bumps manifest/changelog |
| `assets/data/v2/topics.json` | New subtopics or description tweaks |
| `assets/data/v2/books.json` | Library catalog changes |
| `assets/data/changelog.json` | User-visible release notes |

Each claim must include **≥2 sources** (government, academic, or primary). Follow the shape in existing seeds (`socialistClaimText`, `executiveSummary`, `evidenceBullets`, `sources`, `fallacies`, `tags`, versioning fields).

Optional helpers:

```bash
node tools/generate_claims_seed.mjs    # legacy seed regeneration
node tools/merge_wealth_claims.mjs     # example: append wealth bundle claims
```

### 2. Bump versions

| Field | Rule |
|-------|------|
| `kbVersion` | Semantic bump for releases (`2.1.0` → `2.2.0`) |
| `revision` | Per-claim integer on edits |
| `contentHash` | Recompute after file bytes change |
| `updatedAt` | ISO-8601 UTC |

Update `assets/data/v2/knowledge_manifest.json` `kbVersion` and `contentHash` when any bundle changes.

### 3. Changelog entry

Add to `assets/data/changelog.json`:

```json
{
  "version": "2.2.0",
  "date": "2026-10-01",
  "title": "Short headline",
  "changes": ["Bullet 1", "Bullet 2"]
}
```

The home **Latest intelligence** strip and sync panel **Changelog** sheet read this file (bundled + synced overlay).

### 4. Validate locally

```bash
flutter test
flutter analyze
```

Spot-check Topic Tree, Claim Detail (charts, PD quotes), and Argument Crusher search.

### 5. Publish to CDN

```powershell
.\tools\publish_knowledge.ps1 -CdnRoot "C:\path\to\cdn\upload" -KbVersion "2.2.0"
```

Upload the folder to your `KNOWLEDGE_CDN_URL` bucket. Clients with **auto-check on launch** or **Sync Latest Intelligence** pull deltas without an app store build.

### 6. Optional store build

Ship updated `assets/` in the next app release so offline-first users get the new baseline.

---

## Community Workflow (Suggest New Claim)

### In the app (free, no account)

1. **Home → Suggest** or **Topic Tree FAB → Suggest claim** or **Home → Your suggestions → New**.
2. Form requires: topic, title, steelmanned socialist claim, counter summary, **≥2 source URLs**.
3. Submit → saved locally in Hive (`claim_suggestions_local`) with `status = pending` and `userId = anonymous`.
4. User sees submissions on **Home → Your suggestions** (device-local list).

Submissions stay on the user's device. Curators receive ideas through [GitHub Issues](https://github.com/Pitchfork-and-Torch/socialism-destroyer/issues) and merge approved content into seed JSON.

### Curator review (manual)

1. Receive submission details from the contributor (or inspect during a support session).
2. Verify sources (live URLs, primary data, no paywalled-only citations).
3. If approved: copy fields into a seed JSON claim object; run curator workflow above.
4. If rejected: reply to the contributor with brief notes.

Approved claims appear in the next `kbVersion` + changelog — users who sync see them without updating the app.

---

## Quarterly Checklist

- [ ] Review any community submissions received out-of-band
- [ ] Refresh stale government statistics (Census, BLS, World Bank)
- [ ] Bump `kbVersion` + `changelog.json`
- [ ] `flutter test` green
- [ ] CDN upload verified on a test device
- [ ] Store build includes new bundled baseline (optional)

## Related Docs

- [content-pipeline.md](content-pipeline.md) — CDN layout, overlay merge, sync behavior
- [DISTRIBUTION.md](DISTRIBUTION.md) — store release process
- Web builds store suggestions locally in Hive (no account required)