# Vox Wildspace — Product Roadmap

**Working title:** Vox Wildspace  
**Engine:** Godot 4.2+ (`Voxier/`)  
**Status today:** Deepiri Voxier ships three experiences as one project—Fox Rocket Arcade (3D, default entry), C.A.T. Pilot (terminal dodge), and Deepiri Vox (repo scanner). None of them yet form a single shippable game with progression, narrative, or a unified brand.

This document defines the **vision** for turning the toolkit into **one full game** and breaks work into phases you can schedule, estimate, and review.

---

## 1. Vision statement

**Vox Wildspace** is a fast, readable arcade exploration game about a fox pilot charting unstable sectors of deep space—the “wildspace”—where physics, gravity, and threat vectors **rotate without warning**. You survive by shooting, dodging, and **hopping between rockets** before your current craft falls away. Between runs you use ship systems (including a diegetic **Vox** terminal) to map anomalies, unlock routes, and piece together why the wildspace is fracturing.

**One-sentence pitch:** *Geometry Wars meets Star Fox, with an eight-way rotating arena and a desperate rocket-hop survival loop—wrapped in Deepiri’s CRT-soaked, fox-forward aesthetic.*

**Design pillars**

| Pillar | Player promise | Already in repo |
|--------|----------------|-----------------|
| **Rotating wildspace** | The playfield reorients; threats come from new “north” every few seconds | `direction_controller.gd`, `direction_controller_3d.gd`, 8-way `SCREEN_ROTATIONS` |
| **Rocket hop survival** | Your craft is temporary; timing the hop to a fresh rocket is the core tension | `GameManager` states `FALLING`, `ROCKET_CHANGE`, `hop_to_rocket()` |
| **Readable arcade juice** | Every hit, pickup, and sector shift **feels** loud and clear | `camera_juice`, `impact_particles`, `cinematic_post`, SFX router, shaders |
| **Sector variety** | Biomes and rules change how you move and score | `background_manager.gd` biomes; `GameTune` resource |
| **Diegetic tools** | The world’s “scanner” isn’t a separate app—it’s how you **see** the wildspace | Deepiri Vox UI + scan session (`vox_ui`, `VoxAnalyzer`)—needs fiction layer |
| **Modes with purpose** | Side experiences reinforce fantasy, not random demos | C.A.T. Pilot levels (`cat_pilot_game.gd`); menu hooks in `main_3d.gd` |

**What we are not building (v1 scope guard)**

- MMO / live-service economy
- Full open-world sandbox (sectors are **runs**, not infinite streaming worlds)
- Unity migration (`README` placeholder)—Godot is the ship vehicle
- Real repo scanning as a gameplay requirement for non-Deepiri players (Vox becomes **optional** or **fictionalized** for retail builds)

---

## 2. Fiction & player fantasy

### Setting

The **Wildspace** is a band of starlanes where navigation grids collapsed. Compasses spin in eight discrete headings; debris and hostiles drift along **screen-relative** vectors. Fox pilots of the **Deepiri line** run sorties in disposable boosters, relaying telemetry back to a mothership running **Vox**—an analysis stack that turns sensor noise into sector maps.

### Protagonist

- **Fox pilot** (player): competent, understated humor, defined by **actions** (hop timing, aggressive repositioning) not dialogue trees in v1.
- **Ship AI / ground control** (optional VO/text): short callouts on rotation, rocket expiry, sector clears—reuse `EventBus` for barks.

### Antagonists & pressure

- **Drift fleets**: fodder waves (`enemy`, `enemy_3d`, spawners).
- **Anchor beasts** (bosses): large targets that **lock** a rotation until destroyed—teach the eight-way system under stress.
- **The Fracture** (meta threat): explains escalating difficulty and visual glitches (CRT, vignette intensity as narrative knob).

### C.A.T. Pilot in-universe

Reframe **C.A.T. Pilot** as a **crash-recovery sim** or **mothership docking tunnel** game: when the fox is ejected or comms fail, you play the ASCII survival sequence (`levels` 1–5: Nebula Drift → VOID ZONE). Completing it **repairs** or **buffs** the next Wildspace sortie.

### Deepiri Vox in-universe

- **Retail / general audience:** Vox displays **wildspace telemetry** (sector health, threat tables, lore codex)—same UI patterns as today’s repo report (`ascii_report_builder.gd`) but fed by **game data**, not filesystem paths.
- **Developer / Deepiri internal builds:** Optional “Workspace scan” mode keeps real `VoxAnalyzer` behavior for dogfooding.

---

## 3. Core gameplay loop (target)

```
Hub (Mothership)
  → Select sector / loadout
  → Sortie (3D Wildspace run: rotate · shoot · hop rockets)
  → Extraction or death
  → Rewards (currency, unlocks, codex, Vox map update)
  → Hub
```

**Sortie structure (15–25 min target for a full sector)**

1. **Ingress** — calm wave, teach rotation if new biome.
2. **Escalation** — spawner curves tighten; powerups (`powerup`, `powerup_3d`) define build style.
3. **Anomaly** — mini-event (meteor lane, gravity invert, no-rotation window).
4. **Anchor fight** — boss with rotation gimmick.
5. **Extraction** — score tally, optional bonus objective (no damage hop chain, etc.).

**Fail state**

- Lives reach zero **or** fall timer expires without hop (`GameManager` fall height)—return to hub with partial rewards (roguelite-friendly) or checkpoint policy (campaign-friendly); **pick one** in Phase 2.

---

## 4. Current codebase map → Wildspace systems

| Existing asset | Path / entry | Wildspace role |
|----------------|--------------|----------------|
| Main 3D arcade | `scenes/main_3d.tscn`, `arcade3/*` | **Primary sortie** gameplay |
| 2D arcade | `scenes/main.tscn`, `player.gd`, `fox.gd` | Legacy / bonus sector skin or cutdown mobile mode |
| Game state & UI bind | `game_manager.gd`, `GameTune` | Extend with `RUN`, `HUB`, `DEBRIEF` states |
| Scene switching | `scene_registry.gd` | Expand: `HUB`, `SECTOR_SELECT`, `DEBRIEF`, `SETTINGS` |
| Autoloads | `EventBus`, `GameAudio`, `DeepiriPaths`, `GameManager` | Add `SaveGame`, `Progression`, `SectorCatalog` autoloads |
| Juice & FX | `scripts/juice/*`, `scripts/fx/*`, shaders | Per-biome profiles; boss phases |
| Audio | `game_audio.gd`, `sfx_router.gd`, `bus_ids.gd` | Music states per sector; sting on rotation |
| Cat mode | `cat_pilot.tscn`, `cat_pilot_game.gd` | **Recovery sim** between sorties |
| Vox tool | `vox_ui.tscn`, `scripts/vox/*` | **Codex / sector map** UI; dual data backend |
| Constants / branding | `deepiri_constants.gd` | Rename product surface to **Vox Wildspace** |
| Export | `export_presets.cfg` | New presets: `VoxWildspace` (Win/Linux/macOS) |
| CI | `.github/workflows/codeql.yml` | Add Godot headless import + `gut` or `gdUnit4` when tests exist |

---

## 5. Phase roadmap

### Phase 0 — Vision lock & foundations (1–2 weeks)

**Goal:** Everyone agrees what “done” means for v1.0.

- [ ] **GDD one-pager** derived from this doc (pillars, loop, fail policy).
- [ ] **Rename & present** — `PRODUCT_NAME`, window title, export binary, README hero = *Vox Wildspace*; keep “Deepiri” as studio credit.
- [ ] **Scope v1.0** — e.g. 6 sectors, 3 bosses, 1 hub, Cat recovery optional, fictional Vox only.
- [ ] **Art/audio style guide** — CRT strength, palette (`deepiri_theme.tres`), fox silhouette readability at 800×600.
- [ ] **Input & accessibility baseline** — remap via `action_catalog.gd`; toggle screen shake, reduce flashes.

**Exit criteria:** Playable **vertical slice** definition written (Sector 1 start → first boss → debrief mock).

---

### Phase 1 — Product shell & navigation (2–3 weeks)

**Goal:** The project feels like **one game**, not a menu to three demos.

- [ ] **Mothership hub scene** — sector select, upgrades placeholder, settings, credits.
- [ ] **Scene flow** — extend `scene_registry.gd`; replace ad-hoc `change_scene_to_file` with a small `SceneFlow` autoload (history, loading fade).
- [ ] **GameManager states** — add `HUB`, `DEBRIEF`, `CAT_RECOVERY`; unify 2D/3D behind a `GameMode` enum if 2D stays.
- [ ] **Main menu UX** — single “Launch Wildspace” path; demote raw Vox/Cat buttons to hub terminals unless dev build.
- [ ] **Pause & settings** — wire `local_settings.gd` / `settings_keys.gd` to volume, fullscreen, shaders on/off.
- [ ] **Version & build stamp** — `version_info.gd` + commit hash in dev overlay (`dev_overlay.gd`).

**Exit criteria:** Boot → Hub → Start Sector 1 (even if empty arena) → Return to Hub without scene errors.

---

### Phase 2 — Sortie loop completion (3–5 weeks)

**Goal:** One sector is **complete** as a game level, not an endless arcade toy.

- [ ] **Sector resource** — `SectorProfile` (waves, biome, music, boss id, rotation cadence overrides).
- [ ] **Wave director** — refactor `enemy_spawner` / `enemy_spawner_3d` to scripted waves + budget, not pure random.
- [ ] **Scoring & combo** — extend `score_rules.gd`; rank medals (S/A/B) for debrief.
- [ ] **Powerup taxonomy** — define 6–8 types (shield, spread, slow-mo rotation, magnet, etc.); data-driven from `.tres`.
- [ ] **Rocket variety** — multiple `rocket` / `rocket_3d` prefabs with different fire patterns and fall speeds.
- [ ] **Boss framework** — `BossPhase` state machine, weak points, rotation-lock gimmicks.
- [ ] **Debrief screen** — stats, unlock prompts, “Scan sector” → Vox codex entry.
- [ ] **Fail / continue policy** — implement chosen roguelite vs checkpoint model.

**Exit criteria:** Sector 1 playable start-to-boss with debrief and hub return.

---

### Phase 3 — Content pipeline & biomes (4–6 weeks)

**Goal:** Repeatable authoring so adding sectors doesn’t mean code changes.

- [ ] **Biome integration** — map `BackgroundType` + 3D starfields to `SectorProfile`; parallax rules per rotation.
- [ ] **Enemy family set** — 8–12 archetypes (chaser, turret, lane drifter, kamikaze, shielded) with 3D meshes/sprites.
- [ ] **Sector authoring tools** — Godot `@tool` wave editor or CSV/JSON → wave importer.
- [ ] **Six sectors for v1** — distinct rotation cadence, biome, boss, music stem.
- [ ] **Mini-anomalies** — reusable event modules (meteor shower, blackout, double rotation speed).
- [ ] **Difficulty bands** — Easy / Normal / Wild (tune `GameTune` + spawner budgets).

**Exit criteria:** Six sectors selectable from hub with distinct feel; internal playtesters can finish campaign in one sitting (~2 hours).

---

### Phase 4 — Meta progression & persistence (2–4 weeks)

**Goal:** Reason to return after death.

- [ ] **Save system** — extend `local_settings.gd` → `SaveGame` (unlocks, high scores, codex, currency).
- [ ] **Currency & upgrades** — engines (rocket interval shrink cap), hull (extra life), Vox modules (scanner range fiction).
- [ ] **Unlock graph** — sector 2–6 gated by boss clears or currency; optional secret sector.
- [ ] **Achievements** — 20–30 trackable feats (hop chains, no-rotation damage clears).
- [ ] **Leaderboards** — local first; optional Steam/itch if platform allows.

**Exit criteria:** New profile → progression persists → second session opens more than first.

---

### Phase 5 — Integrated modes (2–3 weeks)

**Goal:** C.A.T. and Vox feel like **parts of Wildspace**, not side carts.

- [ ] **C.A.T. recovery hook** — trigger after life loss or between sectors; rewards map to `GameTune` buffs next sortie.
- [ ] **Vox codex** — replace or branch `vox_ui` data source: `WildspaceTelemetry` resource vs `VoxAnalyzer` filesystem.
- [ ] **Codex entries** — tie each boss/sector to ASCII report templates (`ascii_report_builder.gd`).
- [ ] **Developer mode flag** — `DEVELOPER_BUILD` enables real repo scan path via `DeepiriPaths`.
- [ ] **2D mode decision** — ship as “retro sector” DLC slice or cut from v1 to reduce maintenance.

**Exit criteria:** Player can open Vox from hub, read last sector analysis, launch Cat recovery from debrief.

---

### Phase 6 — Narrative & presentation (2–3 weeks)

**Goal:** Emotional arc without bloating scope.

- [ ] **Story beats** — intro crawl, six sector stingers, Fracture reveal, ending branch on campaign clear.
- [ ] **Bark system** — `EventBus` subscribers for rotation, low lives, boss phase; subtitle support.
- [ ] **Cinematic pass** — tune `cinematic_post_driver.gd`, vignette, scanlines per context (hub calm, combat hot).
- [ ] **Character moments** — fox reactions (sprite rim pulse, hop triumph anim) using `fox_texture_builder.gd`.
- [ ] **Trailer script** — 60–90s capture list from strongest sectors.

**Exit criteria:** Playthrough from new game to credits feels intentional, not endless arcade.

---

### Phase 7 — Polish, performance, QA (3–4 weeks)

**Goal:** Shippable quality on target hardware.

- [ ] **Performance budget** — 60 FPS on mid laptop integrated GPU; profile 3D draw calls, particle caps.
- [ ] **Game feel pass** — hitstop, i-frames (`player.gd` stun), audio ducking on rotation.
- [ ] **Controller & rebinding** — full gamepad path; Steam Input if shipping Steam.
- [ ] **Localization prep** — string externalization (CSV/PO), UI layout for +30% text width.
- [ ] **Automated tests** — unit tests for `score_rules`, wave parser, save migration; smoke test boot hub.
- [ ] **Playtest matrix** — input devices, resolutions, Linux/Win/macOS exports.
- [ ] **Bug bash & triage** — freeze content; fix P0/P1 only.

**Exit criteria:** No known crashers; FPS stable; accessibility toggles work.

---

### Phase 8 — Platform release (2–3 weeks)

**Goal:** Players outside Deepiri can buy/download.

- [ ] **Store pages** — itch.io / Steam (if applicable): copy, caps, system requirements.
- [ ] **Export presets** — `VoxWildspace.x86_64`, `.app`, `.exe`; code signing as needed.
- [ ] **Legal & attribution** — `LICENSE`, third-party fonts/audio, Godot mention.
- [ ] **Launch build pipeline** — tag releases, attach builds to GitHub Releases.
- [ ] **Day-one patch plan** — hotfix branch, telemetry-free crash logging optional.

**Exit criteria:** v1.0.0 build published; install doc matches `setup.sh` / `start.sh` flow.

---

### Phase 9 — Post-launch (ongoing)

- [ ] **Sector 7+** — seasonal anomalies, community vote bosses.
- [ ] **Daily challenge** — fixed seed rotation + leaderboard.
- [ ] **Co-op sortie** — networked fox pair (large effort; own milestone).
- [ ] **Mod support** — `SectorProfile` packs from `user://mods`.
- [ ] **Deepiri workspace integration** — optional achievement sync for internal repos (niche).

---

## 6. Technical architecture (target end state)

```
Autoloads
├── EventBus          (signals: combat, UI, narrative)
├── GameAudio         (buses, music states)
├── GameManager       (high-level state machine)
├── SceneFlow         (scene transitions)
├── SaveGame          (persistence)
├── Progression       (unlocks, currency)
└── SectorCatalog     (loads SectorProfile resources)

Data (resources/)
├── game_tune.gd / *.tres
├── sector_profile.gd / sectors/*.tres
├── enemy_archetype.gd
├── wave_script.gd
└── wildspace_telemetry.gd  (Vox codex backend)

Scenes
├── hub.tscn
├── sector_select.tscn
├── sortie_3d.tscn          (evolved main_3d)
├── debrief.tscn
├── vox_codex.tscn          (evolved vox_ui)
├── cat_recovery.tscn       (evolved cat_pilot)
└── settings.tscn
```

**Principles**

- **Data-driven sectors** — designers tweak `.tres`, not spawner code.
- **One source of truth for tuning** — `GameTune` + sector overrides, not magic numbers in `enemy.gd`.
- **Signal-first** — gameplay emits `EventBus` events; UI/audio listen.
- **Keep 2D/3D parity only where it pays** — prefer 3D for v1 campaign; 2D as optional skin.

---

## 7. Content checklist (v1.0 target)

| Category | v1 target | Notes |
|----------|-----------|--------|
| Sectors | 6 + 1 secret | Unique boss + biome each |
| Bosses | 6 (+ secret) | Rotation gimmick required |
| Enemy types | 10–12 | Shared across sectors with palettes |
| Powerups | 8 | Stack rules documented |
| Rockets | 4 | Distinct weapons / fall curves |
| Music tracks | 8 | Hub, 6 sectors, boss, game over |
| SFX | ~25 | Map to `sfx_router` ids |
| Codex entries | 20+ | Vox reports + lore |
| Cat levels | 5 | Recovery arc unchanged, re-skinned intro/outro |
| Achievements | 24 | Platform + in-game list |

---

## 8. Risks & mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Three modes stay disconnected | Feels like a tech demo | Phase 1 hub + Phase 5 fiction hooks (mandatory for v1) |
| Rotation disorients players | Churn in first 5 min | Tutorial sector, slow first rotation, compass UI (`ui_direction`) |
| Scope creep on “full game” | Never ships | Lock v1 to 6 sectors; post-launch for co-op/mod |
| Vox filesystem coupling | Retail builds break | `WildspaceTelemetry` backend; dev-only scan flag |
| 2D + 3D duplicate maintenance | Bug duplication | Pick 3D for campaign; freeze 2D or one “retro” sector |
| No automated tests | Regressions at export | Phase 7 smoke + core unit tests |

---

## 9. Milestones summary

| Milestone | Phases | Deliverable |
|-----------|--------|-------------|
| **M0: Vertical slice** | 0–2 | Sector 1: boss + debrief + hub |
| **M1: Campaign alpha** | 3 | 6 sectors, no meta |
| **M2: Campaign beta** | 4–5 | Saves, unlocks, Cat/Vox integrated |
| **M3: Content complete** | 6 | Story, codex, all audio |
| **M4: Gold** | 7–8 | Release builds |
| **M5: Live** | 9 | Updates, dailies |

**Rough calendar (solo/small team):** M0–M4 ≈ **20–30 weeks** with focused effort; parallel art/audio can overlap Phase 3–6.

---

## 10. Immediate next steps (suggested order)

1. Approve v1 scope (six sectors, 3D-only campaign, fictional Vox, Cat as recovery).
2. Rename product surfaces (`deepiri_constants.gd`, `project.godot`, export preset, README).
3. Implement **hub scene** + `SceneFlow` + extended `GameManager` states.
4. Author **Sector 1** `SectorProfile` + wave file + first boss.
5. Build **debrief** → hub loop before adding Sector 2.

---

## 11. Success metrics (v1)

- **Session length:** median 20+ minutes (one sector + hub tinkering).
- **D1 retention (playtest):** ≥ 40% start second sector.
- **Clarity:** ≥ 80% playtesters explain rotation + hop without prompting after Sector 1.
- **Stability:** zero crash per hour on reference hardware.
- **Identity:** playtesters name the game **Vox Wildspace**, not “the fox arcade” or “three mini-games.”

---

*This roadmap lives in the repo so it can evolve with commits. When a phase completes, check boxes in PR descriptions or link issues to phase headings.*
