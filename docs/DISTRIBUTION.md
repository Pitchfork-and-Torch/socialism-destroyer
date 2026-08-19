# Distribution Readiness

Socialism Destroyer is prepared for continued content expansion and multi-channel distribution.

## Repository status

| Check | Status |
|-------|--------|
| GitHub repo | `Pitchfork-and-Torch/socialism-destroyer` |
| Flutter analyze clean | Run `flutter analyze` before each release |
| Test suite | `flutter test` — widget, golden, journey, edge-case |
| Branding | Navy/gold icon + native splash on all platforms |
| Offline knowledge v2 | Bundled manifest + seeds + FTS index |
| Web | Free, no sign-in — deploy `build/web/` to Cloudflare Pages |
| Auth | Web ships without sign-in; all progress stays local (Hive) |
| Build docs | [BUILD.md](BUILD.md) |

## Release artifacts

| Channel | Command | Output |
|---------|---------|--------|
| **Windows .exe** | `flutter build windows --release` | `build/windows/x64/runner/Release/socialism_destroyer.exe` |
| **Android APK** | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| **iOS / TestFlight** | `flutter build ipa` (macOS + Xcode) | Archive via Xcode → TestFlight |
| **macOS** | `flutter build macos --release` | `build/macos/Build/Products/Release/` |
| **Web PWA** | `flutter build web --release --no-wasm-dry-run` | `build/web/` |

## Store submission

Full metadata, privacy labels, screenshot list, and review notes: **[STORE-SUBMISSION.md](STORE-SUBMISSION.md)**.

## Pre-flight checklist

### All platforms

- [ ] `flutter pub get && flutter analyze && flutter test`
- [ ] Bump `version` in `pubspec.yaml`
- [ ] Update `assets/data/changelog.json`
- [ ] Regenerate seeds if claims changed: `node tools/generate_claims_seed.mjs`
- [ ] Citation freshness sample: `node tools/check_citation_freshness.mjs --limit 40`
- [ ] Regenerate sitemap: `node tools/generate-sitemap.mjs`
- [ ] Publish knowledge overlay if CDN configured: `tools/publish_knowledge.ps1`

### iOS / TestFlight

- [ ] Apple Developer account + App ID with Sign in with Apple capability
- [ ] Configure `ios/Runner` signing team in Xcode
- [ ] Privacy manifest / App Store metadata (truth-first reference app positioning)
- [ ] Upload build: Xcode Organizer or `xcrun altool`

### Google Play

- [ ] Play Console app + signing key
- [ ] `android/app/build.gradle.kts` `applicationId` matches OAuth redirect
- [ ] Content rating questionnaire (education / reference)

### Windows direct .exe

- [ ] Enable Developer Mode for plugin symlinks during dev
- [ ] Optional: MSIX packaging for Microsoft Store (`flutter pub run msix:create`)
- [ ] Code-sign executable for SmartScreen trust

### Web

- [ ] Deploy `build/web/` to static host (Cloudflare Pages, etc.)
- [ ] Set `KNOWLEDGE_CDN_URL` for delta sync in production

## Environment for production

Copy `.env.example` → `.env` (never commit `.env`):

| Variable | Production use |
|----------|------------------|
| `KNOWLEDGE_CDN_URL` | Quarterly content drops (required for web delta sync) |
| `OPENAI_API_KEY` | Optional Crusher LLM overlay |

## Content expansion pipeline

See [content-pipeline.md](content-pipeline.md) for seeding v2 claims, manifest bumps, and CDN publish workflow.

## Support matrix

| Platform | Min target | Notes |
|----------|------------|-------|
| iOS / iPadOS | 13+ | Split-view on iPad |
| Android | API 24+ | Adaptive icon + Android 12 splash |
| Windows | 10+ | Keyboard shortcuts (Ctrl+1–4, Ctrl+K) |
| macOS | 11+ | Native icon set |
| Web | Modern Chromium | PWA manifest + maskable icons |