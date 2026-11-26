# Windows 11 Fidelity Specification (Latest KDE Plasma 6)

This specification defines the exact visual, layout, and behavioral targets for **AngelOS 11** across all five top-priority fidelity pillars.

---

## 1. Taskbar, Start Menu & Quick Settings

| Component | Target Specification |
| :--- | :--- |
| **Taskbar Geometry** | Full-width docked bottom panel (**not floating**), **`48px`** height, Acrylic translucent blur, `1px` subtle top edge hairline (`#FFFFFF` at ~12% Dark / `#000000` at ~8% Light). |
| **Taskbar Zones** | **Left**: Widgets/Weather pill. **Center**: AngelOS 4-pane wing Start button, Search pill/button, Task View, Pinned & Running app icons (`24px` icons on `40px` tiles, `4px` corner radius). **Right**: Overflow chevron (`^`), unified **Network + Volume + Battery** Quick Settings button, 2-line **Time / Date** button, far-right Show Desktop sliver (`8px`). |
| **Active App Indicators** | Focused app: wide rounded pill (`16px` × `3px`) in Accent color; Open unfocused app: compact dot/pill (`6px` × `3px`). |
| **Start Menu** | Centered floating Acrylic popup (`640px` × `720px` target, `8px` radius, `12px` bottom gap), rounded Search input at top, **Pinned** icon grid + `All apps >` toggle, **Recommended** recent items, bottom footer strip with circular user avatar + Power menu. |
| **Quick Settings Flyout** | Separate from Calendar/Notifications (`360px` wide, `8px` radius): **3×2** toggle pill grid (Wi-Fi, Bluetooth, Night Light, Power Mode, Do Not Disturb, Accessibility/Output), Brightness & Volume sliders, Battery status, Edit/Settings footer. |
| **Notification Center** | Opens on Time/Date click: stacked notification cards above a clean compact month calendar. |

---

## 2. Mica / Acrylic Blur, Geometry & Snap Layouts

- **Window Corner Radius**: `8px` on normal floating windows; **`0px`** when maximized or snapped to edges.
- **Window Border**: `1px` crisp outline (subtle translucent light/dark border so overlapping windows never visually merge).
- **Titlebar (`Klassy`)**: `32px` height, Windows 11 caption button order on right (`─` Minimize, `□` Maximize/Restore, `✕` Close with `#C42B1C` red hover fill).
- **Mica vs. Acrylic**:
  - **Mica**: Subtle wallpaper-tinted base for application backdrops (Dolphin, Settings, Kvantum windows).
  - **Acrylic**: Stronger frosted background blur + noise texture for transient overlays (Start Menu, Taskbar, Quick Settings, Context Menus).
- **Snap Layouts**: Triggered by hovering the Maximize button (`□`) or dragging a window to the top edge; Snap Assist shows remaining open window thumbnails in adjacent zones.

---

## 3. Dolphin File Explorer & Context Menus

- **Left Navigation Pane**: Mica backdrop, sections matching Windows 11:
  - *Home / Quick Access* (pinned folders)
  - *Desktop, Downloads, Documents, Pictures, Music, Videos*
  - *This PC* (mounted drives & storage bars)
- **Top Chrome**: Tab bar at the very top (`36px`), clean breadcrumb/path bar + Search box below it, and an uncluttered **Command Bar** (`+ New`, `Cut`, `Copy`, `Paste`, `Rename`, `Share`, `Delete`, `Sort`, `View`).
- **Context Menus**: `8px` rounded Acrylic menus with generous row height (`32px`), clean icons, and compact top action icons where supported.

---

## 4. Exact Windows 11 Keyboard Shortcuts

| Shortcut | Action | KDE Target |
| :--- | :--- | :--- |
| `Meta` | Toggle Start Menu | AngelOS Start Menu |
| `Meta + E` | Open File Explorer | Dolphin |
| `Meta + D` | Show Desktop | KWin MinimizeAll / Show Desktop |
| `Meta + L` | Lock Screen | `loginctl lock-session` (SDDM/KScreenLocker) |
| `Meta + I` | Open Settings | `systemsettings` |
| `Meta + V` | Clipboard History | Klipper popup at cursor |
| `Meta + Tab` | Task View | KWin Overview |
| `Meta + Shift + S` | Snipping Tool | `spectacle -r` (Region capture) |
| `Ctrl + Shift + Esc` | Task Manager | `plasma-systemmonitor` |
| `Meta + Left / Right / Up / Down` | Window Snapping | KWin Quick Tile Left/Right/Max/Min |
| `Meta + .` | Emoji Picker | Plasma Emoji Selector |

---

## 5. Boot, Login, OOBE, Fonts & Sound

- **Typography**: **Selawik** (SIL OFL Segoe UI metric-compatible sans-serif) for UI + **Inter** / **Cascadia Code** for monospace/terminal.
- **Plymouth Boot**: Solid dark background (`#000000`), centered **AngelOS 11** subtle wing/4-pane mark, smooth white spinning arc ring below.
- **SDDM Login/Lock**: Full-screen blurred AngelOS Bloom wallpaper, clock curtain -> circular user avatar, pill password box with eye toggle, bottom-right Network / Accessibility / Power buttons.
- **First-Boot OOBE**: Guided welcome screen allowing the user to pick **Light Mode** or **Dark Mode**, select an accent color, and verify Microsoft Edge / Flathub / Wine readiness.
- **Sound Theme**: Original gentle ambient chimes inspired by Windows 11's soft acoustic palette (startup, notification, USB connect/disconnect, critical alert).
