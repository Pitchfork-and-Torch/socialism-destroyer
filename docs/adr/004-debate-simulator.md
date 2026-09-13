# ADR 004 — Debate Simulator as multi-turn Argument Engine

**Status:** Accepted  
**Date:** 2026-07-14  
**Deciders:** Product + engineering (Socialism Destroyer v2.0)

## Context

The Argument Crusher (v1.x) is a high-quality **single-turn** pipeline: paste → hybrid retrieval → steelman + evidence + export. Users need **practice** (multi-turn sparring and scored rebuttals) without abandoning offline-first sourcing.

## Decision

Ship a first-class **Debate Simulator** (`/debate`) that:

1. Reuses `CrusherService` for every engine turn (curated KB only for facts).
2. Supports **Spar** (user posts opponent claims) and **Challenge** (engine opens steelman; user scored).
3. Persists multi-turn sessions in Hive (`debate_sessions` box).
4. Provides offline heuristic **TurnFeedback** (evidence / specificity / fallacy discipline).
5. Surfaces a live **Evidence Sidebar** (sources + matched claim chips).
6. Exports full transcripts (Markdown + PDF).
7. Treats optional OpenAI polish as transparent overlay only (`llmAssisted` flag).

## Consequences

### Positive
- Training loop dramatically raises educational engagement.
- No new content pipeline required for MVP — claims auto-improve engine turns.
- Architecture stays modular for future vector RAG per turn.

### Negative / trade-offs
- Scoring is heuristic, not a human judge — UI must frame it as coaching.
- Long sessions grow Hive payloads; soft-cap user paste at 12k chars.
- Optional LLM can rephrase but must not invent statistics (prompt + sources unchanged).

## Alternatives considered

| Option | Why not |
|--------|---------|
| Only improve single-turn Crusher | Misses practice/engagement leap |
| Pure LLM debate bot | Violates offline + source rigor non-negotiables |
| Library-only AI companion | Valuable later; less “argument engine” identity |

## Related

- [ARGUMENT-CRUSHER.md](../ARGUMENT-CRUSHER.md)
- [DEBATE-SIMULATOR.md](../DEBATE-SIMULATOR.md)
- [ANALYSIS-REPORT-2026-07-14.md](../ANALYSIS-REPORT-2026-07-14.md)
