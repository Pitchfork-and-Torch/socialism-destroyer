# Perpetual library heartbeat — verify, repair failures, discover gaps, snapshot cache.
# Schedule via Task Scheduler (weekly) or run manually after editing library_sources.json.
#
# Usage:
#   .\tools\run_library_heartbeat.ps1
#   .\tools\run_library_heartbeat.ps1 -ForceAll
#   .\tools\run_library_heartbeat.ps1 -Commit

param(
    [switch]$ForceAll,
    [switch]$Commit
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    $args = @('tools/library_pipeline.py', 'heartbeat')
    if ($ForceAll) { $args += '--force-all' }

    Write-Host '==> library heartbeat' -ForegroundColor Cyan
    & py -3 @args
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Library heartbeat FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    if ($Commit) {
        $status = git status --porcelain assets/data/books assets/data/v2/library_run_state.json assets/data/v2/books.json 2>$null
        if ($status) {
            git add assets/data/books assets/data/v2/library_run_state.json assets/data/v2/books.json
            git commit -m "chore(library): heartbeat $(Get-Date -Format 'yyyy-MM-dd')"
            Write-Host 'Committed library heartbeat changes.' -ForegroundColor Green
        } else {
            Write-Host 'No library changes to commit.' -ForegroundColor DarkGray
        }
    }

    exit 0
}
finally {
    Pop-Location
}