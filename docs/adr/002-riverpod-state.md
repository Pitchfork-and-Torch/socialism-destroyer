# ADR 002: Riverpod for State Management

## Status
Accepted

## Context
Large-scale app with async data loading, user session, search, and sync. Need testable, compile-safe state.

## Decision
Use **flutter_riverpod** with `FutureProvider` for knowledge base and `Provider` for services.

## Alternatives Considered
- **flutter_bloc**: More boilerplate for straightforward async flows
- **Provider alone**: Less ergonomic for complex dependency graphs

## Consequences
- ✅ Easy mocking in tests via `ProviderScope` overrides
- ✅ Clean separation: services → providers → widgets
- ✅ Scales to Argument Crusher streaming responses in Phase 4