# NebulaOS

NebulaOS is a proposed Arch-based Linux distribution designed for gamers, streamers, content creators, and music producers.

## Vision
NebulaOS aims to provide a fast, polished, and ready-to-use desktop experience for:
- gaming
- streaming and recording
- content creation
- music and audio production

NebulaOS is designed with a full sci-fi identity, featuring a futuristic UI, neon accents, cyberpunk-inspired themes, and a space-age workstation feel.

## Core Promise
Powering play, creation, and sound.

## Target Audience
- gamers
- streamers
- content creators
- musicians and producers

## Core Features
- Arch-based rolling release system
- KDE Plasma desktop
- built-in gaming stack
- built-in streaming and recording tools
- content creation software
- audio production tools with PipeWire

## Repository Structure
- docs/ - documentation and build planning
- scripts/ - installer and build helpers
- archiso/ - live ISO customization scaffold with live installer assets
- themes/ - UI theme concepts
- website/ - landing page prototype
- .github/ - CI and issue templates

## Recommended Software Stack
### Package Ecosystem
- Chaotic-AUR
- Yay
- pacman
- Flatpak

### Gaming
- Steam
- Lutris
- Heroic Games Launcher
- Bottles
- ProtonUp-Qt
- MangoHud
- GameMode
- Wine-staging

### Streaming and Recording
- OBS Studio
- VokoscreenNG
- SimpleScreenRecorder

### Content Creation
- Blender
- Kdenlive
- Shotcut
- Krita
- GIMP

### Music and Audio
- Ardour
- Audacity
- LMMS
- Carla
- MuseScore
- PipeWire
- WirePlumber

## Technical Foundation
- Base: Arch Linux
- Desktop: KDE Plasma
- Audio: PipeWire + WirePlumber
- Display: Wayland-first, X11 fallback
- Package systems: pacman, Flatpak, AUR, Chaotic-AUR, Yay

## Roadmap
1. Vision and branding
2. Base system foundation
3. Desktop experience
4. Gaming stack
5. Creator tools
6. Audio production workflow
7. Beta testing
8. Stable release

## First ISO Package Plan
### Core System
- base
- base-devel
- linux
- linux-firmware
- pacman
- sudo
- git
- curl
- wget
- NetworkManager

### Desktop
- plasma
- sddm
- kde-applications
- dolphin
- konsole
- spectacle
- kate

### Graphics and Drivers
- mesa
- vulkan-icd-loader
- libva-utils
- nvidia or nvidia-dkms
- amdvlk
- xf86-video-amdgpu
- xf86-video-intel

### Audio
- pipewire
- pipewire-audio
- pipewire-jack
- pipewire-pulse
- wireplumber
- pavucontrol
- easyeffects
- qjackctl

## Branding Direction
- Name: NebulaOS
- Tagline: Powering play, creation, and sound.
- Style: futuristic, bold, premium, modern, creator-focused, sci-fi
- Visual direction: dark space-inspired theme with cyan, purple, electric blue, and holographic accents

## Build Checklist
- create a custom Arch live ISO profile
- install KDE Plasma
- include gaming, creator, and audio software
- add branding and theme assets
- configure first-run experience
- test boot, drivers, audio, and app launchers
- build and test the ISO

## Contributor Resources
- CONTRIBUTING.md
- docs/contributor-guide.md
- .github/ISSUE_TEMPLATE/

## Additional Starter Assets
- assets/bootsplash/ - boot splash concept and artwork
- docs/mockups/installer-ui.md - installer UI mockup
- docs/main-panel-screen.md - main panel / coding screen concept
- Dockerfile and docker-compose.yml - lightweight dev environment scaffold
- website/README.md - landing page usage notes
- website/main-panel-demo.html - interactive main-panel mockup
