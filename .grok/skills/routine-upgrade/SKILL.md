---
name: routine-upgrade
description: >
  Run the Socialism Destroyer (Liberty Argument Engine) Upgrade & Enhancement Loop:
  audit live site + KB, prioritize, refresh citations, add sourced claims, improve
  features/tests/docs, validate with flutter analyze/test, update changelog/manifest,
  and produce publish notes. Use when the user says "run routine-upgrade", "upgrade
  destroyer", "destroyer cycle", "KB refresh", or weekly maintenance on
  socialism-destroyer / destroyer.jonbailey.xyz. Differentiator: project-specific
  truth-first claim+KB loop for Socialism Destroyer - not generic site SEO or other
  Pitchfork products.
metadata:
  short-description: "Socialism Destroyer upgrade cycle"
  tags:
    - socialism-destroyer
    - liberty-argument-engine
    - knowledge-base
    - claims
    - offline-first
    - flutter
    - upgrade-loop
    - citations
  priority: 35
  example-user-utterances:
    - "run routine-upgrade"
    - "run the destroyer upgrade loop"
    - "Socialism Destroyer weekly cycle"
    - "refresh destroyer claims and citations"
    - "upgrade destroyer.jonbailey.xyz knowledge base"
    - "destroyer Cycle N"
  composes-with:
    - public-github-hygiene
    - site-upgrade-seo-aeo-cf
    - utf8-hygiene
    - first-pass-ship
  allowed-tools:
    - run_terminal_command
    - read_file
    - search_replace
    - write
    - list_dir
    - grep
    - web_search
    - open_page
    - web_fetch
---

# Socialism Destroyer - Routine Upgrade Skill

## When invoked

Execute **one full cycle** of the Upgrade & Enhancement Loop for the open-source project **Socialism Destroyer** (Flutter, offline KB, Cloudflare Pages).

**Authoritative playbook:** `docs/UPGRADE_LOOP.md` in the project repo  
**Project rules:** `AGENTS.md`  
**Default repo path:** `~/socialism-destroyer` or `$env:USERPROFILE\socialism-destroyer`  
**Live:** https://destroyer.jonbailey.xyz/

Do **not** weaken: steelman quality, ≥2 primary sources, offline-first, no tracking/accounts/paywalls.

---

## Phase checklist (run in order)

### 0. Orient

```powershell
cd $env:USERPROFILE\socialism-destroyer
git status -sb
# local KB
(Get-Content assets\data\v2\knowledge_manifest.json -Raw | ConvertFrom-Json) | Select-Object kbVersion, updatedAt
# live
Invoke-WebRequest https://destroyer.jonbailey.xyz/version.json -UseBasicParsing
Invoke-WebRequest https://destroyer.jonbailey.xyz/assets/assets/data/v2/knowledge_manifest.json -UseBasicParsing
```

Reconcile any **live vs git** KB skew before adding new work.

### 1. Audit

- Live health (home, version.json, manifest, llms.txt)
- Orphan seeds: files in `assets/data/v2/seeds/` not listed in manifest
- `node tools/check_citation_freshness.mjs --limit 40`
- Known pain: search precision, web perf, a11y, mobile polish
- Surface a short **audit summary** to the operator

### 2. Prioritize

Rank **5 - 10** items. Weight: philosophy alignment > high-intent topics > retrieval/UX > Phase 8.

High-intent examples: rent control, Nordic model, wealth tax, AI/calculation, China state capitalism, greeflation, degrowth, industrial policy, housing supply.

Prefer **small, reviewable** changes.

### 3. Implement (top items)

Content:

- Follow `docs/ADDING-CLAIMS.md` + existing seed schema
- Steelman in `socialistClaimText` first
- ≥2 government/primary/academic sources each
- Wire new bundles into `knowledge_manifest.json`
- `node tools/bump_kb_manifest.mjs` (or `.\tools\prepublish_checklist.ps1 -SkipBuild`)
- Update `assets/data/changelog.json`

Code/tooling: incremental only; match Riverpod/go_router/Hive patterns; navy/gold theme.

UTF-8: never ship mojibake in `web/index.html` (UTF-8 no BOM).

### 4. Validate

```powershell
$flutter = "C:\flutter\bin\flutter.bat"
& $flutter analyze --no-fatal-infos --no-fatal-warnings
& $flutter test --reporter compact --concurrency=1
node tools/check_citation_freshness.mjs --limit 30
```

Spot-check Topic Tree + Crusher retrieval for new claims.

### 5. Document

- Changelog entry required for content
- Manifest versions/hashes aligned
- Update llms.txt / meta counts if needed
- Produce **Next-cycle prompt** (template in `docs/UPGRADE_LOOP.md`)

### 6. Publish notes (do not force-deploy without operator intent)

Document exact steps:

```powershell
gh auth switch --user Pitchfork-and-Torch
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.grok\scripts\scan-secrets-before-commit.ps1 -Path $PWD
.\tools\publish-web.ps1
```

Post-deploy verify: version.json, knowledge_manifest kbVersion, claim present in UI.

If machine standing practice applies: update LIVE-SITES registry after successful ship.

### 7. Close

State shipped vs deferred, residual risks, and paste-ready next-cycle prompt.

---

## Scripts this skill expects

| Script | Role |
|--------|------|
| `tools/check_citation_freshness.mjs` | URL health |
| `tools/bump_kb_manifest.mjs` | Hash + optional version bump |
| `tools/prepublish_checklist.ps1` | Gate before publish |
| `tools/publish-web.ps1` | Cloudflare Pages ship |
| `tools/publish_knowledge.ps1` | Knowledge CDN folder |
| `tools/generate-sitemap.mjs` | Sitemap |
| `tools/verify.ps1` | Library + analyze + test |

---

## Guardrails (fail closed)

- No accounts, telemetry, paywalls, or tracking SDKs
- No claim without steelman + ≥2 quality sources
- No orphan seed files left unregistered
- No large rewrites when a seed append works
- Do not claim "done" without analyze (errors) + tests consideration
- Public GitHub: Pitchfork-and-Torch + secret scan before push

---

## Output format for the operator

1. **Audit summary** (bullets)
2. **Ranked backlog** (table)
3. **What shipped this cycle**
4. **Validation results**
5. **Publish & verify notes**
6. **Next-cycle prompt** (ready to paste)
