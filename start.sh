#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/GodotProject"

echo -e "${GREEN}🚀 Starting Deepiri Voxier (Godot)...${NC}"
echo ""

# Check for Godot
if [ ! -f "$HOME/.local/bin/godot" ] && ! command -v godot &> /dev/null; then
    echo -e "${RED}Godot not found! Run ./setup.sh first.${NC}"
    exit 1
fi

# Check for project
if [ ! -f "$PROJECT_DIR/project.godot" ]; then
    echo -e "${RED}Project not found!${NC}"
    exit 1
fi

# Run the game
cd "$PROJECT_DIR"

if [ -f "$HOME/.local/bin/godot" ]; then
    "$HOME/.local/bin/godot" --path .
else
    godot --path .
fi
