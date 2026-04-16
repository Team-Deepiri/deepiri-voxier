# Deepiri Voxier

A unified toolkit for Deepiri repository analysis and classic arcade games.

## Features

- **Repository Analysis**: A suite of tools to scan, size, and health-check multiple Deepiri repositories.
- **Arcade Games**:
  - **C.A.T. Pilot**: A CLI-based space dodger.
  - **Fox Rocket Arcade**: A Godot 4 arcade shooter with pseudo-3D rotation.

## Installation

```bash
pip install -e .
```

## Usage

You can use the `voxier` command to access the different tools:

### Run the Repository Scanner

```bash
voxier --scan
```

### Play C.A.T. Pilot (CLI)

```bash
voxier --game cat
```

### Play Fox Rocket Arcade (Godot)

```bash
voxier --game fox
```

## Project Structure

- `src/voxier/analyzer`: Tools for repository scanning and analysis.
- `src/voxier/games`: Python implementations of arcade games (C.A.T. Pilot).
- `src/voxier/ui`: UI utilities and terminal dashboard components.
- `GodotProject/`: Godot 4 implementation of Fox Rocket Arcade.
- `UnityProject/`: Placeholder for Unity implementation.

## Development

- Run tests (if available): `python3 -m pytest`
- Add new analyzer scripts to `src/voxier/analyzer/` and register them in `orchestrator.py`.
