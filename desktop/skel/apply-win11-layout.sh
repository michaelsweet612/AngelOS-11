#!/usr/bin/env bash
set -euo pipefail

# Apply AngelOS 11 Windows 11 layout, colors, shortcuts, KWin blur, and 48px centered taskbar
# on KDE Plasma 6 (Wayland). Usage: apply-win11-layout.sh [dark|light]

MODE="${1:-dark}"
ASSETS_DIR="/opt/angelos/desktop/assets"
COLOR_SRC_DIR="/opt/angelos/desktop/plasma-look-and-feel"
COLOR_DST_DIR="${HOME}/.local/share/color-schemes"

mkdir -p "${COLOR_DST_DIR}"
cp -f "${COLOR_SRC_DIR}/AngelOS11Dark.colors" "${COLOR_DST_DIR}/"
cp -f "${COLOR_SRC_DIR}/AngelOS11Light.colors" "${COLOR_DST_DIR}/"

if [[ "${MODE}" == "light" ]]; then
    SCHEME="AngelOS11Light"
    WALLPAPER="${ASSETS_DIR}/angelos-bloom-light.svg"
else
    SCHEME="AngelOS11Dark"
    WALLPAPER="${ASSETS_DIR}/angelos-bloom-dark.svg"
fi

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    plasma-apply-colorscheme "${SCHEME}" || true
fi

if command -v plasma-apply-wallpaperimage >/dev/null 2>&1 && [[ -f "${WALLPAPER}" ]]; then
    plasma-apply-wallpaperimage "${WALLPAPER}" || true
fi

if command -v kwriteconfig6 >/dev/null 2>&1; then
    # Titlebar buttons matching Windows 11 (Right: Minimize, Maximize, Close)
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"

    # KWin Mica/Acrylic blur & contrast
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled true
    kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 14
    kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 5

    # Exact Windows 11 keyboard shortcuts
    kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Show Desktop" "Meta+D,Meta+D,Show Desktop"
    kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Overview" "Meta+Tab\tMeta+W,Meta+W,Toggle Overview"
    kwriteconfig6 --file kglobalshortcutsrc --group smserver --key "Lock Session" "Meta+L\tScreensaver,Meta+L,Lock Session"
    kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "clipboard_action" "none,,Automatic Action Popup Menu"
    kwriteconfig6 --file kglobalshortcutsrc --group org.kde.klipper.desktop --key "show-on-mouse-pos" "Meta+V,Meta+V,Open Klipper at Mouse Position"
    kwriteconfig6 --file kglobalshortcutsrc --group org.kde.dolphin.desktop --key "_launch" "Meta+E,none,Dolphin"
    kwriteconfig6 --file kglobalshortcutsrc --group org.kde.spectacle.desktop --key "RectangularRegionScreenShot" "Meta+Shift+S,Meta+Shift+Print,Capture Rectangular Region"
    kwriteconfig6 --file kglobalshortcutsrc --group org.kde.plasma-systemmonitor.desktop --key "_launch" "Ctrl+Shift+Esc,none,System Monitor"
    kwriteconfig6 --file kglobalshortcutsrc --group systemsettings.desktop --key "_launch" "Meta+I,none,System Settings"
fi

# Configure 48px docked centered Windows 11 taskbar via PlasmaShell scripting
if command -v gdbus >/dev/null 2>&1; then
    PLASMA_JS=$(cat <<'EOF'
var existing = panels();
for (var i = 0; i < existing.length; i++) {
    existing[i].remove();
}

var panel = new Panel();
panel.location = "bottom";
panel.height = 48;
panel.floating = false;
panel.hiding = "none";

var leftSpacer = panel.addWidget("org.kde.plasma.panelspacer");
leftSpacer.currentConfigGroup = ["General"];
leftSpacer.writeConfig("expanding", true);

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/opt/angelos/desktop/assets/angelos-start-icon.svg");
launcher.writeConfig("showActionButtonCaptions", false);

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:org.kde.discover.desktop",
    "applications:systemsettings.desktop"
].join(","));
tasks.writeConfig("groupingStrategy", 1);

var rightSpacer = panel.addWidget("org.kde.plasma.panelspacer");
rightSpacer.currentConfigGroup = ["General"];
rightSpacer.writeConfig("expanding", true);

panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");
EOF
)
    gdbus call --session \
        --dest org.kde.plasmashell \
        --object-path /PlasmaShell \
        --method org.kde.PlasmaShell.evaluateScript "${PLASMA_JS}" >/dev/null 2>&1 || true

    gdbus call --session \
        --dest org.kde.KWin \
        --object-path /KWin \
        --method org.kde.KWin.reconfigure >/dev/null 2>&1 || true
fi

# Remove one-shot layout autostart once applied
rm -f "${HOME}/.config/autostart/angelos-win11-layout.desktop" || true
