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

# Extract a zip using Bash-friendly paths. Prefer unzip (works under Git Bash);
# fall back to Python, converting MSYS paths for native Windows Python via cygpath.
extract_zip() {
  local archive="$1"
  local dest="$2"
  mkdir -p "$dest"
  if command -v unzip >/dev/null 2>&1; then
    unzip -qo "$archive" -d "$dest"
    return
  fi
  local archive_py="$archive" dest_py="$dest"
  if command -v cygpath >/dev/null 2>&1; then
    archive_py="$(cygpath -w "$archive")"
    dest_py="$(cygpath -w "$dest")"
  fi
  ARCHIVE_PY="$archive_py" DEST_PY="$dest_py" python3 -c \
    'import os, zipfile; zipfile.ZipFile(os.environ["ARCHIVE_PY"]).extractall(os.environ["DEST_PY"])'
}

link_godot_binary() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      if compgen -G "$INSTALL_DIR/${GODOT_TAG}_win64_console.exe" > /dev/null; then
        mv "$INSTALL_DIR/${GODOT_TAG}_win64_console.exe" "$INSTALL_DIR/godot.exe"
      elif compgen -G "$INSTALL_DIR/${GODOT_TAG}_win64.exe" > /dev/null; then
        mv "$INSTALL_DIR/${GODOT_TAG}_win64.exe" "$INSTALL_DIR/godot.exe"
      else
        echo "Windows Godot executable not found after extract" >&2
        ls -la "$INSTALL_DIR" >&2 || true
        exit 1
      fi
      chmod +x "$INSTALL_DIR/godot.exe"
      ;;
    Darwin)
      local macos_bin
      macos_bin="$(find "$INSTALL_DIR" -path '*/Contents/MacOS/Godot' -type f | head -1)"
      if [[ -z "$macos_bin" ]]; then
        echo "macOS Godot.app binary not found after extract" >&2
        ls -la "$INSTALL_DIR" >&2 || true
        exit 1
      fi
      chmod +x "$macos_bin"
      ln -sfn "$macos_bin" "$INSTALL_DIR/godot"
      ;;
    *)
      local bin
      bin="$(find "$INSTALL_DIR" -maxdepth 1 -type f -name 'Godot_v*' ! -name '*.zip' | head -1)"
      if [[ -z "$bin" ]]; then
        echo "Linux Godot binary not found after extract" >&2
        ls -la "$INSTALL_DIR" >&2 || true
        exit 1
      fi
      mv "$bin" "$INSTALL_DIR/godot"
      chmod +x "$INSTALL_DIR/godot"
      ;;
  esac
}

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
  extract_zip "$INSTALL_DIR/godot.zip" "$INSTALL_DIR"
  rm -f "$INSTALL_DIR/godot.zip"
  link_godot_binary
fi

TEMPLATE_ROOT="${HOME}/.local/share/godot/export_templates/${GODOT_TEMPLATE_VERSION}"
if [[ "$(uname -s)" == "Darwin" ]]; then
  TEMPLATE_ROOT="${HOME}/Library/Application Support/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
elif [[ "$(uname -s)" =~ MINGW|MSYS|CYGWIN ]]; then
  if [[ -n "${LOCALAPPDATA:-}" ]] && command -v cygpath >/dev/null 2>&1; then
    TEMPLATE_ROOT="$(cygpath -u "$LOCALAPPDATA")/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
  else
    TEMPLATE_ROOT="${HOME}/AppData/Local/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
  fi
fi

if [[ ! -d "$TEMPLATE_ROOT" ]]; then
  echo "==> Installing export templates ${GODOT_RELEASE}"
  curl -fsSL -o "$INSTALL_DIR/templates.tpz" "$TEMPLATES_URL"
  extract_zip "$INSTALL_DIR/templates.tpz" "$INSTALL_DIR/templates"
  mkdir -p "$TEMPLATE_ROOT"
  cp -a "$INSTALL_DIR/templates/templates/." "$TEMPLATE_ROOT/"
  rm -rf "$INSTALL_DIR/templates" "$INSTALL_DIR/templates.tpz"
fi

echo "Godot binary: ${INSTALL_DIR}/godot (or godot.exe on Windows)"
echo "Templates: $TEMPLATE_ROOT"
