# BRIDGE 5

A complete single-file pseudo-3D mobile-style lane shooter. The entire game — engine, rendering, sound, save system — lives in one HTML file. No build step, no internet, no external assets. Double-click to play.

**🎮 Play it:** [real-war-shoot.web.app](https://real-war-shoot.web.app)
**📦 Repo:** [github.com/sunsetsarge/shoooooooooot](https://github.com/sunsetsarge/shoooooooooot)

## Features

- **3 difficulty modes** — Easy / Normal / Hard, selectable from the main menu (multiplier on enemy density and damage)
- **4 game modes** — Stage (boss progression), Endless, Army Builder (troop-count-as-HP with +N / −N gates), Hero (XP + skill cards)
- **8 weapon tiers** — Pistol → SMG → Assault Rifle → Shotgun → Sniper → Flamethrower → Minigun → Tesla Cannon
- **Contra-style stackable mods** — Power, Rapid Fire, Spread Shot, Incendiary, Poison, Explosive rounds — plus a per-weapon ⭐ unique upgrade (Akimbo, Railgun, Napalm, Overcharge, etc.)
- **Pseudo-3D camera** — bridge-over-sea with vanishing-point road, enemies scale up over the horizon
- **Meta progression** — coins persist between runs, spent in the Armory on 7 permanent perks (toggleable on/off) + 3 coin multipliers
- **Mobile-first** — touch drag uses relative movement (finger never blocks the action), 44pt tap targets, landscape orientation overlay, scales cleanly down to 360px viewports
- **Performance scaling** — Low / Medium / High / Ultra presets plus individual toggles (resolution, particles, FPS cap, shake, glow, damage numbers)
- **Single-file, offline, zero dependencies** — runs from `file://`, ~80 KB total

## Files

| File | Purpose |
| --- | --- |
| `real-war-shooter.html` | The entire game — open this to play |
| `tools/deploy.ps1` | One-shot deploy: syntax-check → `firebase deploy` → `git push` |
| `firebase.json` | Firebase Hosting config (serves `/` → `real-war-shooter.html`) |

## Hosting & deploy

This repo deploys to Firebase Hosting at [real-war-shoot.web.app](https://real-war-shoot.web.app).

```powershell
# one-shot deploy + commit + push
.\tools\deploy.ps1 -Message "tune balance"
```

## Inspiration

- The "fake mobile game ad" subgenre — bridge-running squad shooters with +N / −N gates, destructible barrels containing weapon upgrades, and a steady stream of barrel-numbered obstacles
- *Contra* (1987) for the stackable weapon-modifier system
- [The Greatest Developer's YouTube essay on the genre](https://www.youtube.com/watch?v=JgGa2pdUM7s)

## License

See [LICENSE](LICENSE). MIT.
