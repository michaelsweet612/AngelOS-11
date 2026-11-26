#!/usr/bin/env bash
set -euo pipefail

# Apply AngelOS 11 Windows 11 layout, themes, shortcuts, KWin blur, and exact Win11 taskbar
# on the latest KDE Plasma 6 (Wayland). Usage: angelos-apply-layout [dark|light]

# Immediately delete one-shot autostart trigger so it never lingers or appears again.
rm -f "${HOME}/.config/autostart/angelos-win11-layout.desktop" || true

MODE="${1:-dark}"
ASSETS_DIR="/opt/angelos/desktop/assets"
COLOR_SRC_DIR="/opt/angelos/desktop/plasma-look-and-feel"
COLOR_DST_DIR="${HOME}/.local/share/color-schemes"

mkdir -p "${COLOR_DST_DIR}"
cp -f "${COLOR_SRC_DIR}/AngelOS11Dark.colors" "${COLOR_DST_DIR}/"
cp -f "${COLOR_SRC_DIR}/AngelOS11Light.colors" "${COLOR_DST_DIR}/"

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
    LOOKFEEL_ID="org.kde.windowsmodern.light"
    PLASMA_THEME="Windows-modern-light"
    COLOR_SCHEME="AngelOS11Light"
    KVANTUM_STYLE="kvantum"
    WALLPAPER="${ASSETS_DIR}/angelos-bloom-light.svg"
else
    LOOKFEEL_ID="org.kde.windowsmodern.dark"
    PLASMA_THEME="Windows-modern-dark"
    COLOR_SCHEME="AngelOS11Dark"
    KVANTUM_STYLE="kvantum-dark"
    WALLPAPER="${ASSETS_DIR}/angelos-bloom-dark.svg"
fi

# Apply Windows Modern Global Theme if installed, then layer AngelOS branding & custom taskbar
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
    # Kvantum Mica widget style & Windows Modern icons
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "${KVANTUM_STYLE}"
    kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme "Windows-modern"
    if [[ -d /usr/share/icons/windows-modern ]]; then
        kwriteconfig6 --file kdeglobals --group Icons --key Theme "windows-modern"
        kwriteconfig6 --file kcmicons --group Icons --key Theme "windows-modern"
    fi
    if [[ -d /usr/share/icons/Win10OS-cursors ]]; then
        kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme "Win10OS-cursors"
    fi

    # Disable splash screen override from lookandfeel
    kwriteconfig6 --file ksplashrc --group KSplash --key Engine none
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme None

    # Windows 11 titlebar buttons (Right: Minimize, Maximize, Close) & Tiny borders
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSize "Tiny"
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false

    # KWin Mica/Acrylic blur, contrast, Alt+Tab switcher & clean Show Desktop
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key windowapertureEnabled false
    kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 14
    kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 5
    kwriteconfig6 --file kwinrc --group TabBox --key MultiScreenMode 1
    if [[ -d /usr/share/kwin/tabbox/org.kde.windowsmodern.alttab ]]; then
        kwriteconfig6 --file kwinrc --group TabBox --key LayoutName "org.kde.windowsmodern.alttab"
    fi

    # Short keyboard layout labels (ENG US)
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
# [Widgets (left)] [spacer] [Start] [Search] [Task View] [Pinned Apps] [spacer] [Win11 Tray] [Win11 Clock+Bell] [Show Desktop Sliver]
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

// Center: Start + Search pill + Task View + Icon Tasks
var startId = pick("org.kde.windowsmodern.startmenu", "org.kde.plasma.kickoff");
var start = panel.addWidget(startId);
start.currentConfigGroup = ["General"];
start.writeConfig("icon", "/opt/angelos/desktop/assets/angelos-start-icon.svg");
start.writeConfig("useCustomButtonImage", true);
start.writeConfig("customButtonImage", "/opt/angelos/desktop/assets/angelos-start-icon.svg");
start.writeConfig("showActionButtonCaptions", false);

if (knownWidgetTypes.indexOf("org.kde.windowsmodern.search") >= 0) {
    panel.addWidget("org.kde.windowsmodern.search");
}

if (knownWidgetTypes.indexOf("org.kde.windowsmodern.taskview") >= 0) {
    panel.addWidget("org.kde.windowsmodern.taskview");
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

// Far right: Win11 System Tray + Win11 2-line Clock/Bell + Thin Show Desktop sliver
var tray = panel.addWidget(pick("org.kde.windowsmodern.systemtray", "org.kde.plasma.systemtray"));
tray.currentConfigGroup = ["General"];
tray.writeConfig("showAllItems", false);
tray.writeConfig("scaleIconsToFit", false);
tray.writeConfig("hiddenItems", [
    "org.kde.plasma.clipboard",
    "org.kde.plasma.brightness",
    "org.kde.plasma.nightcolor",
    "org.kde.discovernotifier",
    "org.kde.plasma.devicenotifier",
    "org.kde.plasma.mediacontroller"
].join(","));

var clock = panel.addWidget(pick("org.kde.windowsmodern.digitalclock", "org.kde.plasma.digitalclock"));
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("autoFontAndSize", true);
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", 2);
clock.writeConfig("showSeconds", 0);
clock.writeConfig("use24hFormat", 1);
clock.writeConfig("expandedWidth", 320);

var peek = panel.addWidget(pick("org.kde.windowsmodern.showdesktop", "org.kde.plasma.showdesktop"));
peek.currentConfigGroup = ["General"];
peek.writeConfig("size", 6);
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
