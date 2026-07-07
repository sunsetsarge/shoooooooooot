# PLAN.md — BRIDGE 5 Completion Plan

Snapshot: 2026-07-07. Companion to the Confluence page [BRIDGE 5 — Status, Completion Plan & Roadmap](https://blainecully.atlassian.net/wiki/spaces/cullyhouse/pages/66879511) (v4).

**Local:** `C:\Users\blain\OneDrive\Documents\Claude\Projects\RealWarShooter\real-war-shooter.html` (~92 KB)
**Live:** https://real-war-shoot.web.app
**Repo:** https://github.com/sunsetsarge/shoooooooooot
**Deploy:** `.\tools\deploy.ps1 -Message "..."` (syntax-check → firebase deploy → git push)

## Rules for executors

- **One phase per session; do not batch.** Each phase has explicit success criteria.
- After every phase run `.\tools\deploy.ps1 -Message "Phase X: <summary>"`. If deploy fails, do not proceed.
- **Never `git clean -fd`** — the untracked `.firebase/` cache is harmless.
- All content additions go through existing extension points in `real-war-shooter.html`: `Defs.WEAPONS`, `Defs.ENEMIES`, `Defs.PERKS`, `Defs.HERO_SKILLS`, `Modes.defs`, `Defs.CRATES`. Do **not** fork the render or update loops.
- Verification loop for every phase: `preview_start real-war-shooter` → `location.href='/real-war-shooter.html'` → run the phase's headless test → `node --check` on the extracted script block.
- Full context (feature ledger, gap analysis, research findings, monetization strategy) lives in the Confluence page.

## Blocking prerequisites (before Phase 1)

- [ ] OneDrive recycle-bin check for the six deleted filenames (5 min). Log finding in `Projects\PLANS\PLAN-data-loss-recovery.md`. This is the second time OneDrive has eaten this repo.
- [ ] Mirror the repo off OneDrive: `git clone https://github.com/sunsetsarge/shoooooooooot.git C:\Claude\Projects\Active\RealWarShooter`. That becomes the canonical working copy; the OneDrive copy is the redundant backup.

## Phases

### Phase 1 — Content string extraction + gate framework (S)

**Why first:** every later phase adds content. Extracting now = one small commit vs threading it through 10 phases.

- Extract every user-visible English string into a single `Defs.STRINGS = {...}` object placed right after `Defs.WEAPONS`. Menu labels, toasts, HUD suffixes, level-up card names, difficulty names, mode names. Keep raw English; do not rename to short keys.
- Restructure gate objects from `{l0, l1, z, val, acc, spd}` to `{l0, l1, z, spd, kind, val, acc, target}` where `kind ∈ {'add','mul','weapon','health','armor'}` and `target ∈ {'troops','weapon','hp','bridgeHp'}`. Add `Gate.apply(gt)` dispatching on `kind × target`. Existing +N/−N gates become `{kind:'add', target:'troops'}`.

**Success criteria (headless):** synthetic `{kind:'add', target:'troops', val:5}` gate applies on collision; no behavior change for existing gates.

### Phase 2 — Multiplier gates + shoot-to-buff (M) — UNFULFILLED USER REQUEST

- `{kind:'mul', target:'troops', val:2}` triples troops (cap 99); `val:0.5` halves.
- Shoot-to-buff: bullets hitting a gate modify `val`. `add` gates: ±1 per 30 dmg. `mul` gates: +0.5 per 60 dmg. Caps ±99 for add, ×10/÷10 for mul. Show pulse animation + delta text when hit.
- Gates in more modes: low-frequency spawns in Stage/Endless with `target:'weapon'` or `target:'hp'`. Bridge mode gets `target:'bridgeHp'`.
- Fork-path pairs: sometimes generate "bigger squad" one side, "better gun" the other.

**Success criteria:** Army mode troops=10 through ×2 gate → troops=20. Shooting a ×2 gate 60×3 dmg → reads ×3.5 → walking through → troops=35.

### Phase 3 — 4 new enemy types (M)

Rows for `Defs.ENEMIES`:

```js
tank:    {hp:280, spd:22, r:26, pts:60, dmg:30, coin:1.5, color:'#5a5a68', color2:'#2f2f38', armor:0.4}
sprinter:{hp:14,  spd:180,r:11, pts:20, dmg:9,  coin:.2,  color:'#e2c22a', color2:'#8a7112', dashChance:.02}
bomber:  {hp:36,  spd:44, r:15, pts:25, dmg:0,  coin:.3,  color:'#c43ba0', color2:'#7c1f66', explodeOnDeath:{r:60,dmg:35}}
shielder:{hp:80,  spd:40, r:18, pts:30, dmg:14, coin:.5,  color:'#3a80a0', color2:'#1c4a5c', shield:{hp:60,dir:'front'}}
```

Wire behaviors: `armor` scales incoming damage by `1 - armor` in `Combat.damageEnemy`; `dashChance` adds burst to `e.spd` for 0.5s; `explodeOnDeath` calls `Combat.explode` in `killEnemy`; `shield` blocks front hits until shield HP depleted, arc drawn in `Draw.enemy`.

**Success criteria:** 5-min Stage 5 headless run kills at least one of each new type.

### Phase 4 — Weapon expansion (M)

Extend `Defs.WEAPONS`:

```js
grenade: {name:'Grenade Launcher', ico:'💣', dmg:80,  rate:1.1, speed:420, range:400, arcs:true, explodeR:70, snd:'boom'}
laser:   {name:'Laser Rifle',      ico:'✨', dmg:22,  rate:8,   speed:1200, pierce:2, beam:true, snd:'sniper'}
rocket:  {name:'Rocket Pods',      ico:'🚀', dmg:35,  rate:2.4, speed:520, proj:2, homing:true, explodeR:45, snd:'boom'}
```

Insert into `Defs.WEAPON_ORDER` between Sniper and Flamethrower for progression pacing. Add corresponding `Defs.UNIQUES` entries.

**Success criteria:** Hero mode reaches Rocket Pods by level 10 (headless).

### Phase 5 — Meta progression depth (M)

Add 8 rows to `Defs.PERKS` bringing total to 15: `crit` (Sharpshooter, +4% crit/lvl, max 5), `lifest` (Blood Ration, 2%/lvl heal-on-kill, max 3), `magnet` (Coin Magnet, wider auto-pickup, max 3), `bridgeK` (Reinforced Bridge, +30 bridge HP/lvl, max 3), `gateSense` (Gate Whisperer, values 2s earlier, one-time), `archery` (Return Volley, 2%/lvl arrow-bounce, max 3), `combo` (Combo Master, consecutive-kill dmg stack, max 5), `startCash` (Bank Ties, +50 start coins/lvl, max 3).

Wire each in `Perks.active(id)` and gate the effect at its site. For `combo`, add `P.comboStack` and `P.comboT` to player state, reset on any hurt.

**Success criteria:** Armory shows 15 perks total; each has a working buy/toggle path.

### Phase 6 — Level design layer (L)

Add `Defs.STAGE_SCRIPTS = {}` keyed by stage number. Each script is an ordered array of `{t: seconds, event: 'spawn'|'wave'|'gate'|'blocker'|'boss'|'message', ...args}`. Stage mode's `update` fires scripted events as time passes.

Ship 10 hand-designed stages:
1. 30s tutorial pace: first archer @ t=15, blocker @ t=25, weapon gate @ t=20, boss @ t=40
2. Laned; introduces multiplier gates
3. Open; brute rush @ t=20 forces first Kevlar purchase
4. Bridge-carry section (30s Bridge Carry rules), scripted "bridge dropped" reverts to Stage rules
5. — 10: progressively wider mix
- After Stage 10: procedural forever ("endless-stage" mode)

Each stage's `Defs.STAGE_SCRIPTS[N].intro` provides one toast: "STAGE 3 — CROSS THE MARSH".

**Success criteria:** Each of stages 1–10 has a distinct scripted event log recorded in headless play.

### Phase 7 — Onboarding + retention hooks (S–M)

**Tutorial (first-run only, tracked via `Save.data.tutorialDone`):**
- 0–5s: "DRAG TO MOVE" pulses; require ±50 unit movement
- 8s: barrel spawns dead-ahead with "SHOOT THE BARREL"
- 12s: first mod pickup pauses game 1.5s: "YOU GOT RAPID FIRE"
- 20s: first gate: "PICK A SIDE"
- 30s: Stage 1 boss

**Reward pacing:** every 10 kills coin popup, every 25 kills "5/25 to new perk" toast, on-death "NEAREST UPGRADE: X" with Go To Armory button.

**Daily challenge:** on menu open, if today's date > `Save.data.dailyDate`, roll from `Defs.DAILY_CHALLENGES` and show banner: "TODAY: Beat Stage 3 without dying — reward: 100 🪙".

**Success criteria:** Fresh install runs tutorial once; second run skips it. Daily banner appears on menu.

### Phase 8 — Audio layer (M)

**Music:** 3 runtime-generated 32-bar loops using existing Web Audio grammar. Store as note sequences in `Defs.MUSIC = { menu, combat, boss }`. Scheduler queues notes 250ms ahead of `AudioContext.currentTime`.
- `menu`: soft ambient, sea drone (2 oscillators + noise, low-passed)
- `combat`: 120 BPM square-wave bass + arpeggio
- `boss`: 140 BPM sawtooth tension riff

**SFX polish:** distinct sound per weapon (Pistol=square-short-attack, SMG=sawtooth-pitched-down, Rifle=triangle-longer-attack, Grenade=kick+noise, Laser=chirp-down-saw).

**Success criteria:** Music plays on menu; changes on `Game.start`; distinct SFX per weapon.

### Phase 9 — Achievements + local leaderboard (M)

**Achievements:** 25 in `Defs.ACHIEVEMENTS = [...]`. Each `{id, name, desc, check: (snapshot) => boolean, reward: coins}`. Check after every run in `Game.end`; chain-toast on unlock. Persist in `Save.data.achievements = { <id>: timestamp }`.

Sample: "First Boss", "10 Stages Cleared", "50K Total Score", "Rocket Pods Master (100 kills)", "Bridge Kept Above 50% Full Stage".

**Local leaderboard:** append every run's `{mode, difficulty, stage/time, score, coins, kills, date}` to `Save.data.history[]` capped at 50. Menu tab shows sortable columns.

**Success criteria:** Every mode's completion screen offers "SEE ACHIEVEMENTS" and adds a row to leaderboard history.

### Phase 10 — Distribution + monetization (M)

**Marketing artifacts (external, not in HTML):**
- 3 in-game GIFs (5s each) — squad shooting, boss battle, bridge carry
- 1 cover image (600×450)

**itch.io listing:**
- Title: BRIDGE 5
- Blurb: 100 words
- Tags: `arcade`, `endless-runner`, `mobile`, `html5`, `shooter`, `single-player`
- Price: pay-what-you-want, **$3 minimum** (research: PWYW pays ~30% above minimum on avg)
- Revenue share to itch: **10%** default; adjust after 100 sales
- Category: HTML5 playable-in-browser, downloadable also allowed

**In-game monetization (toggle-gated):**
- Unlock code slot in Settings: entering the itch.io purchase code unlocks a "supporter" tier (bonus mode + tinted squad colors)
- Donation footer in menu: single-line "Enjoyed the game? Support at itch.io/…" external link, no popup

**Success criteria:** itch.io page live, playable in-browser, tracks a play count.

## Roadmap after Phase 10

See the Confluence page for the full roadmap. Highlights:

- **Graphics:** palette engine (Defs.PALETTES themes) → silhouette variety → parallax layer → optional CC0 sprite mode (Kenney pack, ~350 KB toggle) → weather → unique-effect signatures
- **Enemies to 12:** current 6 + Phase 3's 4 + future medic / cloaker / teleporter / hive
- **Mods to 12, uniques to 12:** chain / bounce / slow / heal / magnet / shockwave. Per-weapon: Cluster / Vampire / Ricochet / Choke / Chain Snipe / Blue Flame / Barrel Change / Static Field
- **Broader systems:** merge stations, prestige, loadout slots, boss variants, daily/weekly events, codex, accessibility
- **Distribution:** cross-post subreddits, Firebase Function analytics, supporter unlock code, post-mortem blog post, Steam wrap consideration

## Fallbacks / gotchas

- The `Draw.background` function assumes bridge-over-sea. When adding themed palettes (roadmap), do not fork it — replace hardcoded color literals with `Defs.PALETTES[Modes.currentTheme()][role]` lookups.
- Adding new modes requires an entry in `Modes.defs` **and** in `Save.data.best` **and** in the `refreshMenu` `bestX` textContent block **and** in the mode-button DOM. Miss any of these and something silently breaks.
- Arrow projectiles (Bridge mode) reuse a global `arrows[]` array. If a future phase adds another projectile category, follow the same pattern rather than merging into `bullets[]`.
- Every phase should end with a preview_eval sanity check that all 5 modes still boot cleanly (verified in this snapshot's audit).
