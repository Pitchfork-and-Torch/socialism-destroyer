# Architecture — Socialism Destroyer

## System Context

```
┌─────────────────────────────────────────────────────────────┐
│                    Socialism Destroyer App                   │
│  ┌──────┐ ┌──────┐ ┌────────┐ ┌────────┐ ┌─────────┐     │
│  │ Home │ │ Tree │ │Crusher │ │ Debate │ │ Library │     │
│  └──┬───┘ └──┬───┘ └───┬────┘ └───┬────┘ └────┬────┘     │
│     └────────┴─────────┴──────────┴───────────┘            │
│                         │                                    │
│              ┌──────────▼──────────┐                        │
│              │   Riverpod Layer    │                        │
│              └──────────┬──────────┘                        │
│       ┌─────────────────┼─────────────────┐                │
│  ┌────▼────┐  ┌────────▼────────┐  ┌─────▼─────┐          │
│  │  Hive   │  │ KnowledgeService │  │ Supabase  │          │
│  │ (local) │  │  (assets JSON)   │  │ (sync)    │          │
│  └─────────┘  └──────────────────┘  └───────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Data Model

### Topics (hierarchical)
- `Topic` → `TopicChild[]` nested under 10 root categories
- Loaded from `assets/data/topics.json`

### Claims (leaf content)
- Full schema: socialist claim, executive summary, evidence, charts, fallacies, sources, related IDs
- Loaded from `assets/data/claims_seed.json`
- Versioned; delta updates via Supabase in Phase 6

### User Interactions (Hive-first)
- Favorites, notes, reading progress, debate history, claim suggestions
- Web: all local in Hive — no account required
- Future native: optional Supabase `profiles` sync (last-write-wins)

## Offline-First Strategy

1. **Bundle** initial knowledge base in assets (no network required)
2. **Hive** stores user data locally immediately
3. **CDN delta sync** on "Sync Latest Intelligence" or auto-check (toggle)
4. **Delta patches** apply over bundled base without full app update

## Argument Crusher Pipeline

```
User Input → ArgumentAnalyzer (intent, fallacies, synonym expansion)
          → Hybrid retrieval (FTS5 + ragText embedding overlap + vector stub)
          → ClaimRanker → curated / composed / fallback response
          → Optional LLM overlay (OPENAI_API_KEY)
          → DebateHistoryEntry → Hive (+ Supabase sync)
          → Export PDF / image card / markdown
```

See [ARGUMENT-CRUSHER.md](./ARGUMENT-CRUSHER.md) for RAG upgrade path and how new claims auto-improve matching.

## Debate Simulator (v2.0)

Multi-turn training on top of the Crusher:

```
Session (Spar | Challenge) → user turns → CrusherService per turn
                           → offline TurnFeedback (evidence/specificity/fallacies)
                           → Evidence Sidebar (sources + claim deep links)
                           → Hive debate_sessions + Markdown/PDF export
                           → optional multi-turn LLM polish (labeled)
```

See [DEBATE-SIMULATOR.md](./DEBATE-SIMULATOR.md) and [adr/004-debate-simulator.md](./adr/004-debate-simulator.md).

## Search Performance

- **FTS5** index built at cold start (`DatabaseService`)
- **Query cache** in `SearchService` (in-memory, per session)
- **Debounced filters** (200ms) on topic tree and library screens
- Results capped at `AppConstants.maxSearchResults` (50)

## Motion & Accessibility

- `AppMotion` tokens + `SdFadeIn` (respects `disableAnimations`)
- `RepaintBoundary` on animated list entrances for 60fps scroll
- `Semantics` on nav, streak strip, search fields, claim cards
- Desktop `Shortcuts` widget: Ctrl+1–4 tabs, Ctrl+K search, ? help, Esc back

## Gamification (local, non-intrusive)

- Hive-backed `UserProgressService`: streak days, crush count
- Seven badges: Patriot, 3-Day Streak, Week Warrior, First Crush, Explorer, Bibliophile, Scholar
- Home hub shows next-badge hint — no popups or leaderboards

## Share & Export Surfaces

| Surface | Actions |
|---------|---------|
| Claim detail | Share markdown, export PDF |
| Argument Crusher | Share, PDF, PNG screenshot |
| Daily insight | Share quote + data point |
| Library | Share book; reader shares highlights or progress |
| Topic claims | Via claim detail toolbar |

## Responsive Layout Targets

| Form Factor | Layout |
|-------------|--------|
| Phone | Single pane, bottom nav |
| iPad | Split: tree sidebar + detail pane |
| Desktop | Navigation rail + keyboard shortcuts |

## Security

- Supabase Row Level Security per user
- No secrets in repo (`.env` gitignored)
- OAuth tokens managed by Supabase Auth SDK