#!/usr/bin/env bash
set -euo pipefail

# sign_kernel.sh
# Generates a keypair (if not present) and signs a kernel image using sbsign.
# Usage: ./sign_kernel.sh <kernel-path> [output-path]

KERNEL_PATH=${1:-}
OUT_PATH=${2:-}

if [ -z "$KERNEL_PATH" ]; then
  echo "Usage: $0 <kernel-path> [output-path]"; exit 2
fi

if [ ! -f "$KERNEL_PATH" ]; then
  echo "Kernel not found: $KERNEL_PATH"; exit 1
fi

# Keys will be placed next to kernel by default
DIR=$(dirname "$KERNEL_PATH")
KEY_PRIV="$DIR/MOK.priv.pem"
KEY_PUB="$DIR/MOK.pub.cer"

# Create a self-signed key if missing
if [ ! -f "$KEY_PRIV" ] || [ ! -f "$KEY_PUB" ]; then
  echo "Generating MOK keypair (RSA 4096)"
  openssl req -new -x509 -newkey rsa:4096 -days 3650 -nodes -subj "/CN=NebulaOS MOK/" -keyout "$KEY_PRIV" -out "$DIR/MOK.pem"
  # Convert to DER-encoded cert for some tools (optional)
  openssl x509 -in "$DIR/MOK.pem" -outform DER -out "$KEY_PUB"
  # Keep private key in PEM form for sbsign
  mv "$DIR/MOK.pem" "$KEY_PRIV"
fi

if [ -z "$OUT_PATH" ]; then
  OUT_PATH="$DIR/$(basename "$KERNEL_PATH").signed"
fi

if ! command -v sbsign >/dev/null 2>&1; then
  echo "sbsign not found. Install sbsigntools (on Arch: pacman -S sbsigntools)"; exit 1
fi

sbsign --key "$KEY_PRIV" --cert "$KEY_PUB" --output "$OUT_PATH" "$KERNEL_PATH"

echo "Signed kernel created: $OUT_PATH"
echo "Public key (MOK) to enroll on target machine: $KEY_PUB"
