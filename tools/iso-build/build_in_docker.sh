#!/usr/bin/env bash
set -euo pipefail

# build_in_docker.sh
# Builds the ISO inside an Arch container using the provided Dockerfile.
# Usage: ./build_in_docker.sh [--out /path/to/output.iso]

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IMAGE_NAME="nebulaos-iso-builder:latest"
CONTAINER_NAME="nebulaos-iso-builder"

OUT_ARG=""
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --out)
      OUT_ARG="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Build image
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"

# Run container and execute build script inside it. Mount the repo into /workspace and preserve ownership.
# --privileged is not required for pacstrap here but we keep it off. Use --rm to clean up.
if [ -z "$OUT_ARG" ]; then
  docker run --rm -v "$SCRIPT_DIR:/workspace" -w /workspace "$IMAGE_NAME" sudo bash -lc "cd tools/iso-build && sudo ./build_iso.sh --build-all-arch"
else
  docker run --rm -v "$SCRIPT_DIR:/workspace" -w /workspace "$IMAGE_NAME" sudo bash -lc "cd tools/iso-build && sudo ./build_iso.sh --build-all-arch --out $OUT_ARG"
fi

echo "Done: check NebulaOS.iso (or the path you specified)"
