#!/usr/bin/env bash
# Install Godot editor + export templates for CI (Linux, macOS, Windows via Git Bash).
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.2.2}"
GODOT_RELEASE="${GODOT_VERSION}-stable"
GODOT_TAG="Godot_v${GODOT_RELEASE}"
# Godot locates export templates by its dotted version string (e.g. 4.2.2.stable),
# not the hyphenated release tag used for downloads.
GODOT_TEMPLATE_VERSION="${GODOT_VERSION}.stable"
INSTALL_DIR="${INSTALL_DIR:-$HOME/godot-ci}"
mkdir -p "$INSTALL_DIR"

case "$(uname -s)" in
  Linux)
  case "$(uname -m)" in
    x86_64) GODOT_ARCHIVE="${GODOT_TAG}_linux.x86_64.zip" ;;
    aarch64|arm64) GODOT_ARCHIVE="${GODOT_TAG}_linux.arm64.zip" ;;
    *) echo "Unsupported Linux arch: $(uname -m)" >&2; exit 1 ;;
  esac
  ;;
  Darwin)
  GODOT_ARCHIVE="${GODOT_TAG}_macos.universal.zip"
  ;;
  MINGW*|MSYS*|CYGWIN*)
  GODOT_ARCHIVE="${GODOT_TAG}_win64.exe.zip"
  ;;
  *)
  echo "Unsupported OS: $(uname -s)" >&2
  exit 1
  ;;
esac

GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_RELEASE}/${GODOT_ARCHIVE}"
TEMPLATES_URL="https://github.com/godotengine/godot/releases/download/${GODOT_RELEASE}/${GODOT_TAG}_export_templates.tpz"

if [[ ! -x "$INSTALL_DIR/godot" && ! -x "$INSTALL_DIR/godot.exe" ]]; then
  echo "==> Downloading Godot ${GODOT_RELEASE}"
  curl -fsSL -o "$INSTALL_DIR/godot.zip" "$GODOT_URL"
  python3 -c "import zipfile; zipfile.ZipFile('$INSTALL_DIR/godot.zip','r').extractall('$INSTALL_DIR')"
  rm -f "$INSTALL_DIR/godot.zip"
  if compgen -G "$INSTALL_DIR/${GODOT_TAG}_win64_console.exe" > /dev/null; then
    mv "$INSTALL_DIR/${GODOT_TAG}_win64_console.exe" "$INSTALL_DIR/godot.exe"
    chmod +x "$INSTALL_DIR/godot.exe"
  elif compgen -G "$INSTALL_DIR/${GODOT_TAG}_win64.exe" > /dev/null; then
    mv "$INSTALL_DIR/${GODOT_TAG}_win64.exe" "$INSTALL_DIR/godot.exe"
    chmod +x "$INSTALL_DIR/godot.exe"
  else
    bin="$(find "$INSTALL_DIR" -maxdepth 1 -type f -name 'Godot_v*' ! -name '*.zip' | head -1)"
    mv "$bin" "$INSTALL_DIR/godot"
    chmod +x "$INSTALL_DIR/godot"
  fi
else
  if [[ ! -x "$INSTALL_DIR/godot" && ! -x "$INSTALL_DIR/godot.exe" ]]; then
    bin="$(find "$INSTALL_DIR" -maxdepth 1 -type f -name 'Godot_v*' ! -name '*.zip' | head -1)"
    if [[ -n "$bin" ]]; then
      mv "$bin" "$INSTALL_DIR/godot"
      chmod +x "$INSTALL_DIR/godot"
    fi
  fi
fi

TEMPLATE_ROOT="${HOME}/.local/share/godot/export_templates/${GODOT_TEMPLATE_VERSION}"
if [[ "$(uname -s)" == "Darwin" ]]; then
  TEMPLATE_ROOT="${HOME}/Library/Application Support/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
elif [[ "$(uname -s)" =~ MINGW|MSYS|CYGWIN ]]; then
  TEMPLATE_ROOT="${LOCALAPPDATA:-$HOME/AppData/Local}/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
fi

if [[ ! -d "$TEMPLATE_ROOT" ]]; then
  echo "==> Installing export templates ${GODOT_RELEASE}"
  curl -fsSL -o "$INSTALL_DIR/templates.tpz" "$TEMPLATES_URL"
  python3 -c "import zipfile; zipfile.ZipFile('$INSTALL_DIR/templates.tpz','r').extractall('$INSTALL_DIR/templates')"
  mkdir -p "$TEMPLATE_ROOT"
  cp -a "$INSTALL_DIR/templates/templates/." "$TEMPLATE_ROOT/"
  rm -rf "$INSTALL_DIR/templates" "$INSTALL_DIR/templates.tpz"
fi

echo "Godot binary: ${INSTALL_DIR}/godot (or godot.exe on Windows)"
echo "Templates: $TEMPLATE_ROOT"
