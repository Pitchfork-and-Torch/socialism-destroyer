# ADR 003: Offline-First with Hive + Bundled Assets

## Status
Accepted

## Context
App must work without network. Knowledge base is curated and versioned. User data needs local persistence with optional sync.

## Decision
- **Bundled JSON** for initial topics, claims, insights, changelog
- **Hive** for favorites, notes, debate history, reading progress
- **Supabase** for auth and delta sync (Phase 6)

## Alternatives Considered
- **SQLite/drift**: Heavier setup for simple key-value user prefs
- **Isar**: Excellent but added complexity for MVP

## Consequences
- ✅ Instant offline access to full knowledge base
- ✅ Simple user data CRUD
- ⚠️ Large claim updates ship via sync or asset hot-swap