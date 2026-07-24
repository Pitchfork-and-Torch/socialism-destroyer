# Serve socialism-destroyer web build locally for browser testing (not public).
param(
  [int]$Port = 8765,
  [switch]$Rebuild
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$webDir = Join-Path $root "build\web"
$flutter = "C:\flutter\bin\flutter.bat"

Set-Location $root

if ($Rebuild -or -not (Test-Path (Join-Path $webDir "main.dart.js"))) {
  Write-Host "Building web release..."
  & $flutter build web --release --no-wasm-dry-run
}

if (-not (Test-Path $webDir)) {
  throw "Missing $webDir — run: flutter build web --release --no-wasm-dry-run"
}

Write-Host ""
Write-Host "Socialism Destroyer — local web preview"
Write-Host "  URL:  http://127.0.0.1:$Port/"
Write-Host "  Root: $webDir"
Write-Host "  Stop: Ctrl+C"
Write-Host ""

Set-Location $webDir
py -m http.server $Port --bind 127.0.0.1