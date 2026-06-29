#!/usr/bin/env bash
# Export Voxier for the current OS and write landing-compatible release assets.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT="$ROOT/Voxier"
OUT="$ROOT/release"
GODOT_BIN="${GODOT_BIN:-$HOME/godot-ci/godot}"
if [[ -x "$HOME/godot-ci/godot.exe" ]]; then
  GODOT_BIN="$HOME/godot-ci/godot.exe"
elif [[ -x "$HOME/godot-ci/godot" ]]; then
  GODOT_BIN="$HOME/godot-ci/godot"
fi

mkdir -p "$OUT"
rm -rf "$PROJECT/build"
mkdir -p "$PROJECT/build/linux" "$PROJECT/build/windows" "$PROJECT/build/macos"

run_godot() {
  "$GODOT_BIN" "$@"
}

echo "==> Importing Godot project"
run_godot --headless --path "$PROJECT" --import

case "$(uname -s)" in
  Linux)
  echo "==> Exporting Linux"
  run_godot --headless --path "$PROJECT" --export-release "Linux" "$PROJECT/build/linux/Voxier.x86_64"
  STAGE="$OUT/linux-stage"
  rm -rf "$STAGE"
  mkdir -p "$STAGE"
  cp -a "$PROJECT/build/linux/"* "$STAGE/"
  (cd "$STAGE" && zip -r "$OUT/Voxier-latest.zip" .)
  ;;
  Darwin)
  echo "==> Exporting macOS"
  run_godot --headless --path "$PROJECT" --export-release "macOS" "$PROJECT/build/macos/Voxier.app"
  hdiutil create -volname "Voxier" -srcfolder "$PROJECT/build/macos/Voxier.app" -ov -format UDZO "$OUT/Voxier-latest.dmg"
  ;;
  MINGW*|MSYS*|CYGWIN*)
  echo "==> Exporting Windows"
  run_godot --headless --path "$PROJECT" --export-release "Windows Desktop" "$PROJECT/build/windows/Voxier.exe"
  cp "$PROJECT/build/windows/Voxier.exe" "$OUT/Voxier-latest.exe"
  if [[ -f "$PROJECT/build/windows/Voxier.pck" ]]; then
    cp "$PROJECT/build/windows/Voxier.pck" "$OUT/Voxier-latest.pck"
  fi
  ;;
  *)
  echo "Unsupported OS for export: $(uname -s)" >&2
  exit 1
  ;;
esac

echo "==> Release artifacts in $OUT"
ls -la "$OUT"
