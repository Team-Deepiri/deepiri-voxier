# Deepiri Voxier

A fully Godot-based toolkit made by Deepiri for making classic arcade games.

## Features

- **Deepiri Vox (Analyzer)**: Integrated repository scanner (GDScript) to health-check your Deepiri repos.
- **Fox Rocket Arcade**: Full-featured arcade shooter with pseudo-3D rotation.
- **C.A.T. Pilot (CLI)**: Authentic terminal-style space dodger, reimagined within Godot.

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

- `GodotProject/`: The complete application source (GDScript).
  - `scenes/vox_ui.tscn`: Repository analyzer UI.
  - `scenes/cat_pilot.tscn`: CLI game recreation.
  - `scenes/main.tscn`: Main entry point and Fox Rocket game.
- `UnityProject/`: Placeholder for future expansion.

## Why Godot?

The project was migrated from Python to Godot to provide a unified, performant, and visually rich experience while maintaining the authentic "Deepiri" feel across all tools.
