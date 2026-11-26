# AngelOS 11 Calamares Configuration

Windows 11 OOBE-styled **Calamares** installer configuration (`v0.2.0` target):

- **Storage Layout**: Btrfs root with subvolumes (`@`, `@home`, `@log`, `@pkg`, `@.snapshots`)
- **System Restore**: Snapper + `snap-pac` + `grub-btrfs` + GRUB bootloader
- **Branding**: AngelOS 11 OOBE-style slides, clean light/dark-neutral installation UI, and VirtualBox Guest Additions retention when installed inside a VM
