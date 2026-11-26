#!/usr/bin/env bash
set -euo pipefail

# Apply AngelOS 11 layout using yeyushengfan258/Win11OS-kde (updated for latest Plasma 6)
# and exact Windows 11 taskbar layout. Usage: angelos-apply-layout [dark|light]

# Immediately delete one-shot autostart trigger so it never lingers or appears again.
rm -f "${HOME}/.config/autostart/angelos-win11-layout.desktop" || true

MODE="${1:-dark}"
ASSETS_DIR="/opt/angelos/desktop/assets"

# Detect default browser desktop ID (prefer Microsoft Edge, fallback to Chromium)
BROWSER_DESKTOP="preferred://browser"
if [[ -f /usr/share/applications/microsoft-edge.desktop ]]; then
    BROWSER_DESKTOP="applications:microsoft-edge.desktop"
    xdg-settings set default-web-browser microsoft-edge.desktop 2>/dev/null || true
    kwriteconfig6 --file kdeglobals --group General --key BrowserApplication "microsoft-edge.desktop" 2>/dev/null || true
elif [[ -f /usr/share/applications/chromium.desktop ]]; then
    BROWSER_DESKTOP="applications:chromium.desktop"
    xdg-settings set default-web-browser chromium.desktop 2>/dev/null || true
    kwriteconfig6 --file kdeglobals --group General --key BrowserApplication "chromium.desktop" 2>/dev/null || true
fi

if [[ "${MODE}" == "light" ]]; then
    LOOKFEEL_ID="com.github.yeyushengfan258.Win11OS-light"
    PLASMA_THEME="Win11OS-light"
    COLOR_SCHEME="Win11OSLight"
    KVANTUM_THEME="Win11OS-light"
    AURORAE_THEME="__aurorae__svg__Win11OS-light"
    ICON_THEME="Win11"
    WALLPAPER="${ASSETS_DIR}/angelos-bloom-light.svg"
else
    LOOKFEEL_ID="com.github.yeyushengfan258.Win11OS-dark"
    PLASMA_THEME="Win11OS-dark"
    COLOR_SCHEME="Win11OSDark"
    KVANTUM_THEME="Win11OS-dark"
    AURORAE_THEME="__aurorae__svg__Win11OS-dark"
    ICON_THEME="Win11-dark"
    WALLPAPER="${ASSETS_DIR}/angelos-bloom-dark.svg"
fi

if command -v kpackagetool6 >/dev/null 2>&1 && kpackagetool6 -t Plasma/LookAndFeel -l 2>/dev/null | grep -q "${LOOKFEEL_ID}"; then
    plasma-apply-lookandfeel -a "${LOOKFEEL_ID}" --resetLayout || true
    sleep 1
fi

if command -v plasma-apply-desktoptheme >/dev/null 2>&1; then
    plasma-apply-desktoptheme "${PLASMA_THEME}" || true
fi

if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
    plasma-apply-colorscheme "${COLOR_SCHEME}" || true
fi

if command -v plasma-apply-wallpaperimage >/dev/null 2>&1 && [[ -f "${WALLPAPER}" ]]; then
    plasma-apply-wallpaperimage "${WALLPAPER}" || true
fi

if command -v kwriteconfig6 >/dev/null 2>&1; then
    # Win11OS-kde Kvantum widget style, icons & cursors
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "kvantum"
    kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme "${KVANTUM_THEME}"
    if [[ -d "/usr/share/icons/${ICON_THEME}" ]]; then
        kwriteconfig6 --file kdeglobals --group Icons --key Theme "${ICON_THEME}"
        kwriteconfig6 --file kcmicons --group Icons --key Theme "${ICON_THEME}"
    elif [[ -d /usr/share/icons/Win11 ]]; then
        kwriteconfig6 --file kdeglobals --group Icons --key Theme "Win11"
        kwriteconfig6 --file kcmicons --group Icons --key Theme "Win11"
    fi
    if [[ -d /usr/share/icons/Win10OS-cursors ]]; then
        kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme "Win10OS-cursors"
    fi

    # Keep splash clean (avoid Plasma 5 splash artifacts)
    kwriteconfig6 --file ksplashrc --group KSplash --key Engine none
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme None

    # Win11OS Aurorae decoration with Windows 11 right-side buttons (Minimize, Maximize, Close)
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library "org.kde.kwin.aurorae"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "${AURORAE_THEME}"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSize "Tiny"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false

    # KWin Mica/Acrylic blur & contrast
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key windowapertureEnabled false
    kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 14
    kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 5

    # Short keyboard layout labels (ENG)
    kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames "en:ENG"

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

# Configure exact Windows 11 taskbar:
# [Widgets (left)] [spacer] [Start] [Search pill] [Pinned Apps] [spacer] [ENG] [Tray ^ + Net/Vol/Bat] [2-line Clock] [Bell] [Show Desktop sliver]
if command -v gdbus >/dev/null 2>&1; then
    PLASMA_JS=$(cat <<EOF
function pick(custom, stock) {
    return knownWidgetTypes.indexOf(custom) >= 0 ? custom : stock;
}

var existing = panels();
for (var i = 0; i < existing.length; i++) {
    existing[i].remove();
}

var panel = new Panel();
panel.location = "bottom";
panel.height = 48;
panel.alignment = "center";
panel.floating = false;
panel.hiding = "none";
panel.lengthMode = "fill";

// Far left: AngelOS Widgets pill
if (knownWidgetTypes.indexOf("org.angelos.widgets") >= 0) {
    panel.addWidget("org.angelos.widgets");
}

// Left expanding spacer
panel.addWidget("org.kde.plasma.panelspacer");

// Center: Menu 11 Next Start Menu + Search pill + Pinned/Running Apps
var start = panel.addWidget(pick("menu.11.next", "org.kde.plasma.kickoff"));
start.currentConfigGroup = ["General"];
start.writeConfig("icon", "/opt/angelos/desktop/assets/angelos-start-icon.svg");
start.writeConfig("useCustomButtonImage", true);
start.writeConfig("customButtonImage", "/opt/angelos/desktop/assets/angelos-start-icon.svg");
start.writeConfig("showActionButtonCaptions", false);
start.writeConfig("favoriteApps", [
    "${BROWSER_DESKTOP}",
    "applications:org.kde.dolphin.desktop",
    "applications:org.kde.discover.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop",
    "applications:org.kde.kate.desktop",
    "applications:org.kde.spectacle.desktop"
].join(","));

if (knownWidgetTypes.indexOf("org.angelos.search") >= 0) {
    panel.addWidget("org.angelos.search");
}

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "${BROWSER_DESKTOP}",
    "applications:org.kde.discover.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop"
].join(","));
tasks.writeConfig("showOnlyCurrentScreen", false);
tasks.writeConfig("showOnlyCurrentDesktop", false);
tasks.writeConfig("showOnlyCurrentActivity", false);
tasks.writeConfig("groupingStrategy", 1);

// Right expanding spacer
panel.addWidget("org.kde.plasma.panelspacer");

// Far right (Windows 11 order): Language -> System Tray (^ + Net/Vol/Bat) -> 2-line Clock -> Notification Bell -> Show Desktop sliver
if (knownWidgetTypes.indexOf("org.kde.plasma.keyboardlayout") >= 0) {
    panel.addWidget("org.kde.plasma.keyboardlayout");
}

var tray = panel.addWidget("org.kde.plasma.systemtray");
tray.currentConfigGroup = ["General"];
tray.writeConfig("showAllItems", false);
tray.writeConfig("scaleIconsToFit", false);
tray.writeConfig("hiddenItems", [
    "org.kde.plasma.clipboard",
    "org.kde.plasma.brightness",
    "org.kde.plasma.nightcolor",
    "org.kde.plasma.notifications",
    "org.kde.discovernotifier",
    "org.kde.plasma.devicenotifier",
    "org.kde.plasma.mediacontroller",
    "org.kde.kscreen",
    "org.kde.plasma.keyboardlayout"
].join(","));
tray.writeConfig("shownItems", [
    "org.kde.plasma.networkmanagement",
    "org.kde.plasma.volume",
    "org.kde.plasma.battery"
].join(","));

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("autoFontAndSize", false);
clock.writeConfig("fontSize", 9);
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", 2);
clock.writeConfig("showSeconds", 0);
clock.writeConfig("use24hFormat", 1);

if (knownWidgetTypes.indexOf("org.kde.plasma.notifications") >= 0) {
    panel.addWidget("org.kde.plasma.notifications");
}

var peek = panel.addWidget(pick("org.angelos.showdesktop", "org.kde.plasma.showdesktop"));
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

mkdir -p "${HOME}/.config"
touch "${HOME}/.config/angelos-layout-done"
