# AngelOS 11 Windows Compatibility (`compat/wine`)

This directory will house the **Wine Staging + Winetricks + DXVK + VKD3D** integration:

- `angelos-wine-runner` — Wrapper script & Fluent toast notification (`notify-send` / Plasma notification) when double-clicking `.exe` or `.msi` files
- `mime/` — XDG MIME associations (`application/x-ms-dos-executable`, `application/x-msi`)
- `prefix/` — Pre-tuned default 64-bit Wine prefix template (`win11` mode, DPI scaling, DXVK/VKD3D DLL overrides)
- `shortcut-sync/` — Automatic `.desktop` shortcut syncing so installed Windows apps appear cleanly in the AngelOS Start Menu
