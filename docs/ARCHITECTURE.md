# AngelOS 11 Architecture

## Overview

AngelOS 11 is built on **Arch Linux (`x86_64`)** using the standard **`linux`** kernel with **`multilib`** enabled, the **latest KDE Plasma 6 (Wayland)** for the desktop shell, **Wine Staging + DXVK/VKD3D** for Windows application compatibility, and **Calamares** installing onto **Btrfs + Snapper + GRUB**.

```text
+-------------------------------------------------------------------+
|                        User Applications                          |
|  Microsoft Edge | Dolphin Explorer | Discover/Flatpak | Wine .exe |
+-------------------------------------------------------------------+
|                    AngelOS 11 Shell & Branding                    |
|  48px Taskbar | Start Menu | Quick Settings | OOBE | Win11 Keys   |
+-------------------------------------------------------------------+
|               Latest KDE Plasma 6 + KWin (Wayland)                |
|  Klassy | Kvantum Mica | Fluent GTK3/4 | Better Blur DX | Snap11  |
+-------------------------------------------------------------------+
|                    Boot, Display & Packaging                      |
|  Plymouth | SDDM | Calamares (Btrfs + Snapper + grub-btrfs)       |
+-------------------------------------------------------------------+
|                    Arch Linux Base (linux kernel)                 |
+-------------------------------------------------------------------+
```

---

## Core Subsystems

### 1. Base System & Storage (`iso/archiso-profile/` + `iso/calamares/`)
- **Kernel**: Standard `linux` + `linux-headers` + `linux-firmware`.
- **Repositories**: Arch `core`, `extra`, `multilib` (needed for 32-bit Wine/DXVK dependencies).
- **Root Filesystem**: **Btrfs** with standard subvolumes (`@`, `@home`, `@log`, `@pkg`, `@.snapshots`) configured by Calamares.
- **System Restore**: **Snapper** + **`snap-pac`** + **`grub-btrfs`** so updates automatically create rollback snapshots accessible directly from GRUB, similar to Windows System Restore.

### 2. Display & Compositor (`desktop/kwin/`, `desktop/kvantum/`, `desktop/gtk/`)
- **Compositor**: Latest **KDE Plasma 6** release from Arch repos running on **KWin Wayland** (with XWayland for Wine & legacy X11 apps).
- **Window Decorations**: **Klassy** (`qt6`) configured for Windows 11 `32px` titlebars, `1px` borders, and exact caption glyphs.
- **Blur & Corners**: `kwin-effects-better-blur-dx` + `KDE-Rounded-Corners` (`8px` radius, disabled when maximized).
- **Qt / GTK Parity**: `Kvantum` Qt6 Mica Light/Dark themes paired with matching Fluent GTK3/GTK4 themes.

### 3. Desktop Shell & Plasmoids (`desktop/plasmoids/`, `desktop/plasma-look-and-feel/`)
- **Start Menu**: Customized Plasma 6 QML launcher based on `Eisteed/menu-11-next` / `kurojs/Menu-11-Enhanced`.
- **System Tray / Quick Settings**: Adapted from `Jeysef/KDE-Windows-Modern` and `RaceConditionWinner/Kde-windows-system-tray` for current Plasma 6.
- **Snap Layouts**: `garpu-ng/snap11` or `IamAndelib/kde-snap-overlay` integrated with KWin tiling.
- **First-Boot OOBE**: Qt6/QML wizard (`desktop/oobe/`) allowing Light/Dark mode selection, accent color choice, and initial Wine/Flathub setup.

### 4. Windows Compatibility Layer (`compat/wine/`)
- **Stack**: `wine-staging`, `winetricks`, `dxvk-bin`, `vkd3d`, `wine-mono`, `wine-gecko`.
- **Runner**: `angelos-wine-runner` associates `.exe` and `.msi` MIME types, displays a Fluent launch toast notification, runs apps in a tuned 64-bit/32-bit prefix, and syncs installed `.desktop` shortcuts into the Start Menu.
