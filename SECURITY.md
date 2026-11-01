# Security Policy

## Supported versions

Security fixes apply to the latest release on the `main` branch and the live web deployment.

## Reporting a vulnerability

Open a [GitHub issue](https://github.com/Pitchfork-and-Torch/socialism-destroyer/issues) for non-sensitive reports.

For sensitive findings, use [GitHub private vulnerability reporting](https://github.com/Pitchfork-and-Torch/socialism-destroyer/security/advisories/new) if enabled on the repository. Do not post exploit details publicly before a fix is available.

## Scope

- Flutter app (web, desktop, mobile targets)
- Bundled knowledge base and public-domain library assets
- Build and publish scripts under `tools/`

Out of scope: third-party hosting (Cloudflare Pages), external citation URLs in claim content, and optional API keys you configure locally in `.env`.

## Secrets

Never commit `.env`, API keys, tokens, or service-role credentials. Copy `.env.example` and keep secrets local.
`.env.web.publish` is a **public build template** for `tools/publish-web.ps1` (CDN URL + empty optional keys). It must never gain live secrets. If a key is ever pasted there, treat it as compromised: rotate immediately, scrub the file, and rewrite history if it was pushed.
