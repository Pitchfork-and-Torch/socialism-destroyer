# Socialism Destroyer

**The Pro-America Liberty Argument Engine**

A sourced claim-vs-counterclaim engine for individual liberty and free markets. Every entry steelmans the opposing argument first, then answers with government data, academic research, historical archives, and public-domain primaries. No slogans in place of evidence.

[![Live](https://img.shields.io/badge/live-destroyer.jonbailey.xyz-02569B)](https://destroyer.jonbailey.xyz)
[![App](https://img.shields.io/badge/app-2.8.0-1B4F72)](https://destroyer.jonbailey.xyz)
[![KB](https://img.shields.io/badge/KB-3.19.0-117A65)](https://destroyer.jonbailey.xyz)
[![Flutter](https://img.shields.io/badge/Dart-3.12+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## What this is

Socialism Destroyer is a **reference and practice tool**, not a meme app. The live product is the free web app at [destroyer.jonbailey.xyz](https://destroyer.jonbailey.xyz). The same Flutter codebase can be built for iOS, Android, Windows, macOS, and Linux; store distribution is **not shipped** (Phase 8).

**Current corpus (KB 3.19.0):** 217 unique curated claims (legacy seed plus v2 bundles, de-duplicated by id), 11 top-level topic families, 120 bundled public-domain full texts, and 16 catalog-only copyrighted titles with external links.

### Free, no account

The web app is **free**: no paywall, no subscription, and **no account required**. Topic tree, Argument Crusher, Debate Simulator, public-domain library, study-tool links, optional knowledge CDN sync, and claim suggestions work after a short onboarding. Progress, notes, highlights, and favorites stay on the device (Hive). Suggest-a-claim submissions stay local until a curator merges them.

Leftover auth packages exist in `pubspec.yaml` for optional native experiments. They are **not** part of the public web product and are not initialized on cold start.

### Design principles

| Principle | What the code actually does |
|-----------|-----------------------------|
| Truth-first | Claims cite Census, BLS, BEA, CBO, World Bank, academic papers, and primary archives |
| Steelman then rebut | `socialistClaimText` is the strongest opposing formulation before the counter |
| No ad hominem | Evidence, incentives, calculation problems, historical outcomes |
| Offline-first | Bundled knowledge base + Hive local storage; optional CDN delta under `/knowledge` |
| Flutter codebase | Single repo; **live ship is web**. Other targets are source-buildable, not store-listed |

### Brand palette

- **Navy:** `#0A1628`
- **Gold:** `#D4AF37`
- **Danger red:** `#C0392B` (socialist-claim highlight)
- **Typography:** Libre Baskerville (headings) + Inter (body)

### App icon and splash

**Scales + Star** is the shipped motif.

| Asset | Preview |
|-------|---------|
| **App icon** (iOS/Android/desktop/web) | ![App icon](assets/images/branding/app_icon_preview.png) |
| **Splash screen** (navy field + centered gold motif) | ![Splash](assets/images/branding/splash_preview.png) |

Regenerate platform assets after editing masters:

```bash
py tools/prepare_branding_assets.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Quick start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.12+)
- Platform toolchains for your target (optional; web preview needs Chrome)

### Setup

```bash
git clone https://github.com/Pitchfork-and-Torch/socialism-destroyer.git
cd socialism-destroyer

flutter pub get

cp .env.example .env

flutter run -d chrome     # local web preview
flutter devices           # other attached targets
```

The production build is [destroyer.jonbailey.xyz](https://destroyer.jonbailey.xyz).

### Environment variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `KNOWLEDGE_CDN_URL` | Optional | Delta knowledge sync (production default: `https://destroyer.jonbailey.xyz/knowledge`) |
| `OPENAI_API_KEY` | Optional | Argument Crusher / Debate wording overlay. Public web ships without it. |

---

## Architecture

```
lib/
  main.dart                         App entry, Riverpod scope
  core/                             Cold-start init (Hive, optional FTS)
  features/
    auth/                           3-screen onboarding (no sign-in)
    home/                           Dashboard, daily insight, high-intent pack
    tree/                           Topic tree + claim detail + Battle Brief/Card
    crusher/                        Argument Crusher (local retrieval)
    debate_simulator/               Multi-turn Spar / Challenge
    library/                        Public-domain reader + passage search
    study_tools/                    Outbound links to free research tools
    suggestions/                    Suggest New Claim (local, no account)
    sync/                           Optional CDN overlay + changelog
    shared/                         go_router, shell, share/export
  models/                           Topic, Claim, Source, Book, ...
  services/                         Knowledge, search, Hive, overlay store
  providers/                        Riverpod
  themes/                           Navy/gold
  utils/                            AppConstants (KB version must match manifest)

assets/data/
  claims_seed.json                  Legacy baseline (overridden by v2 on id clash)
  v2/knowledge_manifest.json        KB version + bundle list
  v2/seeds/*.json                   Curated v2 claims
  v2/topics.json                    Topic tree (11 top-level families)
  v2/books.json                     Library catalog (136 entries)
  changelog.json                    In-app KB changelog
  books/                            Bundled public-domain texts
  study_tools.json                  Outbound study-tool links
  daily_insights.json               Rotating quotes + data points

test/                               Unit + widget tests (CI skips goldens)
docs/                               Architecture, claims, debate, distribution
```

### Tech stack

| Layer | Choice | What it is used for |
|-------|--------|---------------------|
| Framework | **Flutter** | UI; live product is web |
| State | **Riverpod** | Providers |
| Navigation | **go_router** | Routes and deep links |
| Offline | **Hive** | Favorites, notes, highlights, suggestions, overlay on web |
| Charts | **fl_chart** | Optional claim charts |
| Search | **FTS5 + fuzzy + hashed bag-of-words** | SQLite FTS5 on native/desktop; fuzzy/token ranking on web; local hashed overlap everywhere. No cloud vector index. |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/adr/](docs/adr/).

---

## What ships

| Surface | Status | Honest description |
|---------|--------|--------------------|
| Topic tree + claim detail | Shipped | 217 unique claims, steelman first, sources, Battle Brief, Hearing Brief, 1200x630 Battle Card PNG |
| Argument Crusher | Shipped | Matches curated claims via local search; Markdown/PDF/image export; optional LLM overlay if a key is set |
| Debate Simulator | Shipped | Multi-turn Spar / Challenge, timed playlists, evidence sidebar, library passage search, transcript export |
| Public-domain library | Shipped | 120 full texts offline; 16 modern titles catalog-only with external links; local highlights and notes |
| Knowledge sync | Shipped | Optional CDN delta under `/knowledge`; bundled KB is the offline baseline |
| Study tools | Shipped | Outbound links (Scholar, FRED, Archive, OLL, Gutenberg, Fraser, Heritage, World Bank PIP, ...) |
| Suggest a claim | Shipped | Local queue; curator merge required |
| Store listing | Not shipped | See [docs/STORE-SUBMISSION.md](docs/STORE-SUBMISSION.md) |

See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md) for release checklists.

---

## Testing

```bash
flutter test
flutter test integration_test/
```

CI runs `flutter analyze` and `flutter test` excluding `test/golden/` (Linux font variance).

Manual checks:

- Type a distinctive phrase in Argument Crusher and confirm a curated claim, steelman, and sources.
- Open Debate Simulator, Challenge mode, evidence sidebar, export.
- Claim detail: Battle Brief copy and Battle Card PNG.

See [docs/TESTING.md](docs/TESTING.md) and [docs/DEBATE-SIMULATOR.md](docs/DEBATE-SIMULATOR.md).

---

## Content and sourcing

Every counter must cite **specific data or documents** with live URLs. Priority sources:

- U.S. Census Bureau, BLS, BEA, CBO
- World Bank (absolute poverty metrics)
- Heritage Index of Economic Freedom, Fraser Institute
- Chetty et al. mobility studies
- Primary archives and public-domain classics (Bastiat, Smith, Locke, Bohm-Bawerk, Founders)

New claims: follow [docs/ADDING-CLAIMS.md](docs/ADDING-CLAIMS.md). Minimum **two** government/primary/academic sources. After content edits, bump `knowledge_manifest.json`, run `node tools/bump_kb_manifest.mjs`, and update `assets/data/changelog.json`.

```bash
node tools/check_citation_freshness.mjs --limit 30
```

---

## Contributing

1. Branch from `main`.
2. Match existing folder structure under `lib/features/`.
3. New claims need at least two primary/government sources and a steelman.
4. Run `flutter analyze` and `flutter test` before a PR.
5. Content changes bump `assets/data/changelog.json` and the KB manifest. App version (`pubspec.yaml`) is independent.

### Commit convention

```
feat: add argument crusher export to PDF
fix: tree expansion animation on iPad
content: add 5 claims on rent control evidence
docs: update ADR for CDN sync
```

---

## Web publish (Cloudflare Pages)

```powershell
powershell -File tools\publish-web.ps1          # build + deploy
powershell -File tools\publish-web.ps1 -BuildOnly   # local build only
```

Production URL: **https://destroyer.jonbailey.xyz**

The publish script swaps in `.env.web.publish` (no API secrets) before `flutter build web`.

---

## Legal and privacy

- MIT license ([LICENSE](LICENSE)).
- Reading progress, highlights, notes, and suggestions stay on-device on the web build.
- Fair-use quotes only in claim summaries.
- Community **Suggest New Claim** flow (no account; saved locally; see [docs/ADDING-CLAIMS.md](docs/ADDING-CLAIMS.md)).
- Public-domain texts only in the bundled library; copyrighted titles are catalog links.
- **Free** -- core tools work without payment or account.

---

## Related tools (Pitchfork-and-Torch)

| Project | Role |
|---------|------|
| [Apple-Notes-to-PDF](https://github.com/Pitchfork-and-Torch/Apple-Notes-to-PDF) | Local research archive export (no cloud) |
| [NetForge](https://github.com/Pitchfork-and-Torch/netforge) ([site](https://netforge.jonbailey.xyz/)) | Host network hardening while you study offline |
| [trench-coat](https://github.com/Pitchfork-and-Torch/trench-coat) | Optional privacy routing on open networks |
| [ghost-continuum](https://github.com/Pitchfork-and-Torch/ghost-continuum) | Defense plane if you take the library off-grid |

Debate content stays offline-first; networking tools are optional and separate.

---

## Support

Socialism Destroyer is **free and open source**. Bug reports and feature requests: [GitHub Issues](https://github.com/Pitchfork-and-Torch/socialism-destroyer/issues).

---

*Built for truth. Built for liberty. Built for America.*
