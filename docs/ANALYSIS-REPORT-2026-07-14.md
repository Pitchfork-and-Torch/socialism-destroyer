# Analysis Report — Socialism Destroyer (2026-07-14)

**Product:** Socialism Destroyer — Pro-America Liberty Argument Engine  
**Live:** https://destroyer.jonbailey.xyz  
**Repo:** `Pitchfork-and-Torch/socialism-destroyer`  
**App version (pre-update):** 1.1.1+3 · **KB:** 3.6.0  

---

## 1. Live production UX

### Shell & brand
- Navy (`#0A1628`) + gold (`#D4AF37`) scholarly identity; Libre Baskerville + Inter.
- Static HTML shell with strong SEO/AEO: Open Graph, Twitter card, JSON-LD (WebSite, WebApplication, FAQ, HowTo), `llms.txt`, sitemap (~239 URLs).
- Flutter CanvasKit SPA (hash routes `#/…`); cold start shows navy loader then onboarding or home.
- Free, no-account web; progress in Hive.

### Routes & journeys
| Route | Experience |
|-------|------------|
| `/` (Home) | Streak/badges, crush bar → Crusher, category chips, daily insight, suggest claim, hub cards (Tree / Library / Study Tools), intelligence sync |
| `/tree` | Hierarchical topics, search, claim list → claim detail |
| `/claim/:id` | Outside shell: steelman, executive summary, evidence, charts, fallacies, sources, library links, export |
| `/crusher` | **Single-turn** paste → hybrid retrieval → steelman + evidence + fallacies + export (MD/PDF/image) + Hive history |
| `/library` | Catalog (122) + search; 111 bundled full texts |
| `/library/read/:bookId` | Reader themes, TOC, highlights, progress, claim↔book recommendations |
| `/study-tools` | External research shortcuts (Scholar, Archive, Gutenberg) |
| `/onboarding` | 3-screen welcome (first visit) |
| `/suggest-claim` | Local claim suggestions |

### Patterns & quality
- **Nav:** Phone bottom chrome; desktop rail (Home / Topics / Crusher / Library). Study tools secondary.
- **Exports:** Claim + Crusher Markdown/PDF/PNG; Crusher “Copy” + “Copy Steelman”.
- **Offline:** Bundled KB; optional CDN delta under `/knowledge`.
- **A11y:** Semantics on nav/search/streak; reduced-motion; desktop shortcuts (Ctrl+1–4, Ctrl+K).
- **Performance:** Large `main.dart.js` (~4MB class); books lazy-loaded; service worker historically flaky (publish script disables SW, forces local CanvasKit).

### Friction vs delight
| Friction | Delight |
|----------|---------|
| Crusher is one-shot — no multi-turn practice | Steelmanning + primary sources builds trust |
| No sparring / scored rebuttal loop | Library depth (socialist primaries + liberty counters) |
| Bottom nav omits Debate/Study | Crush bar + history sheet feel polished |
| SPA limits pure-HTML claim SEO | Strong `llms.txt` + sitemap for answer engines |
| Hub copy still understates library size (“35 classics”) | Export pack for debate prep |

---

## 2. Source & architecture summary

### Stack
Flutter 3.x · Riverpod · go_router · Hive · sqflite FTS5 · fl_chart · fuzzy · optional OpenAI overlay · Supabase-ready (web no sign-in).

### Content
- ~108 unique v2 claim IDs across 10+ seed bundles; 10 root topic categories.
- Source philosophy: steelman first; BLS/Census/CBO/World Bank/academic; no ad hominem.
- Library: 111 PD full texts + 11 catalog-only copyrighted titles.

### Crusher pipeline (production)
```
Input → ArgumentAnalyzer → dual-query Hybrid(FTS + embedding overlap + vector stub)
     → ClaimRanker → curated (≥0.68) / composed (≥0.42) / fallback
     → optional LLM enhance → Hive debate history → export
```

### Gaps vs “Argument Engine”
- History stores single-turn sessions only.
- No multi-turn transcript, challenge scoring, or live evidence sidebar across turns.
- LLM path is single-shot enhance, not debate dialogue.
- Retrieval is strong; **interactive training** is the missing product surface.

---

## 3. SWOT

### Strengths
- Offline-first, free, private (local Hive).
- Source rigor + honest steelman.
- Cross-platform single codebase.
- Hybrid retrieval already pluggable for RAG.
- Large PD library for primary-source reading.
- Mature export and design system.

### Weaknesses
- Single-turn Crusher limits practice & retention.
- Content surface finite (~108 claims); novel claims fall to composed/fallback.
- Flutter web bundle weight / CanvasKit a11y limits.
- Hub stats slightly stale vs real library counts.
- App-store distribution not fully productized.

### Opportunities
- **Debate Simulator** as engagement moat (practice → mastery).
- Scored feedback on user rebuttals (evidence strength, fallacies).
- Deeper claim↔library RAG passages in-sidebar.
- Shareable multi-turn debate cards for social/education.
- Optional LLM only as polish; offline core remains canonical.

### Threats / risks
- Perceived bias if steelman weakens or sources slip.
- LLM hallucination if optional AI drifts from curated stats.
- Performance with long transcripts / full library.
- Political controversy → need clear “educational reference” framing.

---

## 4. User journey map (target)

1. **Discover** — Home crush bar or Topic Tree claim.  
2. **One-shot crush** — Fast rebuttal for a pasted tweet/argument.  
3. **Practice** — Open Debate Simulator; spar multi-turn or challenge mode.  
4. **Deepen** — Evidence sidebar → claim detail → library chapter.  
5. **Export** — Transcript MD/PDF for study group or debate club.  
6. **Return** — Streak + session history (Hive).

---

## 5. Decision: Next Big Update

### Chosen: **Debate Simulator + Semantic Argument Crusher 2.0** (app **v2.0.0**)

**Why this beats alternatives**
| Candidate | Impact | Feasibility | Mission fit |
|-----------|--------|-------------|-------------|
| **Debate Simulator (chosen)** | Transforms engine into training partner; reuses Crusher/export/Hive | High — architecture ready | Highest — practice + sourced steelman |
| Library AI study companion | High for readers | Medium — needs passage chunking/RAG | High but narrower |
| App-store distribution polish | Distribution | Medium ops | Important but not product leap |
| Interactive data dashboards | Medium | Medium | Supports claims, less unique |

**Scope (v2.0)**
- First-class `/debate` mode: Spar + Challenge.
- Multi-turn transcript with Hive session store.
- Engine turns via existing CrusherService (offline).
- User rebuttal scoring (evidence strength, fallacies, specificity).
- Live Evidence Sidebar (sources + matched claims + library hints).
- Enhanced export (full debate Markdown + PDF).
- “Continue in Debate Simulator” from Crusher results.
- Optional multi-turn LLM polish (transparent, off by default).
- Tests, ADR, docs, version bump, web build/deploy prep.

**Non-negotiables retained:** source rigor, steelman honesty, free/private/offline core, optional LLM only.

---

## 6. Implementation milestones

1. Models + Hive session store  
2. Scoring + simulator orchestration  
3. UI (setup, transcript, composer, evidence, score)  
4. Router + home/crusher entry points  
5. Export + optional LLM turn helper  
6. Tests + docs + release artifacts  

---

*Generated as Phase 1 deliverable for the v2.0 Debate Simulator milestone.*
