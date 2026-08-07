# App Store & Google Play — Submission Prep (v2.1)

Socialism Destroyer is **store-ready** in product terms: free educational reference, no account required for core, local-first privacy, offline knowledge base, and clear positioning.

This document is the operator checklist for **TestFlight / App Store / Play Console**. Builds still require platform SDKs (Xcode on macOS; Android SDK + signing keys).

## Product positioning (store copy)

| Field | Suggested copy |
|-------|----------------|
| **Name** | Socialism Destroyer |
| **Subtitle** | Liberty Argument Engine |
| **Short description** | Steelman socialist claims, then rebut with Census, BLS, CBO, and academic sources. Offline-first debate practice. |
| **Category** | Education / Reference |
| **Content rating** | Everyone / PEGI 3-equivalent educational reference (no violence, no user chat network) |
| **Price** | Free |

### Long description (draft)

Socialism Destroyer is a free, offline-first Liberty Argument Engine. Explore a sourced topic tree, crush arguments with curated evidence, practice multi-turn debates with scoring and library passages, and read 110+ public-domain classics (Bastiat, Smith, Spencer, Spooner, Founders, and socialist primaries for honest steelmanning).

- Argument Crusher — paste any claim for steelman + sources  
- Debate Simulator — Spar, Challenge, timed drills & playlists  
- Evidence Sidebar with offline library passage RAG  
- Public-domain library reader  
- No account required; progress stays on your device  

## Privacy (store privacy nutrition labels)

| Data | Practice |
|------|----------|
| Account | Optional (native Supabase only); **web free path has no sign-in** |
| Contact info | Not collected for free web |
| User content | Favorites, notes, debate history stored **locally (Hive)** |
| Diagnostics | None shipped by default |
| Tracking | None |
| Optional AI | Only if operator/user supplies `OPENAI_API_KEY` — not in production web bundle |

Privacy policy URL (set when publishing): use your public policy page on jonbailey.xyz or GitHub SECURITY.md + product privacy section.

## Screenshots to capture (all platforms)

Capture on **navy/gold** theme, real content, no PII:

1. **Home** — streak strip + crush bar + Debate Simulator hub card  
2. **Topic tree** — expanded category with claims  
3. **Claim detail** — steelman (red) → executive summary → evidence  
4. **Argument Crusher** — result with sources + export toolbar  
5. **Debate Simulator** — multi-turn transcript + Evidence Sidebar (desktop)  
6. **Debate drill** — timed playlist panel  
7. **Library reader** — Bastiat or Federalist chapter  
8. **Share card** — branded debate/crusher PNG (optional marketing)

Phone + tablet sizes per store requirements. Desktop Windows optional for Microsoft Store later.

## Build commands

```bash
# Android
flutter build apk --release
flutter build appbundle --release
# → build/app/outputs/flutter-apk/app-release.apk
# → build/app/outputs/bundle/release/app-release.aab

# iOS (macOS)
flutter build ipa
# Upload via Xcode Organizer / Transporter → TestFlight

# Windows
flutter build windows --release
```

## Package IDs

Confirm in platform configs before first submission:

- Android `applicationId` — `android/app/build.gradle.kts`  
- iOS bundle ID — Xcode `Runner` target  
- Signing: Play App Signing; Apple Developer team + Sign in with Apple only if enabling native auth  

## Review notes (what to tell reviewers)

> Educational reference app. Content steelsmans political/economic claims and presents counter-evidence with primary sources. No user-generated social feed. No account required for core features. Optional local notes and debate history.

## Post-approval

- Link store badges from destroyer.jonbailey.xyz  
- Keep `docs/DISTRIBUTION.md` and this file in sync with version bumps  
- Run `node tools/check_citation_freshness.mjs` before major content releases  
