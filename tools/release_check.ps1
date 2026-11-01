# Full release gate: analyze, test, publish CDN bundle, build web.
# Usage: .\tools\release_check.ps1

$ErrorActionPreference = "Stop"
$root = if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { (Get-Location).Path }
$flutter = if ($env:FLUTTER_ROOT) { Join-Path $env:FLUTTER_ROOT "bin\flutter.bat" } else { "C:\flutter\bin\flutter.bat" }
$cdnRoot = Join-Path $root "dist\knowledge-cdn"

Push-Location $root
try {
    Write-Host "==> flutter analyze" -ForegroundColor Cyan
    & $flutter analyze --no-fatal-infos --no-fatal-warnings
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "==> flutter test" -ForegroundColor Cyan
    & $flutter test --reporter compact
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "==> publish knowledge CDN bundle" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot "publish_knowledge.ps1") -CdnRoot $cdnRoot -KbVersion "2.7.1" -ProjectRoot $root
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "==> flutter build web" -ForegroundColor Cyan
    & $flutter build web --release --no-wasm-dry-run
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host ""
    Write-Host "Release check passed." -ForegroundColor Green
    Write-Host "  CDN bundle: $cdnRoot"
    Write-Host "  Web build:  $(Join-Path $root 'build\web')"
    Write-Host "  Local CDN:  .\tools\serve_knowledge_cdn.ps1"
    Write-Host "  Local web:  .\tools\deploy_web.ps1 -Serve -SkipBuild"
}
finally {
    Pop-Location
}