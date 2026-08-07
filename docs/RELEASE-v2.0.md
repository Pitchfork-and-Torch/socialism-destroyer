# Release notes — v2.0.0 Debate Simulator

**Date:** 2026-07-14  
**App:** 2.0.0+4  
**KB changelog:** 3.7.0  

## What shipped

Debate Simulator turns Socialism Destroyer into a multi-turn training partner while keeping the offline-first, steelman-first Argument Crusher as the factual core.

### User-facing
- `/debate` — Spar & Challenge modes
- Live Evidence Sidebar
- Offline rebuttal scoring + coaching
- Transcript export (Markdown, PDF, share)
- Session history (Hive)
- Entry from Home, Crusher, deep links, Ctrl+5

### Engineering
- `lib/features/debate_simulator/`
- `lib/models/debate_session.dart`
- Hive box `debate_sessions`
- Optional multi-turn LLM polish on existing `LlmCrusherBackend`
- Tests in `test/debate_simulator_test.dart`
- ADR-004

## Web deploy

```powershell
cd socialism-destroyer
powershell -File tools\publish-web.ps1          # analyze + test + build + Cloudflare Pages
# or
powershell -File tools\publish-web.ps1 -BuildOnly
```

Production: https://destroyer.jonbailey.xyz  
Verify: open `/#/debate`, run Challenge offline, export Markdown.

## Native artifacts

```bash
flutter build apk --release
flutter build appbundle --release
# iOS (macOS only)
flutter build ipa
flutter build windows --release
```

### Store checklist (unchanged path)
- Privacy: local-first Hive; optional CDN sync; optional OpenAI only if user supplies key (web publish must not ship secrets — use `.env.web.publish`)
- Education/reference positioning; free web no account
- Screenshots: Home, Debate Simulator, Crusher, Library reader, Claim detail

## Rollback

Cloudflare Pages: redeploy previous deployment of project `socialism-destroyer`.  
Git: revert v2.0 commit; republish.

## Post-deploy verification

- [ ] Home shows Debate Simulator card
- [ ] `/#/debate` setup → Spar multi-turn works offline
- [ ] Challenge mode scores a rebuttal
- [ ] Crusher “Continue in Debate Simulator” preserves query
- [ ] Export copy markdown works
- [ ] Topic tree / library / claim detail unchanged
- [ ] No `OPENAI_API_KEY` in production web bundle

## Next iteration ideas (Phase 9+)

1. Passage-level library RAG in Evidence Sidebar  
2. Vector retrieval backend (Vectorize / pgvector)  
3. Shareable debate image cards  
4. App Store / Play full submission  
5. Citation freshness automation for BLS/Census series  
6. Debate drills: timed rounds, topic playlists  
