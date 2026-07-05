#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

echo "Installing NebulaOS base software..."

PKGS=(
  base-devel git curl wget neofetch htop btop timeshift flatpak networkmanager
  plasma sddm kde-applications dolphin konsole spectacle kate
  pipewire wireplumber pavucontrol easyeffects qjackctl
  obs-studio steam lutris heroic-games-launcher bottles mangohud gamemode wine-staging
  kdenlive blender gimp krita shotcut audacity ardour lmms carla musescore
  vlc firefox gparted yay
)

pacman -Syu --noconfirm --needed "${PKGS[@]}"

if ! pacman -Qq chaotic-keyring >/dev/null 2>&1; then
  echo "Chaotic-AUR is not installed by default in this scaffold; add the Chaotic-AUR repository before using it."
fi

systemctl enable NetworkManager
systemctl enable sddm

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

echo "NebulaOS setup complete."
