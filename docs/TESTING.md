# Testing Strategy

## Layers

### Unit Tests (`test/`)
- `KnowledgeService` loads topics and claims from assets
- `SearchService` returns relevant claims for known queries
- `CrusherService` maps exploitation arguments to curated claims
- `DebateSimulatorService` spar multi-turn, challenge scoring, long paste, export
- `DebateScoringService` rewards sources / penalizes ad hominem
- Model serialization round-trips

### Widget Tests (`test/`)
- `OnboardingScreen` renders 3 pages and navigates to home
- `TopicTreeScreen` expands/collapses topics
- `ClaimDetailScreen` renders all sections when claim exists
- `ArgumentCrusherScreen` shows results after search
- `HomeScreen` hub, sync panel, bottom nav

### User Journey Tests (`test/user_journeys/`)
| Test | Scenario |
|------|----------|
| `iphone_new_user_journey_test` | Home → topic tree → home crush → library reader (no sign-in) |
| `desktop_venezuela_journey_test` | Desktop split-view → Venezuela claim deep-dive |
| `ipad_split_view_test` | iPad portrait/landscape split pane |

### Edge Cases (`test/edge_cases_test.dart`)
- Offline sync panel when CDN not configured
- Large FTS search capped at `maxSearchResults`
- Accessibility: bottom nav labels, reader tooltips, streak semantics

### Unit Tests (utilities)
- `debouncer_test.dart` — search debounce coalescing

### Golden Tests (`test/golden/`)
Pixel snapshots for home (iPhone), topic tree (desktop), crusher (iPhone), onboarding (iPhone).

```bash
flutter test test/golden --update-goldens   # refresh PNGs after intentional UI changes
flutter test test/golden                    # verify against committed goldens
```

### Integration Tests (`integration_test/`)
- Full flow: home → tree → crush → library note (no sign-in)
- Desktop Venezuela claim deep-dive

## Test Harness

`test/test_helpers.dart` provides:
- `initTestEnvironment()` — Hive, FTS, preloaded knowledge bundle
- `pumpTestApp()` — full router + journey provider overrides
- `crushFromHomeHub()` — home crush bar → crusher with results
- `TestClaimRetrievalBackend` — in-memory retrieval (avoids sqflite fake-async stalls)
- Device sizes: `TestDevices.iphone14`, `ipadPortrait`, `ipadLandscape`, `desktop`

## Commands

```bash
flutter analyze
flutter test
flutter test test/user_journeys
flutter test test/edge_cases_test.dart
flutter test test/golden
flutter test integration_test/user_journeys_test.dart -d windows
```

## Performance Targets

- Tree navigation: 60fps spring animations (`RepaintBoundary` + reduced-motion fallback)
- Search: <200ms FTS with session query cache; debounced UI filters
- Cold start: <3s to interactive home (after onboarding)
- Library: per-book `rootBundle.loadString` — full corpus not loaded at startup
- Lists: `ListView.builder` / `SliverChildBuilderDelegate` for tree and library grids

## Accessibility Checklist (manual)

- [ ] VoiceOver / TalkBack: bottom nav and rail destinations announced
- [ ] Keyboard-only desktop: Ctrl+1–4 navigation, Ctrl+K focus search
- [ ] Reduced motion OS setting disables `SdFadeIn` and insight carousel timer
- [ ] Contrast: navy/gold palette meets AA on primary text pairs (`AppColors` docs)