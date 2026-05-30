# Audio credits

All gameplay sound effects and music loops in this folder are **CC0 (public domain)** unless noted otherwise. You may use them freely in commercial and non-commercial projects.

## Kenney.nl (CC0)

Source packs (via [OpenGameArt.org](https://opengameart.org)):

- [Sci-Fi Sounds](https://opengameart.org/content/sci-fi-sounds) — lasers, engines, explosions, impacts
- [Interface Sounds](https://opengameart.org/content/interface-sounds) — UI clicks, confirmations, back/close

Files used include (renamed in `sfx/` and `music/`):

- `laserSmall_*`, `laserRetro_*`, `lowFrequency_explosion_*`, `explosionCrunch_*`
- `impactMetal_*`, `thrusterFire_*`, `forceField_*`, `computerNoise_*`
- `engineCircular_*`, `spaceEngine*`, `spaceEngineLow_*`, `spaceEngineSmall_*`, `doorClose_*`
- `click_*`, `confirmation_*`, `back_*`, `close_*`

Optional credit (not required): **Kenney.nl** or **www.kenney.nl**

## Project mapping

| File | Typical use |
|------|-------------|
| `sfx/fire.ogg` | Player weapon |
| `sfx/explosion.ogg` | Rocket detonation, heavy impacts |
| `sfx/hurt.ogg` | Player damage |
| `sfx/hop.ogg` | Rocket hop |
| `sfx/enemy_die.ogg` | Enemy destroyed |
| `sfx/rotate.ogg` | Arena rotation |
| `sfx/warning.ogg` | Rescue rocket timer pulse |
| `music/menu_loop.ogg` | Title / menu |
| `music/game_loop.ogg` | Normal combat |
| `music/combat_loop.ogg` | High enemy count |

Volume-normalized with FFmpeg `loudnorm` for consistent in-game levels.
