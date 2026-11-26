#!/usr/bin/env bash
set -euo pipefail

# Build a versioned AngelOS 11 ISO using mkarchiso.
# Stages from /usr/share/archiso/configs/releng so bootmodes & hooks always track latest archiso.

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

mkdir -p "${WORK_DIR}" "${OUT_DIR}"
rm -rf "${STAGED_PROFILE}" "${ARCHISO_WORK}"

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

# Bundle AngelOS desktop themes, Wine runner, and scripts into /opt/angelos
mkdir -p "${STAGED_PROFILE}/airootfs/opt/angelos"
cp -a "${REPO_ROOT}/VERSION" "${STAGED_PROFILE}/airootfs/opt/angelos/"
cp -a "${REPO_ROOT}/desktop" "${STAGED_PROFILE}/airootfs/opt/angelos/"
cp -a "${REPO_ROOT}/compat" "${STAGED_PROFILE}/airootfs/opt/angelos/"
cp -a "${REPO_ROOT}/scripts" "${STAGED_PROFILE}/airootfs/opt/angelos/"

# Install Wine runner & MIME desktop files system-wide
install -Dm755 "${REPO_ROOT}/compat/wine/angelos-wine-runner" \
    "${STAGED_PROFILE}/airootfs/usr/local/bin/angelos-wine-runner"
install -Dm644 "${REPO_ROOT}/compat/wine/angelos-exe.desktop" \
    "${STAGED_PROFILE}/airootfs/usr/share/applications/angelos-exe.desktop"
install -Dm644 "${REPO_ROOT}/compat/wine/angelos-msi.desktop" \
    "${STAGED_PROFILE}/airootfs/usr/share/applications/angelos-msi.desktop"

# Ensure live systemd services & graphical target are enabled (remove tty1 getty autologin conflict)
SYSTEMD_DIR="${STAGED_PROFILE}/airootfs/etc/systemd/system"
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
