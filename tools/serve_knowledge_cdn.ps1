param(
    [string]$CdnRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) "dist\knowledge-cdn"),

    [int]$Port = 8780
)

$ErrorActionPreference = "Stop"
$manifest = Join-Path $CdnRoot "data\v2\knowledge_manifest.json"
if (-not (Test-Path $manifest)) {
    Write-Host "CDN bundle not found. Run publish first:" -ForegroundColor Yellow
    Write-Host "  .\tools\publish_knowledge.ps1 -CdnRoot '$CdnRoot' -KbVersion '2.3.0'"
    exit 1
}

Write-Host "Serving knowledge CDN at http://localhost:$Port" -ForegroundColor Cyan
Write-Host "Set in .env: KNOWLEDGE_CDN_URL=http://localhost:$Port"
Write-Host "Press Ctrl+C to stop."
Set-Location $CdnRoot
py -m http.server $Port