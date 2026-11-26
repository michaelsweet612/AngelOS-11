#!/usr/bin/env bash
set -euo pipefail

# Bootstrap AngelOS 11 packages & VM guest tools on an Arch Linux system
# (for example, inside a VirtualBox VM installed from archlinux-2026.11.01-x86_64.iso).

if [[ ${EUID} -ne 0 ]]; then
    echo "Error: Run as root (sudo ./bootstrap-vm.sh)." >&2
    exit 1
fi

echo "==> Checking pacman multilib configuration..."
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf
fi

echo "==> Updating package database & installing AngelOS 11 baseline stack..."
pacman -Syu --noconfirm --needed \
    base-devel git curl wget btrfs-progs snapper \
    networkmanager sddm plasma-desktop plasma-workspace kwin \
    kscreen kglobalacceld powerdevil bluedevil plasma-nm plasma-pa \
    plasma-systemmonitor breeze breeze-gtk kvantum xdg-desktop-portal-kde \
    dolphin kate spectacle gwenview haruna ark kcalc konsole discover flatpak \
    virtualbox-guest-utils

echo "==> Enabling core services (NetworkManager, SDDM, VirtualBox Guest Additions)..."
systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl enable vboxservice.service

echo "==> Enabling Flathub remote..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

echo "==> AngelOS 11 baseline bootstrap complete! Reboot to enter Plasma."
