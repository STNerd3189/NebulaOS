#!/usr/bin/env bash
iso_name="nebulaos"
iso_label="NEBULAOS_$(date +%Y%m%d)"
iso_publisher="NebulaOS Project <https://example.invalid>"
iso_application="NebulaOS Live/Installation Medium"
install_dir="arch"
bootmodes="bios.syslinux.mbr bios.syslinux.eltorito efi-x64.systemd-boot.esp efi-x64.systemd-boot.eltorito"
arch="x86_64"
