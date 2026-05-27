# Deepiri Voxier

A fully Godot-based toolkit made by Deepiri for making classic arcade games.

## Features

- **Deepiri Vox (Analyzer)**: Integrated repository scanner (GDScript) to health-check your Deepiri repos.
- **Fox Rocket Arcade**: Full-featured arcade shooter with pseudo-3D rotation.
- **C.A.T. Pilot (CLI)**: Authentic terminal-style space dodger, reimagined within Godot.
- **Audio**: Layered music (menu / combat / game-over), 20+ CC0 SFX (Kenney), separate SFX/Music/UI buses.

## Getting Started

### Prerequisites

You need **Godot 4.2+** installed. You can use the provided setup script:

```bash
./setup.sh
```

### Running the App

```bash
./start.sh
```

## Project Structure

- `Voxier/`: The Godot project (`project.godot` lives here; Godot does not require this folder name).
  - `scenes/vox_ui.tscn`: Repository analyzer UI.
  - `scenes/cat_pilot.tscn`: CLI game recreation.
  - `scenes/main.tscn`: Main entry and rocket-fox arcade.
  - `audio/`: OGG music loops and SFX — see `audio/AUDIO_CREDITS.md` for CC0 attribution.
- `UnityProject/`: Placeholder for future expansion.

## Why Godot?

The project was migrated from Python to Godot to provide a unified, performant, and visually rich experience while maintaining the authentic "Deepiri" feel across all tools.
