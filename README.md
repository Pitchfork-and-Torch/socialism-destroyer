# Socialism Destroyer

**The Pro-America Liberty Argument Engine**

> *The ultimate claim-vs-counterclaim engine for individual liberty, free markets, and American exceptionalism. Fully sourced. Always updated. Built for truth.*

[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Vision

Socialism Destroyer is a **serious, authoritative reference and debate tool** â€” not a meme app. Every claim and counter is sourced from primary data, peer-reviewed research, and verifiable historical records. The app steelmans socialist arguments first, then dismantles them with evidence, incentives, and historical outcomes.

**Target user feeling:** *"I just opened the app and instantly feel smarter and more equipped."*

### Free for everyone

The live web app at [destroyer.jonbailey.xyz](https://destroyer.jonbailey.xyz) is **100% free** â€” no paywall, no subscription, and **no account required**. Topic tree, Argument Crusher, public-domain library, study tools, intelligence sync, and claim suggestions all work immediately after a short onboarding. Progress, notes, and favorites stay on your device (Hive).

### Design Principles

| Principle | Implementation |
|-----------|----------------|
| Truth-first | U.S. Census, BLS, BEA, World Bank, Heritage/Fraser indices, Chetty mobility, Soviet archives |
| Steelman then rebut | Every entry presents the strongest socialist claim before the counter |
| No ad hominem | Evidence, incentives, calculation problems, historical outcomes only |
| Offline-first | Bundled knowledge base + Hive local storage; optional CDN delta sync |
| Cross-platform native | Single Flutter codebase â†’ iOS, Android, iPadOS, Windows, macOS, Linux |

### Brand Palette

- **Navy:** `#0A1628` â€” authority, depth
- **Gold:** `#D4AF37` â€” excellence, liberty accents
- **Danger red:** `#C0392B` â€” socialist claim highlights
- **Typography:** Libre Baskerville (headings) + Inter (body)

### App Icon & Splash

**Scales + Star** is the shipped motif â€” it reads clearly at small sizes and matches the truth-and-evidence positioning.

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

## Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44+ (stable)
- Dart 3.12+
- Platform toolchains for your target (Xcode, Android Studio, Visual Studio for Windows)

### Setup

```bash
git clone https://github.com/Pitchfork-and-Torch/socialism-destroyer.git
cd socialism-destroyer

flutter pub get

cp .env.example .env

flutter run -d windows    # Windows desktop
flutter run -d chrome     # Web preview (dev only)
flutter devices           # List available targets
```

Run `flutter run -d windows` or open [destroyer.jonbailey.xyz](https://destroyer.jonbailey.xyz) to preview the live build.

### Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `KNOWLEDGE_CDN_URL` | Optional | Delta knowledge sync (production: bundled under `/knowledge`) |
| `OPENAI_API_KEY` | Optional | Enhanced Argument Crusher LLM overlay |

---

## Architecture Overview

```
lib/
â”œâ”€â”€ main.dart                    # App entry, Hive init, Riverpod scope
â”œâ”€â”€ features/
â”‚   â”œâ”€â”€ auth/                    # Onboarding (3-screen welcome flow)
â”‚   â”œâ”€â”€ suggestions/             # Suggest New Claim (local, no account)
â”‚   â”œâ”€â”€ home/                    # Dashboard, daily insight, quick categories
â”‚   â”œâ”€â”€ tree/                    # Hierarchical topic tree + claim detail
│   ├── crusher/                 # Argument Crusher (NL search → sourced rebuttal)
│   ├── debate_simulator/        # Multi-turn Spar / Challenge (v2.0)
│   ├── library/                 # Public-domain reader (Smith, Bastiat, Locke…)
â”‚   â””â”€â”€ shared/
â”‚       â”œâ”€â”€ router/              # go_router navigation
â”‚       â””â”€â”€ widgets/             # AppLogo, shared UI
â”œâ”€â”€ models/                      # Topic, Claim, Source, Book, UserInteraction
â”œâ”€â”€ services/                    # Knowledge, Search, LocalStorage, Sync, ClaimSuggestion
â”œâ”€â”€ providers/                   # Riverpod providers
â”œâ”€â”€ themes/                      # AppColors, AppTheme (navy/gold)
â””â”€â”€ utils/                       # AppConstants

assets/
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ topics.json              # 10 top-level categories
â”‚   â”œâ”€â”€ claims_seed.json         # Legacy baseline (superseded by v2 seeds)
â”‚   â”œâ”€â”€ v2/seeds/*.json          # Curated v2 claims
â”‚   â”œâ”€â”€ daily_insights.json      # Rotating quotes + data points
â”‚   â”œâ”€â”€ changelog.json           # Versioned knowledge base changelog
â”‚   â””â”€â”€ books/                   # Public-domain text assets
â””â”€â”€ images/                      # Branding, icons

test/                            # Widget + unit tests
integration_test/                # End-to-end scenarios
docs/
â”œâ”€â”€ adr/                         # Architecture Decision Records
â”œâ”€â”€ ARCHITECTURE.md
â”œâ”€â”€ BUILD.md
â”œâ”€â”€ DISTRIBUTION.md              # TestFlight, stores, .exe readiness
â”œâ”€â”€ TESTING.md
â””â”€â”€ content-pipeline.md
```

### Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | **Flutter** | True native cross-platform from single codebase |
| State | **Riverpod** | Compile-safe, testable, scales to large apps |
| Navigation | **go_router** | Declarative routes, deep linking, split-view ready |
| Offline | **Hive** | Fast key-value for favorites, notes, history |
| Charts | **fl_chart** | Interactive poverty/mobility/GDP visualizations |
| Search | **Fuzzy + RAG-ready** | Local fuzzy now; vector layer in Phase 4 |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/adr/](docs/adr/) for detailed decisions.

---

## Core Features

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 1 | ✅ | Scaffold, onboarding, folder structure |
| 2 | ✅ | Topic tree UI, detail view, global search |
| 3 | ✅ | 90+ curated claims, source system, v2 manifest |
| 4 | ✅ | Argument Crusher (FTS retrieval + optional LLM overlay) |
| 5 | ✅ | Public-domain library reader, highlights, progress |
| 6 | ✅ | Knowledge sync panel, changelog, CDN overlay pipeline |
| 7 | ✅ | Polish: 60fps motion, a11y, desktop shortcuts, share/export, streaks |
| **2.0** | ✅ | **Debate Simulator** — multi-turn spar/challenge, scoring, evidence sidebar |
| **2.1** | ✅ | Library passage RAG, local vectors, timed drills, SEO/AEO, store prep |
| 8 | 🔓 | TestFlight / App Store / Play / signed .exe distribution — see docs/STORE-SUBMISSION.md |

See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md) for release checklists.

---

## Testing

```bash
flutter test
flutter test integration_test/
```

Manual scenarios:

> User types *"capitalism exploits workers"* in Argument Crusher → surfaces exploitation claim + mobility data + related topics.

> Open **Debate Simulator** → Challenge mode → write a sourced rebuttal → receive score + evidence sidebar → export transcript.

See [docs/TESTING.md](docs/TESTING.md) and [docs/DEBATE-SIMULATOR.md](docs/DEBATE-SIMULATOR.md).

---

## Content & Sourcing Standards

Every counter must cite **specific data or documents** with links/DOIs. Priority sources:

- U.S. Census Bureau, BLS, BEA
- World Bank (absolute poverty metrics)
- Heritage Index of Economic Freedom, Fraser Institute
- Chetty et al. mobility studies
- Primary Soviet archives, Conquest, DikÃ¶tter
- Mises, Hayek, Bastiat, Smith, Founding Fathers

Regenerate seed data:

```bash
node tools/generate_claims_seed.mjs
```

---

## Contributing

1. Branch from `main`: `feat/phase-N-description`
2. Follow existing folder structure under `lib/features/`
3. All new claims require minimum 2 primary/government sources
4. Run `flutter analyze` and `flutter test` before PR
5. Content changes bump `assets/data/changelog.json`

### Commit Convention

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

## Legal & Privacy

- Minimal data collection; reading progress and notes stay local on the web build
- Fair-use quotes only in claim summaries
- Community **Suggest New Claim** flow (no account â€” saved locally for curator review; see [docs/ADDING-CLAIMS.md](docs/ADDING-CLAIMS.md))
- Public-domain texts only in library
- **100% free** â€” every feature on the web works without payment or account

---


## Related tools (Pitchfork-and-Torch)

| Project | Role |
|---------|------|
| [Apple-Notes-to-PDF](https://github.com/Pitchfork-and-Torch/Apple-Notes-to-PDF) | Local research archive export (no cloud) |
| [NetForge suite](https://github.com/Pitchfork-and-Torch/netforge-windows) | Host network hardening while you study offline |
| [trench-coat](https://github.com/Pitchfork-and-Torch/trench-coat) | Optional privacy routing on open networks |

Debate content stays offline-first; networking tools are optional and separate.

---
## Support the work

Socialism Destroyer is **free and open source**. Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/Pitchfork-and-Torch/socialism-destroyer/issues).

---

*Built for truth. Built for liberty. Built for America.*