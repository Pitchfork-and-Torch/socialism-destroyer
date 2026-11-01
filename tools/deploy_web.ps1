param(
    [switch]$SkipBuild,

    [switch]$Serve,

    [int]$Port = 8765,

    [string]$ProjectRoot = $(if ($PSScriptRoot) { Split-Path $PSScriptRoot -Parent } else { (Get-Location).Path })
)

$ErrorActionPreference = "Stop"
$flutter = if ($env:FLUTTER_ROOT) { Join-Path $env:FLUTTER_ROOT "bin\flutter.bat" } else { "C:\flutter\bin\flutter.bat" }

Push-Location $ProjectRoot
try {
    if (-not $SkipBuild) {
        Write-Host "==> flutter build web --release" -ForegroundColor Cyan
        & $flutter build web --release --no-wasm-dry-run
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    $webRoot = Join-Path $ProjectRoot "build\web"
    if (-not (Test-Path (Join-Path $webRoot "index.html"))) {
        throw "build/web not found. Run without -SkipBuild first."
    }

    Write-Host "Web build ready: $webRoot" -ForegroundColor Green

    if ($Serve) {
        Write-Host "Serving at http://localhost:$Port (Ctrl+C to stop)" -ForegroundColor Cyan
        Set-Location $webRoot
        py -m http.server $Port
    } else {
        Write-Host ""
        Write-Host "Deploy options:"
        Write-Host "  Preview:  .\tools\deploy_web.ps1 -Serve -SkipBuild"
        Write-Host "  Cloudflare Pages:"
        Write-Host "    cmd /c `"npx wrangler@latest pages deploy build\web --project-name socialism-destroyer --branch main`""
        Write-Host "  Live: https://destroyer.jonbailey.xyz"
        Write-Host "  Any static host: upload contents of build/web/"
    }
}
finally {
    Pop-Location
}