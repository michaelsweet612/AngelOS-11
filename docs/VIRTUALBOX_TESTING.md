# VirtualBox Testing Guide (Windows Host)

AngelOS 11 is designed to run smoothly inside **Oracle VirtualBox** on Windows for rapid visual iteration and ISO testing.

---

## Recommended VM Settings

When creating a VM manually or via `scripts/vbox-test.ps1`:

| Setting | Recommended Value | Why |
| :--- | :--- | :--- |
| **Type / Version** | `Linux` -> `Arch Linux (64-bit)` | Optimal kernel/ACPI defaults |
| **RAM** | `8192 MB` (8 GB) *(min 4 GB)* | Smooth Plasma 6 + Wine + Calamares |
| **CPU** | `4` cores (PAE/NX enabled) | Fast Live ISO boot & Btrfs install |
| **Firmware** | **Enable EFI** (`System -> Motherboard`) | Matches modern UEFI + GRUB + Btrfs snapshots |
| **Graphics Controller** | **VMSVGA** | Required for Wayland/X11 auto-resize in VirtualBox |
| **Video Memory** | `128 MB` + **Enable 3D Acceleration** | Needed for KWin Mica/Acrylic blur & rounded corners |
| **Virtual Disk** | `40 GB`–`64 GB` VDI (Dynamically allocated) | Enough room for Btrfs + Snapper + Wine prefixes |
| **Audio / Network** | Intel HD Audio + NAT (or Bridged) | Sound theme & pacman/Flatpak access |

---

## Method 1: Quick VM Setup via PowerShell

Run from the repository root on Windows:

```powershell
# Boot using your stock Arch ISO for early VM testing:
.\scripts\vbox-test.ps1 -IsoPath "C:\Users\Michael\Desktop\archlinux-2026.11.01-x86_64.iso"

# Or boot a built AngelOS 11 ISO:
.\scripts\vbox-test.ps1 -IsoPath ".\out\angelos-11-v0.1.0-x86_64.iso"
```

Pass `-DryRun` first to preview the `VBoxManage` commands without modifying anything.

---

## Method 2: Bootstrapping from `archlinux-2026.11.01-x86_64.iso`

If you boot a fresh VM from stock `archlinux-2026.11.01-x86_64.iso`:
1. Ensure networking is active (`ping -c 2 archlinux.org`).
2. Pull the bootstrap script and run it inside the Arch VM (after partitioning/mounting `/mnt`, or on a freshly installed base Arch system):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/michaelsweet612/AngelOS-11/main/scripts/bootstrap-vm.sh -o bootstrap-vm.sh
   chmod +x bootstrap-vm.sh
   sudo ./bootstrap-vm.sh
   ```

---

## VirtualBox Guest Additions in AngelOS 11 ISOs

Every `archiso` build includes `virtualbox-guest-utils` and enables `vboxservice.service` automatically so:
- Window resizing (`VMSVGA`), shared clipboard, and seamless mouse pointer integration work out of the box on both the Live ISO and the Calamares-installed system.
- If blur glitches occur under VirtualBox 3D acceleration on certain Windows GPU drivers, test toggling **3D Acceleration** in VirtualBox Display settings as a baseline check.
