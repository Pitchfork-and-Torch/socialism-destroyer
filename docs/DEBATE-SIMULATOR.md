# Debate Simulator — Multi-turn Liberty Training

**Route:** `/debate`  
**App milestone:** v2.0.0  
**Core:** 100% offline (Hive + curated Crusher pipeline)  
**Optional:** `OPENAI_API_KEY` multi-turn polish (labeled in UI)

## Modes

| Mode | Flow |
|------|------|
| **Spar** | User pastes opponent arguments → engine counters with steelman, evidence, fallacies, sources. Optional “Score this reply” for self-coaching. |
| **Challenge** | Engine opens with steelmanned claim (seed text, claim id, topic, or random KB claim) → user rebuts → scored feedback + sourced reinforcement. |
| **Timed drills** | Curated playlists (`debate_playlists.json`) with per-round timers; multi-round Challenge openings via `appendChallengeOpening`. |

## Library passage RAG

`LibraryPassageRagService` ranks offline passages for the Evidence Sidebar:

1. Curated `claim_reading_links.json` for matched claim IDs  
2. Windowed full-text / excerpt scan (capped asset load + token overlap)  
3. Topical book description fallback  

## Retrieval (Crusher hybrid)

FTS + embedding overlap + **local vector** (hashed bag-of-words cosine, `VectorClaimRetrievalBackend.enabled = true`).

## Pipeline

```
Start session → system briefing (+ opening steelman in Challenge)
User turn → (optional score) → CrusherService.crush
         → format engine/coach reply
         → optional LlmCrusherBackend.enhanceDebateTurn
         → Hive DebateSession
Export → Markdown / PDF / share
```

## Scoring (offline)

`DebateScoringService` rates user text 0–100 on:

- **Evidence** — source language (BLS, Census, CBO…), numbers, overlap with engine bullets
- **Specificity** — length, mechanism language (incentives, calculation problem…)
- **Fallacy discipline** — avoids ad hominem; can name opponent fallacies

Coaching lists strengths and concrete improvements. Not a political purity test.

## Evidence Sidebar

Aggregates sources and matched claim IDs across turns; deep-links to `/claim/:id` and Library.

## Entry points

- Home hub card **Debate Simulator**
- Crusher: “Open Debate Simulator” + result “Continue in Debate Simulator”
- Deep links: `/debate?q=…&mode=spar|challenge&claim=…&topic=…`
- Desktop: **Ctrl+5**

## Key files

```
lib/features/debate_simulator/
  services/debate_simulator_service.dart
  services/debate_scoring_service.dart
  services/debate_session_store.dart
  services/debate_export_service.dart
  providers/debate_providers.dart
  screens/debate_simulator_screen.dart
  widgets/…
lib/models/debate_session.dart
```

## Tests

`test/debate_simulator_test.dart` — scoring, spar multi-turn, challenge scoring, long paste, export, JSON round-trip.

## Non-negotiables

- Steelman honesty; primary-source discipline
- Core works with no network / no API key
- LLM never required; when used, session marks `llmAssisted`
