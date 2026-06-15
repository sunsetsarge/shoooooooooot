#requires -Version 5
<#
.SYNOPSIS
  Build the Tiny Swords sprite atlas and inject it into real-war-shooter.html.

.DESCRIPTION
  Crops animation frames from the Tiny Swords pack into a 768x768 96px-grid
  atlas (atlas.png), then base64-encodes it and injects it into the game HTML
  by replacing either the current data:image/png;base64 src or the
  __SPRITE_ATLAS__ placeholder.

  Rows of the atlas:
    0  Blue Warrior run (squad)         + rock1 + rock2 (decorations)
    1  Blue Archer shoot (hero)         + arrow
    2  Red Warrior run                  (grunt)
    3  Red Pawn run w/ knife            (runner)
    4  Purple Warrior run               (brute)
    5  Yellow Warrior run               (husk)
    6  Explosion frames                 (FX)
    7  Black Warrior run                (boss)

.PARAMETER SourceDir
  Path to the unzipped "Tiny Swords (Free Pack)" folder.
  Default: C:\Users\blain\Desktop\Shooooooot\Tiny Swords (Free Pack)

.PARAMETER OutDir
  Project root containing real-war-shooter.html. Default: script's parent folder.

.EXAMPLE
  .\tools\build-atlas.ps1
  .\tools\build-atlas.ps1 -SourceDir "D:\Assets\Tiny Swords (Free Pack)"
#>
param(
  [string]$SourceDir = "C:\Users\blain\Desktop\Shooooooot\Tiny Swords (Free Pack)",
  [string]$OutDir    = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $SourceDir)) {
  Write-Error "Source dir not found: $SourceDir"
}
$gameFile = Join-Path $OutDir 'real-war-shooter.html'
if (-not (Test-Path $gameFile)) {
  Write-Error "Game file not found: $gameFile"
}

$cell  = 96
$atlas = New-Object System.Drawing.Bitmap(768, 768)
$gx    = [System.Drawing.Graphics]::FromImage($atlas)
$gx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

function DrawCells {
  param($File, $FrameW, $Frames, $CropX, $CropY, $CropS, $Row, $Col0)
  $img = [System.Drawing.Bitmap]::FromFile($File)
  try {
    for ($i = 0; $i -lt $Frames.Count; $i++) {
      $f   = $Frames[$i]
      $src = New-Object System.Drawing.Rectangle (($f * $FrameW + $CropX)), $CropY, $CropS, $CropS
      $dst = New-Object System.Drawing.Rectangle (($Col0 + $i) * $cell), ($Row * $cell), $cell, $cell
      $gx.DrawImage($img, $dst, $src, [System.Drawing.GraphicsUnit]::Pixel)
    }
  } finally { $img.Dispose() }
}

$frames = @(0, 1, 2, 3, 4, 5)
DrawCells "$SourceDir\Units\Blue Units\Warrior\Warrior_Run.png"  192 $frames 32 28 128 0 0
DrawCells "$SourceDir\Terrain\Decorations\Rocks\Rock2.png"        64 @(0)     0  0  64 0 6
DrawCells "$SourceDir\Terrain\Decorations\Rocks\Rock3.png"        64 @(0)     0  0  64 0 7
DrawCells "$SourceDir\Units\Blue Units\Archer\Archer_Shoot.png"  192 $frames 32 28 128 1 0
DrawCells "$SourceDir\Units\Blue Units\Archer\Arrow.png"          64 @(0)     0  0  64 1 6
DrawCells "$SourceDir\Units\Red Units\Warrior\Warrior_Run.png"   192 $frames 32 28 128 2 0
DrawCells "$SourceDir\Units\Red Units\Pawn\Pawn_Run Knife.png"   192 $frames 32 28 128 3 0
DrawCells "$SourceDir\Units\Purple Units\Warrior\Warrior_Run.png" 192 $frames 32 28 128 4 0
DrawCells "$SourceDir\Units\Yellow Units\Warrior\Warrior_Run.png" 192 $frames 32 28 128 5 0
DrawCells "$SourceDir\Particle FX\Explosion_02.png"              192 @(0,2,4,6,8,9) 16 16 160 6 0
DrawCells "$SourceDir\Units\Black Units\Warrior\Warrior_Run.png" 192 $frames 32 28 128 7 0

$gx.Dispose()
$atlasPath = Join-Path $OutDir 'atlas.png'
$atlas.Save($atlasPath, [System.Drawing.Imaging.ImageFormat]::Png)
$atlas.Dispose()

$bytes = [IO.File]::ReadAllBytes($atlasPath)
$b64   = 'data:image/png;base64,' + [Convert]::ToBase64String($bytes)
Write-Host ("Atlas built: {0} bytes; base64 {1} chars" -f $bytes.Length, $b64.Length)

# Inject into the HTML — supports both the placeholder (first run) and the
# previously-injected data URI (subsequent runs).
$html = [IO.File]::ReadAllText($gameFile)
if ($html -match '__SPRITE_ATLAS__') {
  $html = $html.Replace('__SPRITE_ATLAS__', $b64)
} else {
  $html = [regex]::Replace($html, "const SPRITE_B64='data:image/png;base64,[^']+';", "const SPRITE_B64='$b64';")
}
[IO.File]::WriteAllText($gameFile, $html, (New-Object Text.UTF8Encoding $false))
Write-Host ("Injected into {0} ({1:N0} KB)" -f $gameFile, ((Get-Item $gameFile).Length / 1KB))
