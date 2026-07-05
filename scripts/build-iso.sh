#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/out"

mkdir -p "$OUT_DIR"

echo "NebulaOS ISO build scaffold"
echo "Project root: $ROOT_DIR"
echo "Output directory: $OUT_DIR"
echo "This script is a placeholder for a full archiso build pipeline."
