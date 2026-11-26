# Changelog

All notable changes to **AngelOS 11** are documented in this file using [Semantic Versioning](https://semver.org/).

## [Unreleased]
### Added
- Completed `archiso` live profile (`angelos-11` hostname/os-release, passwordless live user `angel`, SDDM Wayland autologin, `NetworkManager` & `vboxservice` auto-enabled, staged from upstream `releng` with AngelOS 11 boot branding).
- Added initial Windows 11 Plasma 6 desktop layer: original AngelOS 11 start icon & Light/Dark Bloom SVG wallpapers, `AngelOS11Dark`/`AngelOS11Light` color schemes, `apply-win11-layout.sh` (48px docked centered taskbar, `IAX` titlebars, KWin blur, Dolphin layout, Windows 11 shortcuts), and PyQt6 First-Boot OOBE Light/Dark mode picker.
- Added `angelos-wine-runner` + `.exe`/`.msi` desktop handlers (`compat/wine/`) for seamless Wine Staging launches with desktop notifications.

## [0.0.1] - 2026-11-26
### Added
- Initialized the **AngelOS 11** Arch Linux + latest KDE Plasma 6 repository scaffold.
- Added architecture documentation, Windows 11 fidelity specification, SemVer roadmap, and VirtualBox testing guide.
- Added starter `archiso` profile (`iso/archiso-profile/`), Calamares layout placeholder (`iso/calamares/`), desktop/Wine module directories, and helper scripts (`bump-version.ps1`, `vbox-test.ps1`, `bootstrap-vm.sh`, `build-iso.sh`).
- Added GitHub Actions workflows for repository linting and tag-triggered SemVer ISO builds.
