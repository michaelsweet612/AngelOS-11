# AngelOS 11

**AngelOS 11** is an **Arch Linux**-based operating system engineered to deliver the visual polish, ergonomics, animations, and familiar workflows of **Windows 11** on top of the **latest KDE Plasma 6 (Wayland)** — paired with seamless **Windows `.exe`/`.msi` support** and **Btrfs + Snapper** system restore rollbacks.

> **Current Version:** `0.0.1` *(Phase 0 — Repository & Build Foundation)*  
> **License:** GPL-3.0

---

## Core Design Goals

1. **Maximum Windows 11 Fidelity (Latest KDE Plasma 6 + Wayland)**
   - **48px Docked Centered Taskbar** with Acrylic translucency, `1px` top hairline border, centered pinned/running icons, left Widgets pill, and unified right Quick Settings + Notification/Calendar area.
   - **Windows 11 Start Menu** (`Menu 11 Next` / `Menu-11-Enhanced` customization) with rounded search bar, Pinned grid, All Apps view, Recommended section, and User/Power footer.
   - **Mica / Acrylic Materials & Geometry** powered by `Klassy`, `Kvantum` Qt6, `Fluent` GTK3/4 parity, `kwin-effects-better-blur-dx`, and `KDE-Rounded-Corners` (`8px` radius, disabled when maximized).
   - **Snap Layouts & Snap Assist** on top-edge drag and maximize-button hover.
   - **Dolphin Configured as File Explorer** (Quick Access, command bar, tabs, Mica sidebar) + Windows 11 keyboard shortcuts (`Meta+E`, `Meta+V`, `Meta+Shift+S`, `Ctrl+Shift+Esc`, etc.).
   - **Subtle AngelOS Identity** blending the 4-pane Fluent aesthetic with an AngelOS wing/halo emblem, custom AngelOS Bloom wallpapers, and a **first-boot OOBE Light/Dark mode picker**.

2. **Seamless Windows App Compatibility**
   - Pre-configured **Wine Staging + Winetricks + DXVK + VKD3D** with 32-bit `multilib` libraries.
   - Double-click `.exe` and `.msi` execution with a Fluent launch toast and automatic Start Menu shortcut sync.

3. **Arch Linux Core & Windows-Style System Restore**
   - Standard Arch **`linux`** kernel (`x86_64`, `multilib` enabled).
   - **Calamares** installer styled after the Windows 11 OOBE, setting up **Btrfs + Snapper + `grub-btrfs` + GRUB** for bootable system snapshots.
   - Out-of-the-box essentials: **Microsoft Edge for Linux**, **KDE Discover + Flatpak (Flathub) + AUR (`paru`)**, and KDE core equivalents (**Dolphin**, **Kate**, **Spectacle**, **Gwenview**, **Haruna**, **Ark**, **Plasma System Monitor**, **KCalc**).

---

## Repository Structure

```text
AngelOS-11/
├── VERSION                         # SemVer source of truth (e.g. 0.0.1 -> 0.1.0 -> 1.0.0)
├── README.md
├── LICENSE                         # GNU GPL v3.0
├── CHANGELOG.md
├── CONTRIBUTING.md
├── docs/                           # Architecture, Win11 fidelity spec, roadmap, VirtualBox guide
├── packages/pkgbuilds/             # Custom Arch PKGBUILDs & latest Plasma 6 KWin plugin builds
├── desktop/                        # Plasma Look-and-Feel, plasmoids, KWin, Kvantum, GTK, SDDM, Plymouth, OOBE
├── compat/wine/                    # Wine Staging + DXVK/VKD3D runner & MIME integration
├── iso/                            # archiso profile & Calamares installer configs
└── scripts/                        # SemVer bump, VirtualBox test helper, VM bootstrapper, ISO builder
```

---

## Quick Start (Development & Testing on Windows + VirtualBox)

See [docs/VIRTUALBOX_TESTING.md](docs/VIRTUALBOX_TESTING.md) for the full guide.

### Option A: Create & Boot a VirtualBox Test VM (PowerShell)
```powershell
.\scripts\vbox-test.ps1 -IsoPath "C:\Users\Michael\Desktop\archlinux-2026.11.01-x86_64.iso"
```

### Option B: Build a Versioned AngelOS 11 ISO (Linux / Arch Container)
```bash
sudo ./scripts/build-iso.sh
```
Output is written as `out/angelos-11-v<VERSION>-x86_64.iso` (driven by [`VERSION`](VERSION)).

### Semantic Versioning & Automated Releases
- Bump versions cleanly using `.\scripts\bump-version.ps1 -Part patch|minor|major`.
- Pushing a SemVer tag (`git tag v0.1.0 && git push origin v0.1.0`) triggers the GitHub Actions ISO build workflow.

---

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Windows 11 Fidelity Specification](docs/WIN11_FIDELITY_SPEC.md)
- [Release Roadmap (`0.0.1` -> `1.0.0+`)](docs/ROADMAP.md)
- [VirtualBox Testing Guide](docs/VIRTUALBOX_TESTING.md)
