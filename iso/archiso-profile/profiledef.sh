#!/usr/bin/env bash
# shellcheck disable=SC2034

if [[ -f /usr/share/archiso/configs/releng/profiledef.sh ]]; then
    # Inherit current upstream releng bootmodes and image tool defaults.
    # shellcheck source=/dev/null
    source /usr/share/archiso/configs/releng/profiledef.sh
fi

iso_name="angelos-11"
iso_label="ANGELOS11_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="AngelOS 11 Project <https://github.com/michaelsweet612/AngelOS-11>"
iso_application="AngelOS 11 Live/Install ISO"
iso_version="${ANGELOS_VERSION:-0.0.1}"
install_dir="angelos"
arch="x86_64"
pacman_conf="pacman.conf"

file_permissions+=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/sudoers.d/10-angelos-wheel"]="0:0:440"
    ["/usr/local/bin/angelos-live-init"]="0:0:755"
    ["/usr/local/bin/angelos-wine-runner"]="0:0:755"
    ["/opt/angelos/desktop/skel/apply-win11-layout.sh"]="0:0:755"
    ["/opt/angelos/desktop/oobe/angelos-firstboot.py"]="0:0:755"
    ["/opt/angelos/compat/wine/angelos-wine-runner"]="0:0:755"
    ["/opt/angelos/compat/wine/install-wine-compat.sh"]="0:0:755"
)
