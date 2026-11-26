#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="angelos-11"
iso_label="ANGELOS11_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="AngelOS 11 Project <https://github.com/michaelsweet612/AngelOS-11>"
iso_application="AngelOS 11 Live/Install ISO"
iso_version="${ANGELOS_VERSION:-0.0.1}"
install_dir="angelos"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.systemd-boot.esp' 'uefi-x64.systemd-boot.esp'
           'uefi-ia32.systemd-boot.eltorito' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
)
