#!/usr/bin/env bash
set -euo pipefail

# Build a versioned AngelOS 11 ISO using mkarchiso.
# - Stages from /usr/share/archiso/configs/releng so bootmodes & hooks track latest archiso.
# - Compiles Windows 11 C++/QML Plasma 6 components against the latest Arch Plasma 6 ABI.
# - Builds Microsoft Edge & Selawik font from AUR into a local pacman repo (with Chromium fallback).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE_OVERRIDES="${REPO_ROOT}/iso/archiso-profile"
WORK_DIR="${WORK_DIR:-${REPO_ROOT}/work}"
OUT_DIR="${OUT_DIR:-${REPO_ROOT}/out}"
RELENG_DIR="/usr/share/archiso/configs/releng"

if [[ ${EUID} -ne 0 ]]; then
    echo "Error: build-iso.sh must be run as root (mkarchiso requires root)." >&2
    exit 1
fi

if ! command -v mkarchiso >/dev/null 2>&1; then
    echo "Error: mkarchiso not found. Install 'archiso' first (pacman -S archiso)." >&2
    exit 1
fi

if [[ ! -d "${RELENG_DIR}" ]]; then
    echo "Error: Upstream archiso releng profile not found at ${RELENG_DIR}." >&2
    exit 1
fi

VERSION_VAL="${ANGELOS_VERSION:-$(tr -d '[:space:]' < "${REPO_ROOT}/VERSION")}"
if [[ ! "${VERSION_VAL}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
    echo "Error: Invalid SemVer '${VERSION_VAL}'." >&2
    exit 1
fi

export ANGELOS_VERSION="${VERSION_VAL}"

STAGED_PROFILE="${WORK_DIR}/profile"
ARCHISO_WORK="${WORK_DIR}/archiso"
LOCAL_REPO="${WORK_DIR}/angelos-repo"
WM_DIR="${WORK_DIR}/kde-windows-modern"
AUR_WORK="${WORK_DIR}/aur"

mkdir -p "${WORK_DIR}" "${OUT_DIR}" "${LOCAL_REPO}" "${AUR_WORK}"
rm -rf "${STAGED_PROFILE}" "${ARCHISO_WORK}" "${WM_DIR}"

echo "==> Installing Plasma 6 build dependencies & AUR tools in build environment..."
pacman -Syu --noconfirm --needed \
    base-devel git cmake extra-cmake-modules gcc \
    qt6-base qt6-declarative kpackage kconfig ki18n kwindowsystem kio \
    kiconthemes kitemmodels kservice kxmlgui kglobalaccel kjobwidgets kcmutils \
    knotifications plasma-activities plasma-activities-stats libplasma \
    plasma-workspace libksysguard

echo "==> Staging archiso profile from ${RELENG_DIR}..."
cp -a "${RELENG_DIR}" "${STAGED_PROFILE}"
cp -a "${PROFILE_OVERRIDES}/." "${STAGED_PROFILE}/"

# Brand boot menus as AngelOS 11
for cfg_dir in efiboot syslinux grub; do
    if [[ -d "${STAGED_PROFILE}/${cfg_dir}" ]]; then
        find "${STAGED_PROFILE}/${cfg_dir}" -type f \( -name "*.cfg" -o -name "*.conf" \) -exec \
            sed -i "s/Arch Linux/AngelOS 11/g" {} +
    fi
done

# Build AUR packages (Microsoft Edge + Selawik font) into local pacman repo
if ! id -u builder >/dev/null 2>&1; then
    useradd -m -s /bin/bash builder
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-angelos-builder
    chmod 440 /etc/sudoers.d/99-angelos-builder
fi
chown -R builder:builder "${AUR_WORK}"

build_aur_pkg() {
    local pkg_name="$1"
    local pkg_dir="${AUR_WORK}/${pkg_name}"
    rm -rf "${pkg_dir}"
    if su - builder -c "git clone --depth=1 https://aur.archlinux.org/${pkg_name}.git '${pkg_dir}' && cd '${pkg_dir}' && makepkg -s --noconfirm --skippgpcheck"; then
        cp -f "${pkg_dir}"/*.pkg.tar.zst "${LOCAL_REPO}/" 2>/dev/null || true
        return 0
    fi
    return 1
}

if build_aur_pkg "microsoft-edge-stable-bin"; then
    echo "microsoft-edge-stable-bin" >> "${STAGED_PROFILE}/packages.x86_64"
else
    echo "Warning: AUR build for microsoft-edge-stable-bin failed; falling back to chromium."
    echo "chromium" >> "${STAGED_PROFILE}/packages.x86_64"
fi

if build_aur_pkg "ttf-selawik"; then
    echo "ttf-selawik" >> "${STAGED_PROFILE}/packages.x86_64"
fi

if ls "${LOCAL_REPO}"/*.pkg.tar.zst >/dev/null 2>&1; then
    repo-add "${LOCAL_REPO}/angelos.db.tar.gz" "${LOCAL_REPO}"/*.pkg.tar.zst
    cat >> "${STAGED_PROFILE}/pacman.conf" <<EOF

[angelos]
SigLevel = Optional TrustAll
Server = file://${LOCAL_REPO}
EOF
fi

# Compile & install Windows Modern Plasma 6 components into airootfs
echo "==> Fetching and building KDE-Windows-Modern Plasma 6 shell components..."
git clone --depth=1 https://github.com/Jeysef/KDE-Windows-Modern.git "${WM_DIR}"

QT_PLUGIN_REL="usr/lib/qt6/plugins"
if command -v qtpaths6 >/dev/null 2>&1; then
    QT_PLUGIN_RAW="$(qtpaths6 --query QT_INSTALL_PLUGINS)"
    QT_PLUGIN_REL="${QT_PLUGIN_RAW#/}"
fi

AIROOTFS="${STAGED_PROFILE}/airootfs"
PLUGIN_DST="${AIROOTFS}/${QT_PLUGIN_REL}/plasma/applets"
mkdir -p "${PLUGIN_DST}" \
    "${AIROOTFS}/usr/share/plasma/plasmoids" \
    "${AIROOTFS}/usr/share/plasma/desktoptheme" \
    "${AIROOTFS}/usr/share/plasma/look-and-feel" \
    "${AIROOTFS}/usr/share/plasma/layout-templates" \
    "${AIROOTFS}/usr/share/plasma/shells" \
    "${AIROOTFS}/usr/share/aurorae/themes" \
    "${AIROOTFS}/usr/share/color-schemes" \
    "${AIROOTFS}/usr/share/Kvantum" \
    "${AIROOTFS}/usr/share/icons" \
    "${AIROOTFS}/usr/share/kwin/tabbox"

for cpp_applet in org.kde.windowsmodern.systemtray org.kde.windowsmodern.icontasks; do
    APP_SRC="${WM_DIR}/plasma/applets/${cpp_applet}"
    if [[ -d "${APP_SRC}" ]]; then
        cmake -S "${APP_SRC}" -B "${APP_SRC}/build" -DCMAKE_BUILD_TYPE=Release
        cmake --build "${APP_SRC}/build" --parallel "$(nproc)"
        find "${APP_SRC}/build" -type f -name "*.so" -exec cp -f {} "${PLUGIN_DST}/" \;
    fi
done

for qml_applet in \
    org.kde.windowsmodern.startmenu \
    org.kde.windowsmodern.search \
    org.kde.windowsmodern.taskview \
    org.kde.windowsmodern.digitalclock \
    org.kde.windowsmodern.showdesktop; do
    if [[ -d "${WM_DIR}/plasma/applets/${qml_applet}" ]]; then
        cp -a "${WM_DIR}/plasma/applets/${qml_applet}" "${AIROOTFS}/usr/share/plasma/plasmoids/"
    fi
done

cp -a "${WM_DIR}/plasma/desktoptheme/." "${AIROOTFS}/usr/share/plasma/desktoptheme/"
cp -a "${WM_DIR}/plasma/look-and-feel/." "${AIROOTFS}/usr/share/plasma/look-and-feel/"
cp -a "${WM_DIR}/plasma/layout-templates/." "${AIROOTFS}/usr/share/plasma/layout-templates/"
if [[ -d "${WM_DIR}/plasma/shells" ]]; then
    cp -a "${WM_DIR}/plasma/shells/." "${AIROOTFS}/usr/share/plasma/shells/"
fi
cp -a "${WM_DIR}/aurorae/." "${AIROOTFS}/usr/share/aurorae/themes/"
cp -a "${WM_DIR}/color-schemes/"*.colors "${AIROOTFS}/usr/share/color-schemes/"
cp -a "${WM_DIR}/Kvantum/." "${AIROOTFS}/usr/share/Kvantum/"
cp -a "${WM_DIR}/icons/." "${AIROOTFS}/usr/share/icons/"
if [[ -d "${WM_DIR}/plasma/windowswitcher" ]]; then
    cp -a "${WM_DIR}/plasma/windowswitcher/." "${AIROOTFS}/usr/share/kwin/tabbox/"
fi

# Bundle Win10OS-cursors (GPL-3.0) if reachable
CURSOR_SRC="${WORK_DIR}/win10os-cursors"
rm -rf "${CURSOR_SRC}"
if git clone --depth=1 https://github.com/yeyushengfan258/Win10OS-cursors.git "${CURSOR_SRC}" && [[ -d "${CURSOR_SRC}/dist" ]]; then
    mkdir -p "${AIROOTFS}/usr/share/icons/Win10OS-cursors"
    cp -a "${CURSOR_SRC}/dist/." "${AIROOTFS}/usr/share/icons/Win10OS-cursors/"
fi

# Install AngelOS custom Widgets plasmoid
cp -a "${REPO_ROOT}/desktop/plasmoids/org.angelos.widgets" "${AIROOTFS}/usr/share/plasma/plasmoids/"

# Bundle AngelOS desktop assets, OOBE, and scripts into /opt/angelos
mkdir -p "${AIROOTFS}/opt/angelos"
cp -a "${REPO_ROOT}/VERSION" "${AIROOTFS}/opt/angelos/"
cp -a "${REPO_ROOT}/desktop" "${AIROOTFS}/opt/angelos/"
cp -a "${REPO_ROOT}/compat" "${AIROOTFS}/opt/angelos/"
cp -a "${REPO_ROOT}/scripts" "${AIROOTFS}/opt/angelos/"

# Install hidden layout runner & Wine runner system-wide
install -Dm755 "${REPO_ROOT}/desktop/scripts/apply-win11-layout.sh" \
    "${AIROOTFS}/usr/local/libexec/angelos-apply-layout"
install -Dm755 "${REPO_ROOT}/compat/wine/angelos-wine-runner" \
    "${AIROOTFS}/usr/local/bin/angelos-wine-runner"
install -Dm644 "${REPO_ROOT}/compat/wine/angelos-exe.desktop" \
    "${AIROOTFS}/usr/share/applications/angelos-exe.desktop"
install -Dm644 "${REPO_ROOT}/compat/wine/angelos-msi.desktop" \
    "${AIROOTFS}/usr/share/applications/angelos-msi.desktop"

# Ensure live systemd services & graphical target are enabled (remove tty1 getty autologin conflict)
SYSTEMD_DIR="${AIROOTFS}/etc/systemd/system"
rm -rf "${SYSTEMD_DIR}/getty@tty1.service.d"
mkdir -p "${SYSTEMD_DIR}/multi-user.target.wants"
ln -sf /usr/lib/systemd/system/NetworkManager.service "${SYSTEMD_DIR}/multi-user.target.wants/NetworkManager.service"
ln -sf /usr/lib/systemd/system/vboxservice.service "${SYSTEMD_DIR}/multi-user.target.wants/vboxservice.service"
ln -sf /etc/systemd/system/angelos-live-init.service "${SYSTEMD_DIR}/multi-user.target.wants/angelos-live-init.service"
ln -sf /usr/lib/systemd/system/sddm.service "${SYSTEMD_DIR}/display-manager.service"
ln -sf /usr/lib/systemd/system/graphical.target "${SYSTEMD_DIR}/default.target"

echo "==> Building AngelOS 11 v${ANGELOS_VERSION} ISO..."
mkarchiso -v -w "${ARCHISO_WORK}" -o "${OUT_DIR}" "${STAGED_PROFILE}"

BUILT_ISO="$(find "${OUT_DIR}" -maxdepth 1 -type f -name "angelos-11-${ANGELOS_VERSION}*.iso" | head -n 1 || true)"
TARGET_ISO="${OUT_DIR}/angelos-11-v${ANGELOS_VERSION}-x86_64.iso"

if [[ -n "${BUILT_ISO}" && "${BUILT_ISO}" != "${TARGET_ISO}" ]]; then
    mv -f "${BUILT_ISO}" "${TARGET_ISO}"
fi

if [[ -f "${TARGET_ISO}" ]]; then
    echo "==> ISO ready: ${TARGET_ISO}"
else
    echo "==> Build finished. Files in ${OUT_DIR}:"
    ls -la "${OUT_DIR}"
fi
