# ADR 001: Flutter for Cross-Platform Native

## Status
Accepted

## Context
Need single codebase producing native builds for iOS, Android, iPadOS, Windows, macOS, Linux with premium feel and offline-first support.

## Decision
Use **Flutter** with platform channels only where needed (speech-to-text, sign-in).

## Consequences
- ✅ One team, one UI codebase, consistent branding
- ✅ Strong animation/performance for tree and transitions
- ✅ Mature desktop support (Windows primary dev target)
- ⚠️ Supabase + Google/Apple auth require per-platform config
- ⚠️ App size larger than native-only; mitigated by lazy library loading