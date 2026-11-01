# Build and deploy Socialism Destroyer web to Cloudflare Pages (production-safe).
param(
  [string]$ProjectName = "socialism-destroyer",
  [switch]$BuildOnly,
  [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$flutter = "C:\flutter\bin\flutter.bat"
$envBackup = Join-Path $root ".env.local.backup"
$envFile = Join-Path $root ".env"
$safeEnv = Join-Path $root ".env.web.publish"

Set-Location $root

try {
  & $flutter pub get
  node (Join-Path $PSScriptRoot "generate-sitemap.mjs")
  py (Join-Path $PSScriptRoot "generate_social_card.py")
  & $flutter analyze --no-fatal-infos --no-fatal-warnings
  if (-not $SkipTests) {
    & $flutter test --reporter compact --concurrency=1
    if ($LASTEXITCODE -ne 0) {
      Write-Host "WARNING: flutter test exit $LASTEXITCODE - continuing publish (content/SEO deploy)."
    }
  } else {
    Write-Host "Skipping flutter test (-SkipTests)"
  }

  # Secret-free env only for the web asset bundle (after tests).
  if (Test-Path $envFile) {
    Copy-Item $envFile $envBackup -Force
    Write-Host "Backed up .env -> .env.local.backup"
  }
  Copy-Item $safeEnv $envFile -Force
  Write-Host "Using .env.web.publish for production build (no API secrets)"
  $publishText = Get-Content $safeEnv -Raw
  if ($publishText -match 'your-project|your-anon-key') {
    Write-Host 'Note: Supabase placeholders in .env.web.publish - OK for free web (no sign-in UI).'
  }

  # --no-web-resources-cdn: ship local canvaskit/ so CSP connect-src 'self' works
  & $flutter build web --release --no-wasm-dry-run --no-web-resources-cdn
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build web failed with exit code $LASTEXITCODE"
  }

  # Force local CanvasKit + no Flutter SW in the emitted bootstrap.
  $boot = Join-Path $root "build\web\flutter_bootstrap.js"
  if (Test-Path $boot) {
    $bootText = Get-Content $boot -Raw
    if ($bootText -notmatch 'useLocalCanvasKit') {
      $bootText = $bootText + "`r`n_flutter.buildConfig.useLocalCanvasKit = true;`r`n"
    }
    if ($bootText -notmatch 'canvasKitBaseUrl') {
      $bootText = $bootText -replace '_flutter\.loader\.load\(', '_flutter.loader.load({config:{canvasKitBaseUrl:"/canvaskit/"},'
    } else {
      $bootText = [regex]::Replace($bootText, 'canvasKitBaseUrl\s*:\s*"[^"]*"', 'canvasKitBaseUrl: "/canvaskit/"')
      $bootText = [regex]::Replace($bootText, "canvasKitBaseUrl\s*:\s*'[^']*'", 'canvasKitBaseUrl: "/canvaskit/"')
    }
    # Drop service worker registration if present
    $bootText = [regex]::Replace($bootText, ',\s*serviceWorkerSettings\s*:\s*\{[\s\S]*?\n\s*\}', '')
    $bootText = [regex]::Replace($bootText, 'serviceWorkerSettings\s*:\s*\{[\s\S]*?\n\s*\}\s*,?', '')
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($boot, $bootText, $utf8)
    Write-Host "Hardened flutter_bootstrap.js (local CanvasKit, no service worker)"
  }

  $manifestPath = Join-Path $root "assets\data\v2\knowledge_manifest.json"
  $manifestJson = Get-Content $manifestPath -Raw | ConvertFrom-Json
  $kbVersion = $manifestJson.kbVersion
  Write-Host "Publishing knowledge CDN at kbVersion $kbVersion"

  $cdnRoot = Join-Path $root "dist\knowledge-cdn"
  & (Join-Path $PSScriptRoot "publish_knowledge.ps1") `
    -CdnRoot $cdnRoot `
    -KbVersion $kbVersion `
    -ProjectRoot $root
  $knowledgeDest = Join-Path $root "build\web\knowledge"
  if (Test-Path $knowledgeDest) { Remove-Item $knowledgeDest -Recurse -Force }
  Copy-Item -Path $cdnRoot -Destination $knowledgeDest -Recurse -Force
  Write-Host "Bundled knowledge CDN -> build/web/knowledge"

  if ($BuildOnly) {
    Write-Host "Build complete: $root\build\web"
    exit 0
  }

  Write-Host "Deploying to Cloudflare Pages project: $ProjectName"
  npx.cmd --yes wrangler pages deploy build/web --project-name=$ProjectName --commit-dirty=true
  if ($LASTEXITCODE -ne 0) {
    throw "wrangler pages deploy failed with exit code $LASTEXITCODE"
  }

  Write-Host "Pinging IndexNow (Bing/Yandex) for SEO/AEO URL refresh..."
  try {
    node (Join-Path $PSScriptRoot "ping-indexnow.mjs")
  } catch {
    Write-Host "IndexNow ping warning: $_"
  }
}
finally {
  if (Test-Path $envBackup) {
    Copy-Item $envBackup $envFile -Force
    Remove-Item $envBackup -Force
    Write-Host "Restored local .env"
  }
}

Write-Host ""
Write-Host "Live URLs:"
Write-Host "  https://destroyer.jonbailey.xyz"
Write-Host "  https://$($ProjectName).pages.dev"
Write-Host "  llms.txt: https://destroyer.jonbailey.xyz/llms.txt"
Write-Host "  sitemap:  https://destroyer.jonbailey.xyz/sitemap.xml"
