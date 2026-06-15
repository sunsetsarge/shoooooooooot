#requires -Version 5
<#
.SYNOPSIS
  One-shot deploy: firebase deploy + git commit + git push.

.DESCRIPTION
  Verifies the game file's HTML script block parses with Node, then deploys
  to Firebase Hosting and commits/pushes any working-tree changes to GitHub.
  The local copy, Firebase, and the GitHub repo all end up in sync.

.PARAMETER Message
  Git commit message. If omitted, a timestamped message is used.

.PARAMETER SkipFirebase
  Skip the firebase deploy step (just commit + push).

.PARAMETER SkipGit
  Skip the git commit + push (just deploy).

.EXAMPLE
  .\tools\deploy.ps1
  .\tools\deploy.ps1 -Message "tune stage 3 difficulty"
  .\tools\deploy.ps1 -SkipGit       # deploy only
#>
param(
  [string]$Message,
  [switch]$SkipFirebase,
  [switch]$SkipGit
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# ── 1. Syntax-check the HTML script block with Node ─────────────────────────
$gameFile = Join-Path $root 'real-war-shooter.html'
if (-not (Test-Path $gameFile)) { Write-Error "real-war-shooter.html missing" }
$html = [IO.File]::ReadAllText($gameFile)
$m = [regex]::Match($html, '(?s)<script>(.*)</script>')
if (-not $m.Success) { Write-Error "no <script> block found in $gameFile" }
$tmp = Join-Path $env:TEMP 'rw_check.js'
[IO.File]::WriteAllText($tmp, $m.Groups[1].Value, (New-Object Text.UTF8Encoding $false))
node --check $tmp
if ($LASTEXITCODE -ne 0) { Write-Error "Syntax check failed" }
Write-Host "Syntax OK ($([math]::Round((Get-Item $gameFile).Length / 1KB)) KB)" -ForegroundColor Green

# ── 2. Firebase deploy ──────────────────────────────────────────────────────
if (-not $SkipFirebase) {
  if (-not (Test-Path (Join-Path $root '.firebaserc'))) {
    Write-Warning ".firebaserc not found - run 'firebase use --add' once to pick the project"
  } else {
    Write-Host "Deploying to Firebase Hosting..." -ForegroundColor Cyan
    firebase deploy --only hosting
    if ($LASTEXITCODE -ne 0) { Write-Error "firebase deploy failed" }
  }
}

# ── 3. Git commit + push ────────────────────────────────────────────────────
if (-not $SkipGit) {
  if (-not (Test-Path (Join-Path $root '.git'))) {
    Write-Warning ".git not found - run 'git init' and add the remote first"
  } else {
    $status = (git status --porcelain)
    if ([string]::IsNullOrWhiteSpace($status)) {
      Write-Host "No git changes to commit." -ForegroundColor Yellow
    } else {
      if (-not $Message) {
        $Message = "deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
      }
      git add -A
      git commit -m $Message
      if ($LASTEXITCODE -ne 0) { Write-Error "git commit failed" }
      Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
      git push
      if ($LASTEXITCODE -ne 0) { Write-Error "git push failed" }
    }
  }
}

Write-Host "Done." -ForegroundColor Green
