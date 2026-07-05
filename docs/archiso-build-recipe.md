# NebulaOS Archiso Build Recipe

## Goal
Create a custom Arch Linux live ISO for NebulaOS with the NebulaOS package set and branding.

## 1. Prepare the build environment
```bash
sudo pacman -Syu --noconfirm archiso
mkdir -p ~/nebulaos-build/work
cd ~/nebulaos-build
cp -r /usr/share/archiso/configs/releng/ releng
cd releng
```

## 2. Add NebulaOS packages
Edit packages.x86_64 and add the core NebulaOS software packages:
- plasma
- sddm
- pipewire
- wireplumber
- obs-studio
- steam
- lutris
- heroic-games-launcher
- kdenlive
- blender
- audacity
- ardour
- lmms
- carla
- musescore

## 3. Add branding assets
Place wallpapers, splash images, and theme assets in:
- airootfs/etc/skel
- airootfs/usr/share/backgrounds
- airootfs/usr/share/icons

## 4. Build the ISO
```bash
sudo ./build.sh -v
```

## 5. Output
The finished ISO will appear in the out/ directory.
