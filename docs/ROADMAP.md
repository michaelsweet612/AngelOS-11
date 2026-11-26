# AngelOS 11 SemVer Roadmap

AngelOS 11 uses **Semantic Versioning** (`MAJOR.MINOR.PATCH`) tracked in [`VERSION`](../VERSION) and tagged in Git (`v0.0.1`, `v0.1.0`, `v1.0.0`, `v1.1.2`, …).

---

## `v0.0.1` — Repository Scaffold & Base ISO *(Current Milestone)*
- [x] Initialize `michaelsweet612/AngelOS-11` GitHub repository (Public, GPL-3.0)
- [x] Architecture, Windows 11 Fidelity Spec, Roadmap, and VirtualBox Testing docs
- [x] GitHub Actions CI lint & tag-triggered ISO build workflow skeleton
- [ ] Complete `iso/archiso-profile/` baseline (`linux`, latest KDE Plasma 6, `virtualbox-guest-utils`, `vboxservice`)
- [ ] Verify first bootable `angelos-11-v0.0.1-x86_64.iso` inside VirtualBox on Windows

## `v0.1.0` — Core Windows 11 Desktop Fidelity
- [ ] **Taskbar**: Docked `48px` centered taskbar with Acrylic blur, `1px` top hairline, active pills, left Widgets, right Quick Settings + Clock
- [ ] **Start Menu**: Customized Plasma 6 QML Start Menu (`Menu 11 Next` / `Menu-11-Enhanced` fork) with Pinned, All Apps, Search, Recommended, and Power footer
- [ ] **Quick Settings & Notifications**: 3×2 toggle pill flyout + sliders + separated Notification/Calendar panel
- [ ] **Mica & Geometry**: `Klassy` Win11 titlebars, `Kvantum` Mica Light/Dark, `Fluent` GTK3/4 parity, `better-blur-dx`, `KDE-Rounded-Corners` (`8px` floating / `0px` maximized), and `Snap11` Snap Layouts
- [ ] **Dolphin & Shortcuts**: File Explorer layout preset, Selawik font, Win11 icons/cursors, and full Windows 11 keyboard shortcuts

## `v0.2.0` — Boot, Login, First-Boot OOBE & Calamares Installer
- [ ] **Plymouth & SDDM**: AngelOS 11 boot splash ring + `win11-sddm-theme` lock/login screen
- [ ] **First-Boot OOBE**: Light Mode / Dark Mode selector + accent color & initial setup wizard
- [ ] **Original Assets**: AngelOS wing/halo 4-pane emblem, AngelOS Bloom Light & Dark wallpapers, subtle ambient sound theme
- [ ] **Calamares Installer**: Windows 11 OOBE-styled installer creating **Btrfs + Snapper + `grub-btrfs` + GRUB**
- [ ] **Default Apps**: Microsoft Edge, KDE Discover + Flatpak (Flathub) + `paru`, Dolphin, Kate, Spectacle, Gwenview, Haruna, Ark, Plasma System Monitor, KCalc

## `v0.3.0` — Seamless Windows `.exe` / `.msi` Integration
- [ ] Bundle **Wine Staging + Winetricks + DXVK + VKD3D + `multilib` libraries**
- [ ] Implement **`angelos-wine-runner`** double-click handler for `.exe` / `.msi`
- [ ] Add Fluent launch toast notification & automatic Start Menu `.desktop` shortcut syncing

## `v1.0.0` — First Stable Release
- [ ] Full VirtualBox + bare-metal UEFI & BIOS QA pass
- [ ] Automated GitHub Releases publishing (`angelos-11-v1.0.0-x86_64.iso` + `.sha256`)
- [ ] Ongoing SemVer point releases (`1.0.1`, `1.1.0`, `1.1.2`, …) for Plasma updates and visual refinements
