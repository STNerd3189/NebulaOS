#!/usr/bin/env bash
set -euo pipefail

# build_iso.sh
# Builds a hybrid BIOS+UEFI ISO (NebulaOS.iso) using grub-mkrescue or xorriso.
# Supports two flows:
#  - generic: uses a provided kernel/initramfs or builds a tiny busybox-based initramfs
#  - arch: uses pacstrap to create a minimal Arch Linux chroot, generates a kernel and initramfs via mkinitcpio
#
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKDIR="$SCRIPT_DIR/output"
OUTISO="$SCRIPT_DIR/../NebulaOS.iso"

BUILD_ALL=false
USE_ARCH=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --build-all)
      BUILD_ALL=true; shift ;;
    --build-all-arch)
      BUILD_ALL=true; USE_ARCH=true; shift ;;
    --arch)
      USE_ARCH=true; shift ;;
    --out)
      OUTISO="$2"; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$WORKDIR/boot/grub"

if [ "$USE_ARCH" = true ]; then
  echo "Arch flow selected: will use pacstrap to build minimal Arch chroot and mkinitcpio to generate kernel/initramfs"
  if [ "$BUILD_ALL" = true ]; then
    "$SCRIPT_DIR/build_arch_rootfs.sh" "$WORKDIR"
  fi
else
  # Build kernel and initramfs if requested (generic flow)
  if [ "$BUILD_ALL" = true ]; then
    echo "--build-all: building kernel, busybox, and initramfs (generic flow)"
    "$SCRIPT_DIR/build_kernel.sh" "$WORKDIR"
    "$SCRIPT_DIR/build_busybox.sh" "$WORKDIR"
    "$SCRIPT_DIR/build_initramfs.sh" "$WORKDIR"
  fi
fi

# Determine kernel/initramfs paths depending on flow
if [ "$USE_ARCH" = true ]; then
  KERNEL_SRC="$WORKDIR/vmlinuz-linux"
  INITRAMFS_SRC="$WORKDIR/initramfs-linux.img"
else
  KERNEL_SRC="$WORKDIR/nebula-bzImage"
  INITRAMFS_SRC="$WORKDIR/nebula-initramfs.cpio.gz"
fi

if [ ! -f "$KERNEL_SRC" ]; then
  echo "Kernel not found at $KERNEL_SRC"
  echo "Run with --build-all (or --build-all-arch) to build artifacts, or place kernel into $WORKDIR"
  exit 1
fi

if [ ! -f "$INITRAMFS_SRC" ]; then
  echo "Initramfs not found at $INITRAMFS_SRC"
  echo "Run with --build-all (or --build-all-arch) to build artifacts, or place initramfs into $WORKDIR"
  exit 1
fi

# Assemble iso tree
ISO_ROOT="$SCRIPT_DIR/iso_root"
rm -rf "$ISO_ROOT"
mkdir -p "$ISO_ROOT/boot/grub"

cp "$KERNEL_SRC" "$ISO_ROOT/boot/nebula-bzImage"
cp "$INITRAMFS_SRC" "$ISO_ROOT/boot/nebula-initramfs.cpio.gz"

# Use provided grub.cfg
cp "$SCRIPT_DIR/grub.cfg" "$ISO_ROOT/boot/grub/grub.cfg"

# Create ISO
echo "Creating hybrid BIOS+UEFI ISO at $OUTISO"

if command -v grub-mkrescue >/dev/null 2>&1; then
  echo "Using grub-mkrescue"
  grub-mkrescue -o "$OUTISO" "$ISO_ROOT" -- -quiet || {
    echo "grub-mkrescue failed; try installing grub and xorriso packages";
    exit 1
  }
else
  echo "grub-mkrescue not found; attempting xorriso flow"
  if ! command -v xorriso >/dev/null 2>&1; then
    echo "xorriso not found; install xorriso or grub-mkrescue"; exit 1
  fi

  xorriso -as mkisofs \
    -iso-level 3 \
    -o "$OUTISO" \
    -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    "$ISO_ROOT"
fi

echo "ISO created: $OUTISO"

cat <<'EOF'
Next steps:
 - Test in QEMU (BIOS): qemu-system-x86_64 -cdrom NebulaOS.iso -m 1024
 - Test in QEMU (UEFI): qemu-system-x86_64 -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd -cdrom NebulaOS.iso -m 1024
 - Write to USB: sudo dd if=NebulaOS.iso of=/dev/sdX bs=4M status=progress conv=fsync
EOF
