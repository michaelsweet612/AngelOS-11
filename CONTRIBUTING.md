# Contributing to AngelOS 11

Thank you for helping build **AngelOS 11**!

## Core Principles

1. **Visual & Behavioral Fidelity First**: Every UI change should be checked against Windows 11 proportions, spacing, corner radii (`8px` windows / `4px–8px` controls), Mica/Acrylic translucency, and keyboard shortcuts on the **latest KDE Plasma 6 (Wayland)**.
2. **Clean Licensing & Original Assets**: Never commit proprietary Microsoft binaries, copyrighted fonts (use **Selawik** / **Inter**), or copyrighted Microsoft wallpapers/logos. Use open-source equivalents and original AngelOS 11 assets.
3. **Reproducible Arch Packaging**: Prefer clean Arch `PKGBUILD`s and declarative config files over ad-hoc manual tweaks so `archiso` and `calamares` stay deterministic across SemVer releases.
4. **Semantic Versioning (`VERSION`)**: Follow `MAJOR.MINOR.PATCH` (`0.0.1`, `0.1.0`, `1.0.0`, `1.1.2`). Use `scripts/bump-version.ps1` when cutting a new release.

## Coding & Formatting Standards

- Follow `.editorconfig` (UTF-8, LF for Linux configs/scripts/QML, CRLF permitted for `.ps1`, 2 spaces for YAML/JSON, 4 spaces for QML/Bash/Python).
- Lint shell scripts with `shellcheck` and keep Bash scripts `set -euo pipefail`.
- Document any Plasma 6 KWin ABI rebuild requirements in `packages/pkgbuilds/` or `docs/ARCHITECTURE.md` so C++ plugins track the latest Arch Plasma release cleanly.
