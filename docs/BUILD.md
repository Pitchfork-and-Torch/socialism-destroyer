# Build Guide — All Platforms

## Prerequisites by Target

| Platform | Requirements |
|----------|--------------|
| **Windows .exe** | Visual Studio 2022+ with "Desktop development with C++", Windows Developer Mode (symlinks) |
| **Android** | Android Studio, SDK 34+, JDK 17 |
| **iOS / iPadOS** | macOS, Xcode 15+, Apple Developer account (Sign in with Apple) |
| **macOS** | macOS, Xcode, entitlements in `macos/Runner/*.entitlements` |
| **Linux** | `clang`, `cmake`, `ninja-build`, `pkg-config`, GTK dev libs |
| **Web PWA** | Chrome or Edge; build with `--no-wasm-dry-run` if wasm dry-run crashes on Windows |

## Commands

```bash
flutter pub get
flutter analyze
flutter test

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release

# Mobile
flutter build apk --release
flutter build ios --release   # macOS only

# Web PWA
flutter build web --release --no-wasm-dry-run
```

## Environment

Copy `.env.example` → `.env`. For web publish, `tools/publish-web.ps1` swaps in `.env.web.publish` (no secrets).

## Known Windows Dev Setup

1. Enable **Developer Mode**: `start ms-settings:developers`
2. Install **Visual Studio** with C++ desktop workload
3. Install **Android Studio** for mobile builds

Output artifacts:
- Windows: `build/windows/x64/runner/Release/socialism_destroyer.exe`
- Web: `build/web/`
- Android: `build/app/outputs/flutter-apk/app-release.apk`

## Branding assets

After editing masters in `assets/images/branding/`:

```bash
py tools/prepare_branding_assets.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Distribution

See [DISTRIBUTION.md](DISTRIBUTION.md) for TestFlight, Play Store, and signed `.exe` checklists.