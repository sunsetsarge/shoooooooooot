# REAL WAR (Not Fake)

A complete single-file pseudo-3D lane shooter inspired by the "fake mobile game ad" subgenre. The entire game — engine, rendering, sound, sprite atlas, save system — lives in one HTML file. No build step, no internet, no external assets. Double-click to play.

**Play it:** open `real-war-shooter.html` in any modern browser, or visit the hosted version (see below).

## Features

- **4 game modes** — Stage (boss progression), Endless, Army Builder (troop-count-as-HP with +N / −N gates), Hero (XP + skill cards)
- **8 weapon tiers** — Pistol → SMG → Assault Rifle → Shotgun → Sniper → Flamethrower → Minigun → Tesla Cannon
- **Contra-style stackable mods** — Power, Rapid Fire, Spread Shot, Incendiary, Poison, Explosive rounds — plus a per-weapon ⭐ unique upgrade (Akimbo, Railgun, Napalm, Overcharge, etc.)
- **Pseudo-3D camera** — bridge-over-sea with vanishing-point road, enemies scale up over the horizon, perspective-projected sprites
- **Meta progression** — coins persist between runs, spent in the Armory on 7 permanent perks (toggleable on/off) + 3 coin multipliers
- **Performance scaling** — Low / Medium / High / Ultra presets plus individual toggles (resolution scale, particle density, FPS cap, shake, glow, damage numbers, sprite atlas vs. vector fallback)
- **Single-file, offline, zero dependencies** — runs from `file://`, works on phones, ~450 KB total including the base64-embedded sprite atlas

## Files

| File | Purpose |
| --- | --- |
| `real-war-shooter.html` | The entire game — open this to play |
| `atlas.png` | Build artifact — sprite atlas (already embedded in the HTML, kept for re-injection workflow) |
| `tools/build-atlas.ps1` | Atlas builder — re-packs frames from a Tiny Swords source folder into the HTML |
| `tools/deploy.ps1` | One-shot deploy: copies game → builds → `firebase deploy` → `git push` |
| `firebase.json` | Firebase Hosting config (serves `/` → `real-war-shooter.html`) |

## Hosting

This repo deploys to Firebase Hosting. The `firebase.json` rewrites `/` to `/real-war-shooter.html` so the bare site URL plays the game.

```powershell
# one-shot deploy + commit + push
.\tools\deploy.ps1 -Message "tune balance"
```

## Art credit

Sprites from **Tiny Swords** by [Pixel Frog](https://pixelfrog-assets.itch.io/tiny-swords). Free for personal and commercial use; redistribution of raw assets not allowed. The atlas embedded here is built from cropped/downscaled frames packed for this game (not the raw pack) — see `tools/build-atlas.ps1` for the build steps.

If you want to rebuild the atlas with different units, download the Tiny Swords pack and point the build script at it:

```powershell
.\tools\build-atlas.ps1 -SourceDir "C:\path\to\Tiny Swords (Free Pack)"
```

## Inspiration

- The "fake mobile game ad" subgenre — bridge-running squad shooters with +N / −N gates, destructible barrels containing weapon upgrades, and a steady stream of barrel-numbered obstacles
- *Contra* (1987) for the stackable weapon-modifier system
- [The Greatest Developer's YouTube essay on the genre](https://www.youtube.com/watch?v=JgGa2pdUM7s)

## License

Game code: see [LICENSE](LICENSE). Art assets are © Pixel Frog under their [Tiny Swords license](https://pixelfrog-assets.itch.io/tiny-swords) and are not covered by the code license.
