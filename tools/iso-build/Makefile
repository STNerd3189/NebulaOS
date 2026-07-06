# Minimal Makefile to integrate ISO build into your existing workflow
# Usage: make -C tools/iso-build iso

.PHONY: iso build-all build-all-arch

iso:
	./build_iso.sh

build-all:
	./build_iso.sh --build-all

# Arch flow (requires root because pacstrap needs root privileges)
build-all-arch:
	sudo ./build_iso.sh --build-all-arch
