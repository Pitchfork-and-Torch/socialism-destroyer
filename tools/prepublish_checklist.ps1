# Pre-publish checklist for Socialism Destroyer web + KB ships.
# Usage:
#   .\tools\prepublish_checklist.ps1
#   .\tools\prepublish_checklist.ps1 -SkipBuild
#   .\tools\prepublish_checklist.ps1 -SkipTests -SkipBuild
param(
  [switch]$SkipBuild,
  [switch]$SkipTests,
  [switch]$SkipFreshness
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

$flutter = if (Test-Path "C:\flutter\bin\flutter.bat") {
  "C:\flutter\bin\flutter.bat"
} elseif ($env:FLUTTER_ROOT) {
  Join-Path $env:FLUTTER_ROOT "bin\flutter.bat"
} else {
  "flutter"
}

function Step($name) {
  Write-Host ""
  Write-Host "==> $name" -ForegroundColor Cyan
}

$failed = @()

Step "Versions"
$pub = Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value }
$manifest = Get-Content "assets\data\v2\knowledge_manifest.json" -Raw | ConvertFrom-Json
$changelog = Get-Content "assets\data\changelog.json" -Raw | ConvertFrom-Json
Write-Host "App: $pub"
Write-Host "KB manifest: $($manifest.kbVersion) updated $($manifest.updatedAt)"
Write-Host "Changelog current: $($changelog.currentVersion) lastUpdated $($changelog.lastUpdated)"
if ($manifest.kbVersion -ne $changelog.currentVersion) {
  Write-Host "WARN: manifest kbVersion != changelog currentVersion" -ForegroundColor Yellow
  $failed += "kb-changelog-skew"
}

Step "Claim bundles exist"
foreach ($b in $manifest.claimBundles) {
  $p = $b.asset
  if (-not (Test-Path $p)) {
    Write-Host "MISSING: $p" -ForegroundColor Red
    $failed += "missing:$p"
  } else {
    $j = Get-Content $p -Raw | ConvertFrom-Json
    $n = if ($j.claims) { $j.claims.Count } else { "?" }
    Write-Host "OK $($b.id) claims=$n"
  }
}

Step "Orphan seeds"
$registered = $manifest.claimBundles | ForEach-Object { $_.asset -replace '\\', '/' }
Get-ChildItem "assets\data\v2\seeds\*.json" | ForEach-Object {
  $rel = "assets/data/v2/seeds/$($_.Name)"
  if ($registered -notcontains $rel) {
    Write-Host "ORPHAN: $rel" -ForegroundColor Yellow
    $failed += "orphan:$rel"
  }
}

Step "Source bar (>=2 sources on v2 seed claims; legacy seed may be thinner)"
Get-ChildItem "assets\data\v2\seeds\*.json" | ForEach-Object {
  $j = Get-Content $_.FullName -Raw | ConvertFrom-Json
  foreach ($c in $j.claims) {
    $sc = @($c.sources).Count
    if ($sc -lt 2) {
      Write-Host "UNDER-SOURCED ($sc): $($c.id) in $($_.Name)" -ForegroundColor Yellow
      $failed += "sources:$($c.id)"
    }
  }
}

Step "UTF-8 mojibake scan (web shell)"
$webFiles = @("web\index.html", "web\llms.txt") | Where-Object { Test-Path $_ }
foreach ($wf in $webFiles) {
  $raw = [System.IO.File]::ReadAllText((Join-Path $root $wf))
  if ($raw -match 'â€|Ã¶|Ã - |Â·| - | - ') {
    Write-Host "MOJIBAKE in $wf" -ForegroundColor Red
    $failed += "mojibake:$wf"
  } else {
    Write-Host "OK $wf"
  }
}

if (-not $SkipFreshness) {
  Step "Citation freshness (sample 40)"
  node (Join-Path $PSScriptRoot "check_citation_freshness.mjs") --limit 40
  if ($LASTEXITCODE -ne 0) {
    Write-Host "WARN: citation freshness reported failures (review tools/reports)" -ForegroundColor Yellow
    # non-fatal: external sites flake
  }
}

Step "Bump / rehash manifest"
node (Join-Path $PSScriptRoot "bump_kb_manifest.mjs")
if ($LASTEXITCODE -ne 0) { $failed += "bump_kb_manifest" }

Step "Flutter analyze"
& $flutter analyze --no-fatal-infos --no-fatal-warnings
if ($LASTEXITCODE -ne 0) { $failed += "analyze" }

if (-not $SkipTests) {
  Step "Flutter test"
  & $flutter test --reporter compact --concurrency=1
  if ($LASTEXITCODE -ne 0) { $failed += "test" }
}

if (-not $SkipBuild) {
  Step "Web release build (no deploy)"
  & $flutter build web --release --no-wasm-dry-run --no-web-resources-cdn
  if ($LASTEXITCODE -ne 0) { $failed += "build" }
}

Write-Host ""
if ($failed.Count -gt 0) {
  Write-Host "CHECKLIST ISSUES ($($failed.Count)):" -ForegroundColor Yellow
  $failed | ForEach-Object { Write-Host "  - $_" }
  exit 1
}

Write-Host "PREPUBLISH CHECKLIST PASS" -ForegroundColor Green
Write-Host "Deploy when ready: .\tools\publish-web.ps1"
exit 0
