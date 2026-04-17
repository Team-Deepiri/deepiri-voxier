#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/Voxier"

echo -e "${GREEN}Voxier — Setup${NC}"
echo ""

# ============================================
# PART 0: Linux system libraries (Godot audio / runtime)
# ============================================

install_linux_godot_runtime() {
	if [ "$(uname -s)" != "Linux" ]; then
		return 0
	fi
	if ! command -v sudo &> /dev/null; then
		echo -e "${YELLOW}No sudo: skip system packages. If Godot warns about audio, install ALSA/Pulse for your distro.${NC}"
		return 0
	fi

	echo -e "${BLUE}Installing Linux runtime libs for Godot (audio, etc.)…${NC}"

	if command -v apt-get &> /dev/null; then
		export DEBIAN_FRONTEND=noninteractive
		if sudo apt-get update -qq; then
			if sudo apt-get install -y libasound2 libpulse0 2>/dev/null; then
				echo -e "${GREEN}✓ apt: libasound2, libpulse0${NC}"
			elif sudo apt-get install -y libasound2t64 libpulse0 2>/dev/null; then
				echo -e "${GREEN}✓ apt: libasound2t64, libpulse0${NC}"
			else
				echo -e "${YELLOW}apt install failed; try: sudo apt-get install -y libasound2 libpulse0${NC}"
			fi
		else
			echo -e "${YELLOW}apt-get update failed (offline?). Install libasound2 / libpulse0 when online.${NC}"
		fi
	elif command -v dnf &> /dev/null; then
		if sudo dnf install -y alsa-lib pulseaudio-libs; then
			echo -e "${GREEN}✓ dnf: alsa-lib, pulseaudio-libs${NC}"
		else
			echo -e "${YELLOW}dnf install failed; try: sudo dnf install -y alsa-lib pulseaudio-libs${NC}"
		fi
	elif command -v pacman &> /dev/null; then
		if sudo pacman -S --needed --noconfirm alsa-lib libpulse; then
			echo -e "${GREEN}✓ pacman: alsa-lib, libpulse${NC}"
		else
			echo -e "${YELLOW}pacman install failed; try: sudo pacman -S alsa-lib libpulse${NC}"
		fi
	elif command -v zypper &> /dev/null; then
		if sudo zypper install -y libasound2 libpulse0; then
			echo -e "${GREEN}✓ zypper: libasound2, libpulse0${NC}"
		else
			echo -e "${YELLOW}zypper install failed.${NC}"
		fi
	else
		echo -e "${YELLOW}Unknown package manager. Godot may need ALSA/Pulse libraries — see Godot Linux export docs.${NC}"
	fi
}

install_linux_godot_runtime || true
echo ""

# ============================================
# PART 1: Install Godot
# ============================================

ARCH="$(uname -m)"
GODOT_INSTALLED=false

if command -v godot &> /dev/null; then
    echo -e "${GREEN}✓ Godot already installed!${NC}"
    godot --version 2>/dev/null || true
    GODOT_INSTALLED=true
fi

if [ "$GODOT_INSTALLED" = false ]; then
    echo -e "${YELLOW}Installing Godot 4.2...${NC}"
    
    case "$ARCH" in
        x86_64)  GODOT_NAME="Godot_v4.2.2-stable_linux.x86_64" ;;
        arm64|aarch64)  GODOT_NAME="Godot_v4.2.2-stable_linux.arm64" ;;
        *)  echo -e "${RED}Unsupported: $ARCH" && exit 1 ;;
    esac
    
    if [ ! -f "$HOME/.local/bin/godot" ]; then
        echo -e "${BLUE}Downloading Godot...${NC}"
        TMP=$(mktemp -d)
        cd "$TMP"
        
        curl -sLo godot.zip "https://github.com/godotengine/godot/releases/download/4.2.2-stable/${GODOT_NAME}.zip"
        
        if [ ! -s godot.zip ]; then
            echo -e "${RED}Download failed!${NC}"
            exit 1
        fi
        
        echo -e "${BLUE}Extracting...${NC}"
        python3 -c "import zipfile; zipfile.ZipFile('godot.zip','r').extractall('.')"
        
        mkdir -p "$HOME/.local/bin"
        mv "$GODOT_NAME" "$HOME/.local/bin/godot"
        chmod +x "$HOME/.local/bin/godot"
        
        cd ~
        rm -rf "$TMP"
    fi
    
    echo -e "${GREEN}✓ Godot installed!${NC}"
fi

echo ""

# ============================================
# PART 2: Setup Godot Project
# ============================================

echo -e "${GREEN}📦 Setting up project...${NC}"

if [ ! -f "$PROJECT_DIR/project.godot" ]; then
    echo -e "${RED}Project not found at $PROJECT_DIR${NC}"
    exit 1
fi

# Headless editor import (--import); plain --headless --path runs the game loop.
echo -e "${BLUE}Importing project (first time setup)...${NC}"
cd "$PROJECT_DIR"

export PATH="$HOME/.local/bin:$PATH"
godot --headless --path . --import

echo -e "${GREEN}✓ Project ready!${NC}"
echo ""

# ============================================
# PART 3: Ask to run
# ============================================

echo -e "${YELLOW}🚀 Do you want to run the game now?${NC}"
echo -e "${BLUE}(y/n): ${NC}"
read -r RUN

if [ "$RUN" = "y" ] || [ "$RUN" = "Y" ]; then
    echo -e "${GREEN}Starting game...${NC}"
    godot --path .
else
    echo ""
    echo -e "${GREEN}To run later:${NC}"
    echo "  ./start.sh"
    echo ""
    echo -e "${YELLOW}Or in Godot: F5 to run${NC}"
fi