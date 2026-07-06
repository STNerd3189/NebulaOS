# Dockerfile to run Arch-based ISO build in a container
# Usage: ./build_in_docker.sh (this builds the image and runs the build)
FROM archlinux:latest

# Install required packages non-interactively
RUN pacman -Syy --noconfirm arch-install-scripts base-devel git grub efibootmgr xorriso qemu ovmf mkinitcpio sbsigntools openssl sudo

# Create a builder user (optional) and set up working dir
RUN useradd -m builder && echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
WORKDIR /workspace

# Copy scripts into container
COPY . /workspace

# Default entry: print usage
ENTRYPOINT ["/bin/bash","-lc","echo 'Use build_in_docker.sh wrapper on host to run the build inside this container' && bash"]
