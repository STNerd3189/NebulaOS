#!/usr/bin/env bash
set -euo pipefail

# build_arch_rootfs.sh
# Uses pacstrap (arch-install-scripts) to create a minimal Arch Linux root file system,
# generates kernel + initramfs using mkinitcpio, and places artifacts into the specified output dir.
# Usage: sudo ./build_arch_rootfs.sh <output-dir>

OUTDIR=${1:-$(pwd)}
WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root because pacstrap and pacman require root." >&2
  exit 1
fi

echo "Building minimal Arch chroot in $WORKDIR"

# Check required tools
for cmd in pacstrap pacman-key mkinitcpio; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd is required. Install arch-install-scripts (for pacstrap) and mkinitcpio." >&2
    exit 1
  fi
done

# Prepare dest
mkdir -p "$OUTDIR"

# pacstrap will populate WORKDIR
PACKAGES=(base linux linux-firmware mkinitcpio systemd-sysvcompat)

# Initialize pacman keyring to avoid interactive prompts
pacman-key --init
pacman-key --populate archlinux

# Use pacstrap to install minimal system
pacstrap -c -G "$WORKDIR" "${PACKAGES[@]}"

# Generate initramfs inside chroot
arch-chroot "$WORKDIR" /bin/bash -lc "mkinitcpio -P"

# Copy kernel and initramfs
KERNEL_PATH="$WORKDIR/boot/vmlinuz-linux"
INIT_PATH="$WORKDIR/boot/initramfs-linux.img"

if [ ! -f "$KERNEL_PATH" ] || [ ! -f "$INIT_PATH" ]; then
  echo "Expected kernel or initramfs not found in $WORKDIR/boot" >&2
  ls -la "$WORKDIR/boot" || true
  exit 1
fi

cp "$KERNEL_PATH" "$OUTDIR/vmlinuz-linux"
cp "$INIT_PATH" "$OUTDIR/initramfs-linux.img"

# Optional: copy a minimal pacman configuration or mirrorlist into OUTDIR so the live system can use pacman
cp -L /etc/pacman.conf "$OUTDIR/pacman.conf" 2>/dev/null || true
cp -L /etc/pacman.d/mirrorlist "$OUTDIR/mirrorlist" 2>/dev/null || true

echo "Arch kernel and initramfs placed into $OUTDIR"
