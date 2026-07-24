# Contributing to Socialism Destroyer

## Ground rules

- **Truth-first** — claims need sources; steelman before rebut
- **No ad hominem** — evidence and incentives only
- Do **not** commit `.env`, secrets, personal paths, or publish tokens
- Keep offline-first behavior intact

## Dev setup

```bash
git clone https://github.com/Pitchfork-and-Torch/socialism-destroyer.git
cd socialism-destroyer
flutter pub get
cp .env.example .env
flutter test
flutter analyze
```

## Pull requests

1. One logical change per PR when possible  
2. `flutter analyze` clean for touched packages  
3. Tests for logic changes under `test/` or `integration_test/`  
4. Content/claim PRs: follow `docs/ADDING-CLAIMS.md`  

## Code style

- Flutter/Dart with project `analysis_options.yaml`  
- Prefer local Hive storage over new network calls  
- Web publish uses `tools/publish-web.ps1` and `.env.web.publish` (no secrets)
