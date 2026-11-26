#!/usr/bin/env bash
set -euo pipefail

# Bootstrap AngelOS 11 packages, Win11 desktop defaults, and Wine support on an Arch Linux system
# (for example, inside a VirtualBox VM installed from archlinux-2026.11.01-x86_64.iso).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ ${EUID} -ne 0 ]]; then
    echo "Error: Run as root (sudo ./bootstrap-vm.sh)." >&2
    exit 1
fi

echo "==> Enabling multilib repository in /etc/pacman.conf..."
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
fi

echo "==> Installing AngelOS 11 latest Plasma 6, Wine Staging, and VirtualBox Guest stack..."
pacman -Syu --noconfirm --needed \
    base-devel git curl wget btrfs-progs snapper grub-btrfs \
    networkmanager sddm xorg-xwayland qt6-wayland qt6-5compat plasma-desktop plasma-workspace plasma5support kwin \
    kscreen kglobalacceld powerdevil bluedevil plasma-nm plasma-pa \
    plasma-systemmonitor pipewire pipewire-pulse wireplumber \
    breeze breeze-gtk kvantum xdg-desktop-portal-kde \
    xdg-user-dirs libnotify python-pyqt6 noto-fonts inter-font \
    dolphin kate spectacle gwenview haruna ark kcalc konsole discover flatpak \
    wine-staging winetricks wine-mono wine-gecko \
    lib32-mesa lib32-vulkan-icd-loader lib32-pipewire lib32-gnutls \
    virtualbox-guest-utils

echo "==> Installing AngelOS 11 desktop assets & Wine runner into /opt/angelos..."
mkdir -p /opt/angelos
cp -a "${REPO_ROOT}/desktop" /opt/angelos/
cp -a "${REPO_ROOT}/compat" /opt/angelos/
cp -a "${REPO_ROOT}/scripts" /opt/angelos/

install -Dm755 "${REPO_ROOT}/desktop/scripts/apply-win11-layout.sh" /usr/local/libexec/angelos-apply-layout
install -Dm755 "${REPO_ROOT}/compat/wine/angelos-wine-runner" /usr/local/bin/angelos-wine-runner
install -Dm644 "${REPO_ROOT}/compat/wine/angelos-exe.desktop" /usr/share/applications/angelos-exe.desktop
install -Dm644 "${REPO_ROOT}/compat/wine/angelos-msi.desktop" /usr/share/applications/angelos-msi.desktop
mkdir -p /usr/share/plasma/plasmoids
cp -a "${REPO_ROOT}/desktop/plasmoids/org.angelos.widgets" /usr/share/plasma/plasmoids/
update-desktop-database /usr/share/applications || true

echo "==> Enabling core services (NetworkManager, SDDM, VirtualBox Guest Additions)..."
systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl enable vboxservice.service

echo "==> Enabling Flathub remote..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

if [[ -n "${SUDO_USER:-}" ]]; then
    USER_HOME="$(getent passwd "${SUDO_USER}" | cut -d: -f6)"
    echo "==> Applying AngelOS 11 Win11 desktop config for user '${SUDO_USER}'..."
    cp -a /opt/angelos/desktop/skel/. "${USER_HOME}/"
    mkdir -p "${USER_HOME}/.config/autostart"
    cp -f /opt/angelos/desktop/oobe/angelos-firstboot.desktop "${USER_HOME}/.config/autostart/"
    chown -R "${SUDO_USER}:${SUDO_USER}" "${USER_HOME}"
fi

echo "==> AngelOS 11 bootstrap complete! Reboot to launch Plasma 6."
