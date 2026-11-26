#!/usr/bin/env bash
set -euo pipefail

# Build a versioned AngelOS 11 ISO using mkarchiso.
# - Stages from /usr/share/archiso/configs/releng so bootmodes & hooks track latest archiso.
# - Installs and patches yeyushengfan258/Win11OS-kde (theme only) for latest KDE Plasma 6.
# - Installs Win11-icon-theme, Win10OS-cursors, Eisteed/menu-11-next, and AngelOS plasmoids.
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
WIN11OS_DIR="${WORK_DIR}/win11os-kde"
ICONS_DIR="${WORK_DIR}/win11-icon-theme"
CURSORS_DIR="${WORK_DIR}/win10os-cursors"
MENU11_DIR="${WORK_DIR}/menu-11-next"
AUR_WORK="${WORK_DIR}/aur"

mkdir -p "${WORK_DIR}" "${OUT_DIR}" "${LOCAL_REPO}" "${AUR_WORK}"
rm -rf "${STAGED_PROFILE}" "${ARCHISO_WORK}" "${WIN11OS_DIR}" "${ICONS_DIR}" "${CURSORS_DIR}" "${MENU11_DIR}"

echo "==> Installing base-devel, git & gtk-update-icon-cache tools in build environment..."
pacman -Syu --noconfirm --needed base-devel git python

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

AIROOTFS="${STAGED_PROFILE}/airootfs"
mkdir -p \
    "${AIROOTFS}/usr/share/aurorae/themes" \
    "${AIROOTFS}/usr/share/color-schemes" \
    "${AIROOTFS}/usr/share/Kvantum" \
    "${AIROOTFS}/usr/share/plasma/desktoptheme" \
    "${AIROOTFS}/usr/share/plasma/look-and-feel" \
    "${AIROOTFS}/usr/share/plasma/plasmoids" \
    "${AIROOTFS}/usr/share/wallpapers" \
    "${AIROOTFS}/usr/share/icons" \
    "${AIROOTFS}/usr/share/sddm/themes"

# Fetch & install ONLY yeyushengfan258/Win11OS-kde (updated for latest KDE Plasma 6)
echo "==> Installing yeyushengfan258/Win11OS-kde and updating for latest Plasma 6..."
git clone --depth=1 https://github.com/yeyushengfan258/Win11OS-kde.git "${WIN11OS_DIR}"

cp -a "${WIN11OS_DIR}/aurorae/." "${AIROOTFS}/usr/share/aurorae/themes/"
cp -a "${WIN11OS_DIR}/color-schemes/"*.colors "${AIROOTFS}/usr/share/color-schemes/"
cp -a "${WIN11OS_DIR}/Kvantum/." "${AIROOTFS}/usr/share/Kvantum/"
cp -a "${WIN11OS_DIR}/plasma/desktoptheme/." "${AIROOTFS}/usr/share/plasma/desktoptheme/"
cp -a "${WIN11OS_DIR}/wallpaper/." "${AIROOTFS}/usr/share/wallpapers/"

for lnf in com.github.yeyushengfan258.Win11OS-dark com.github.yeyushengfan258.Win11OS-light; do
    if [[ -d "${WIN11OS_DIR}/plasma/look-and-feel/${lnf}" ]]; then
        cp -a "${WIN11OS_DIR}/plasma/look-and-feel/${lnf}" "${AIROOTFS}/usr/share/plasma/look-and-feel/"
    fi
done

# Install Plasma 6 SDDM themes from Win11OS-kde
for sddm_variant in sddm-dark/6.0/Win11OS-dark sddm-light/6.0/Win11OS-light; do
    if [[ -d "${WIN11OS_DIR}/${sddm_variant}" ]]; then
        cp -a "${WIN11OS_DIR}/${sddm_variant}" "${AIROOTFS}/usr/share/sddm/themes/"
    fi
done

# Update Win11OS-kde metadata & defaults for latest KDE Plasma 6 + Windows 11 accuracy
python3 - "${AIROOTFS}" <<'PYEOF'
import json
import pathlib
import sys

airootfs = pathlib.Path(sys.argv[1])

# 1. Patch look-and-feel packages: Windows 11 right-side titlebar buttons (IAX),
#    consistent Win10OS-cursors, and Plasma 6 QtQuick Splash.qml cleanup
for variant in ("Win11OS-dark", "Win11OS-light"):
    lnf_dir = airootfs / "usr/share/plasma/look-and-feel" / f"com.github.yeyushengfan258.{variant}"
    if not lnf_dir.exists():
        continue

    # Drop legacy metadata.desktop when metadata.json exists so Plasma 6 uses JSON cleanly
    legacy_desktop = lnf_dir / "metadata.desktop"
    if (lnf_dir / "metadata.json").exists() and legacy_desktop.exists():
        legacy_desktop.unlink()

    defaults_file = lnf_dir / "contents/defaults"
    if defaults_file.exists():
        text = defaults_file.read_text(encoding="utf-8")
        text = text.replace("ButtonsOnLeft=XAI", "ButtonsOnLeft=")
        text = text.replace("ButtonsOnRight=", "ButtonsOnRight=IAX")
        text = text.replace("cursorTheme=ArcDusk-cursors", "cursorTheme=Win10OS-cursors")
        defaults_file.write_text(text, encoding="utf-8")

    splash_file = lnf_dir / "contents/splash/Splash.qml"
    if splash_file.exists():
        splash_text = splash_file.read_text(encoding="utf-8")
        splash_text = splash_text.replace("import QtQuick 2.1", "import QtQuick")
        splash_text = splash_text.replace("target: bottomRect", "target: topRect")
        splash_file.write_text(splash_text, encoding="utf-8")

# 2. Ensure Win11OS-dark / Win11OS-light desktopthemes have Plasma 6 metadata.json
for variant in ("Win11OS-dark", "Win11OS-light"):
    dt_dir = airootfs / "usr/share/plasma/desktoptheme" / variant
    meta_json = dt_dir / "metadata.json"
    if dt_dir.exists() and not meta_json.exists():
        payload = {
            "KPlugin": {
                "Authors": [{"Email": "yeyushengfan258@outlook.com", "Name": "yeyushengfan258"}],
                "Category": "Plasma Theme",
                "Description": f"{variant} theme updated for KDE Plasma 6",
                "EnabledByDefault": True,
                "Id": variant,
                "License": "GPLv3",
                "Name": variant,
                "Version": "1.0",
                "Website": "https://github.com/yeyushengfan258/Win11OS-kde",
            }
        }
        meta_json.write_text(json.dumps(payload, indent=4) + "\n", encoding="utf-8")
PYEOF

# Install Win11-icon-theme & Win10OS-cursors (paired assets referenced by Win11OS-kde)
echo "==> Installing Win11-icon-theme & Win10OS-cursors..."
git clone --depth=1 https://github.com/yeyushengfan258/Win11-icon-theme.git "${ICONS_DIR}"
bash "${ICONS_DIR}/install.sh" -d "${AIROOTFS}/usr/share/icons" -t default || true

git clone --depth=1 https://github.com/yeyushengfan258/Win10OS-cursors.git "${CURSORS_DIR}"
if [[ -d "${CURSORS_DIR}/dist" ]]; then
    mkdir -p "${AIROOTFS}/usr/share/icons/Win10OS-cursors"
    cp -a "${CURSORS_DIR}/dist/." "${AIROOTFS}/usr/share/icons/Win10OS-cursors/"
fi

# Install pure-QML Plasma 6 Start Menu (Eisteed/menu-11-next) & AngelOS taskbar plasmoids
echo "==> Installing menu-11-next and AngelOS taskbar plasmoids..."
git clone --depth=1 https://github.com/Eisteed/menu-11-next.git "${MENU11_DIR}"
cp -a "${MENU11_DIR}" "${AIROOTFS}/usr/share/plasma/plasmoids/menu.11.next"
rm -rf "${AIROOTFS}/usr/share/plasma/plasmoids/menu.11.next/.git"

cp -a "${REPO_ROOT}/desktop/plasmoids/org.angelos.widgets" "${AIROOTFS}/usr/share/plasma/plasmoids/"
cp -a "${REPO_ROOT}/desktop/plasmoids/org.angelos.search" "${AIROOTFS}/usr/share/plasma/plasmoids/"
cp -a "${REPO_ROOT}/desktop/plasmoids/org.angelos.showdesktop" "${AIROOTFS}/usr/share/plasma/plasmoids/"

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
