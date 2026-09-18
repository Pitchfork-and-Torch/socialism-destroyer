# Socialism Destroyer — local CI verify (analyze + test)
# Usage: .\tools\verify.ps1
# Exits non-zero only on analyzer errors or test failures (info lints are non-fatal).

$ErrorActionPreference = 'Stop'
$flutter = if ($env:FLUTTER_ROOT) { Join-Path $env:FLUTTER_ROOT 'bin\flutter.bat' } else { 'flutter' }

Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    Write-Host '==> library verify (full texts)' -ForegroundColor Cyan
    & py -3 tools/library_pipeline.py verify
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> flutter analyze (errors only)' -ForegroundColor Cyan
    & $flutter analyze --no-fatal-infos --no-fatal-warnings
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> flutter test' -ForegroundColor Cyan
    & $flutter test
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}