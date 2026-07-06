#!/bin/sh
# enroll_mok.sh - helper commands to enroll a MOK public key on a running system
# Requires mokutil (package: mokutil)
# Usage: sudo ./enroll_mok.sh /path/to/MOK.pub.cer

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/MOK.pub.cer"; exit 2
fi

PUBKEY="$1"
if [ ! -f "$PUBKEY" ]; then echo "File not found: $PUBKEY"; exit 1; fi

if ! command -v mokutil >/dev/null 2>&1; then
  echo "mokutil not found. On Arch: pacman -S mokutil"; exit 1
fi

sudo mokutil --import "$PUBKEY"

echo "Reboot the machine and follow the MOK manager menu to complete enrollment (enter a password when prompted)."
