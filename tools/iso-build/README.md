# README for tools/iso-build

This folder contains scripts to produce a hybrid BIOS+UEFI bootable ISO for NebulaOS.
The ISO can be built in two ways:
 - Generic tiny initramfs flow (busybox-based)
 - Arch-based flow (uses pacstrap/mkinitcpio so the resulting ISO uses pacman and an Arch rootfs)

Files added:
- build_iso.sh        : orchestrates ISO creation; copy files into output/ or run with --build-all
- build_arch_rootfs.sh: (Arch) builds a minimal Arch chroot with pacstrap and creates kernel/initramfs
- build_kernel.sh     : helper to download and build a vanilla Linux kernel (bzImage) (generic)
- build_busybox.sh    : builds a static busybox for use in the initramfs (generic)
- build_initramfs.sh  : builds an initramfs (nebula-initramfs.cpio.gz) using the busybox binary (generic)
- grub.cfg            : GRUB menu configuration used on the ISO
- Makefile            : convenience targets
- output/             : build artifacts (nebula-bzImage, nebula-initramfs.cpio.gz or vmlinuz-linux/initramfs-linux.img)

Arch-specific quickstart (on an Arch machine):

# Install dependencies on Arch
sudo pacman -Syu --needed base-devel arch-install-scripts grub efibootmgr xorriso qemu ovmf mkinitcpio

# Build everything and create NebulaOS.iso (Arch flow - requires root because pacstrap requires root):
cd tools/iso-build
sudo ./build_iso.sh --build-all-arch

# The script will use pacstrap to install a minimal Arch system into a temporary chroot,
# run mkinitcpio to generate an initramfs, and then create the hybrid ISO.

# Test in QEMU (BIOS):
qemu-system-x86_64 -cdrom NebulaOS.iso -m 1024

# Test in QEMU (UEFI) - ensure OVMF is installed and path is correct:
qemu-system-x86_64 -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd -cdrom NebulaOS.iso -m 1024

Writing to USB (careful! replace /dev/sdX with your device):
sudo dd if=NebulaOS.iso of=/dev/sdX bs=4M status=progress conv=fsync

Notes:
- The Arch flow requires root and network connectivity to download packages via pacman.
- Secure Boot: disable if not using signed binaries.
- You can customize the pacstrap package list in build_arch_rootfs.sh if you want extra packages included in the live system.
