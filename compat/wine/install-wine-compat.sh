#!/usr/bin/env bash
set -euo pipefail

# Install Wine Staging + 32-bit multilib stack + AngelOS .exe/.msi runner on Arch Linux.

if [[ ${EUID} -ne 0 ]]; then
    echo "Error: Run as root (sudo ./install-wine-compat.sh)." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pacman -S --noconfirm --needed \
    wine-staging winetricks wine-mono wine-gecko \
    lib32-mesa lib32-vulkan-icd-loader lib32-pipewire lib32-gnutls libnotify

install -Dm755 "${SCRIPT_DIR}/angelos-wine-runner" /usr/local/bin/angelos-wine-runner
install -Dm644 "${SCRIPT_DIR}/angelos-exe.desktop" /usr/share/applications/angelos-exe.desktop
install -Dm644 "${SCRIPT_DIR}/angelos-msi.desktop" /usr/share/applications/angelos-msi.desktop
update-desktop-database /usr/share/applications || true

echo "==> AngelOS Wine Staging .exe/.msi compatibility installed."
