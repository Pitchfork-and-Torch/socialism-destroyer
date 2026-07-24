param(
    [Parameter(Mandatory = $true)]
    [string]$CdnRoot,

    [string]$KbVersion = "2.3.0",

    [string]$ProjectRoot = $(if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { (Get-Location).Path }),

    [switch]$SkipBundledManifestUpdate
)

$ErrorActionPreference = "Stop"
$assetsRoot = Join-Path $ProjectRoot "assets"
$dataRoot = Join-Path $assetsRoot "data"
$destRoot = Join-Path $CdnRoot "data"
$manifestPath = Join-Path $dataRoot "v2\knowledge_manifest.json"

function Get-Sha256Hex([string]$Path) {
    $hash = Get-FileHash -Path $Path -Algorithm SHA256
    return "sha256:$($hash.Hash.ToLower())"
}

function Write-JsonFile([string]$Path, $Object) {
    # Depth 20; Compress removes extra whitespace PowerShell adds after colons.
    $json = ($Object | ConvertTo-Json -Depth 20 -Compress)
    $pretty = ($json | ConvertFrom-Json | ConvertTo-Json -Depth 20)
    [System.IO.File]::WriteAllText($Path, $pretty + "`n")
}

if (-not (Test-Path $manifestPath)) {
    throw "Manifest not found: $manifestPath"
}

Write-Host "Publishing knowledge base v$KbVersion to $destRoot"

# Bump bundled manifest kbVersion/timestamp in-place (preserve JSON formatting).
if (-not $SkipBundledManifestUpdate) {
    $raw = Get-Content $manifestPath -Raw
    $raw = $raw -replace '"kbVersion"\s*:\s*"[^"]*"', "`"kbVersion`": `"$KbVersion`""
    $updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $raw = $raw -replace '"updatedAt"\s*:\s*"[^"]*"', "`"updatedAt`": `"$updatedAt`""
    [System.IO.File]::WriteAllText($manifestPath, $raw.TrimEnd() + "`n")
    Write-Host "Bundled manifest kbVersion -> $KbVersion"
}

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null
Copy-Item -Path (Join-Path $dataRoot "*") -Destination $destRoot -Recurse -Force

$jsonFiles = Get-ChildItem -Path $destRoot -Recurse -Filter "*.json"
foreach ($file in $jsonFiles) {
    if ($file.Name -eq "knowledge_manifest.json") { continue }
    $hash = Get-Sha256Hex $file.FullName
    Set-Content -Path "$($file.FullName).sha256" -Value $hash -NoNewline
    Write-Host "  hash $($file.Name) -> $hash"
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$manifest.kbVersion = $KbVersion
$manifest.updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$manifestOut = Join-Path $destRoot "v2\knowledge_manifest.json"
Write-JsonFile $manifestOut $manifest

$manifestHash = Get-Sha256Hex $manifestOut
$manifest.contentHash = $manifestHash
Write-JsonFile $manifestOut $manifest

if (-not $SkipBundledManifestUpdate) {
    $raw = Get-Content $manifestPath -Raw
    $raw = $raw -replace '"contentHash"\s*:\s*"[^"]*"', "`"contentHash`": `"$manifestHash`""
    [System.IO.File]::WriteAllText($manifestPath, $raw.TrimEnd() + "`n")
}

Write-Host "Manifest -> $manifestOut ($manifestHash)"
Write-Host "Done. Serve locally: .\tools\serve_knowledge_cdn.ps1 -CdnRoot '$CdnRoot'"
Write-Host "Upload $CdnRoot to your production CDN bucket root."