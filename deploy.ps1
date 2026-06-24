#requires -version 5
<#
  Deploy the latest Godot Web export to Vercel production.

  Usage:  .\deploy.ps1            # sync + deploy to production
          .\deploy.ps1 -Preview   # sync + deploy to a preview URL instead

  Steps:
    1. Mirror the Godot Web export (..\underroot\build\Web) into .\game\
    2. Run `vercel deploy` (--prod unless -Preview)

  The build is gitignored on purpose; this ships it straight to Vercel.
#>
param(
    [switch]$Preview
)

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$src  = Join-Path $repo '..\underroot\build\Web'
$dst  = Join-Path $repo 'game'

if (-not (Test-Path (Join-Path $src 'index.pck'))) {
    throw "No export found at '$src'. Run a Godot Web export first (Project > Export > Web -> build/Web)."
}

Write-Host "Syncing build/Web -> game/ ..." -ForegroundColor Cyan
if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
New-Item -ItemType Directory -Path $dst | Out-Null
Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force

$pck = Get-Item (Join-Path $dst 'index.pck')
Write-Host ("  game/index.pck  {0:N1} MB  (exported {1:HH:mm})" -f ($pck.Length / 1MB), $pck.LastWriteTime) -ForegroundColor Green

if ($Preview) {
    Write-Host "Deploying to a PREVIEW url ..." -ForegroundColor Cyan
    vercel deploy --yes
} else {
    Write-Host "Deploying to PRODUCTION (testing.underroot.se) ..." -ForegroundColor Cyan
    vercel deploy --prod --yes
}
