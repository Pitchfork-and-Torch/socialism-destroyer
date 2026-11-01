# Remove wrong-ID Gutenberg downloads; keep verified raw sources for strip_gutenberg.py
$ErrorActionPreference = "Stop"
$raw = Join-Path (Split-Path $PSScriptRoot -Parent) "assets\data\books\_gutenberg_raw"

$remove = @(
    "acton-liberty.txt",      # was Gutenberg #369 (Outlaw of Torn)
    "orwell-animal-farm.txt", # was Gutenberg #2852 (Hound of the Baskervilles)
    "shaw-socialism.txt",     # was Gutenberg #3321 (Children of the Whirlwind)
    "acton-lectures.txt",     # redundant; acton-essays.txt is the curated source
    "bakunin-god-state.txt"   # duplicate of bakunin-god.txt
)

foreach ($name in $remove) {
    $path = Join-Path $raw $name
    if (Test-Path $path) {
        Remove-Item $path -Force
        Write-Host "Removed $name"
    }
}

Write-Host "Gutenberg raw cleanup done. Remaining:"
Get-ChildItem $raw -File | Select-Object Name, Length | Format-Table -AutoSize