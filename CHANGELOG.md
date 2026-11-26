# Changelog

All notable changes to **AngelOS 11** are documented in this file using [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-11-26
### Added
- Switched theme exclusively to `yeyushengfan258/Win11OS-kde` (Aurorae, Kvantum, Color Schemes, Desktop Theme, Look-and-Feel, and SDDM 6.0), updated for latest KDE Plasma 6 (right-side `IAX` titlebar buttons, Plasma 6 `metadata.json`, and `Splash.qml` Qt6 fix) alongside paired `Win11-icon-theme` and `Win10OS-cursors`.
- Added left-side Windows 11-style `org.angelos.widgets` plasmoid, `org.angelos.search` rounded Search pill, `Eisteed/menu-11-next` Plasma 6 Start Menu, `org.angelos.showdesktop` thin sliver, and Windows 11 right-side tray/clock/notification bell order.
- Added Microsoft Edge (`microsoft-edge-stable-bin` via AUR with `chromium` fallback) and `ttf-selawik` font builds to `build-iso.sh`, pinning Edge to the centered taskbar.
- Moved layout initializer to `/usr/local/libexec/angelos-apply-layout` with `NoDisplay=true` and immediate autostart cleanup so it stays hidden from user folders and app menus.

## [0.0.1] - 2026-11-26
### Added
- Initialized the **AngelOS 11** Arch Linux + latest KDE Plasma 6 repository scaffold.
- Added architecture documentation, Windows 11 fidelity specification, SemVer roadmap, and VirtualBox testing guide.
- Added starter `archiso` profile (`iso/archiso-profile/`), Calamares layout placeholder (`iso/calamares/`), desktop/Wine module directories, and helper scripts (`bump-version.ps1`, `vbox-test.ps1`, `bootstrap-vm.sh`, `build-iso.sh`).
- Added GitHub Actions workflows for repository linting and tag-triggered SemVer ISO builds.
