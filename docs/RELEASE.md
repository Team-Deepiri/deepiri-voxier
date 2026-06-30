# Releasing Voxier (Godot)

GitHub Actions builds desktop exports for Linux, macOS, and Windows when you push a version tag. Assets use fixed filenames consumed by the [Deepiri landing site](https://github.com/Team-Deepiri/deepiri-landing).

Godot version: **4.2.2.stable** (see `.godot-version` and `setup.sh`).

## Cut a release

1. Merge changes to `main`.
2. Tag and push:

   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

3. Watch [Release workflow](https://github.com/Team-Deepiri/deepiri-voxier/actions/workflows/release.yml).

## Test CI without tagging

**Actions → Release → Run workflow** on a branch. Build jobs run; the publish job is skipped unless the ref is a `v*` tag.

## Local export (optional)

```bash
bash scripts/ci/install-godot.sh
bash scripts/ci/export-release.sh
ls release/
```

## Release assets

| Platform | Filename |
|----------|----------|
| macOS (arm64) | `Voxier-latest.dmg` |
| Linux | `Voxier-latest.zip` |
| Windows | `Voxier-latest.exe` |

## Verify download URLs

```bash
BASE=https://github.com/Team-Deepiri/deepiri-voxier/releases/latest/download

curl -I "$BASE/Voxier-latest.dmg"
curl -I "$BASE/Voxier-latest.zip"
curl -I "$BASE/Voxier-latest.exe"
```

## Code signing (v1)

Exports are **unsigned**. Gatekeeper / SmartScreen warnings are expected until signing is added later.
