# Secure Boot signing helpers and notes

This directory contains helper scripts and instructions to sign kernels and create keys usable with shim/MOK enrollment.

Overview
- To boot on Secure Boot-enabled machines, you must either use a signed shim (and sign GRUB and kernel) or disable Secure Boot in firmware.
- The scripts here show how to generate a Machine Owner Key (MOK), sign a kernel with sbsign, and provide helper commands to enroll the key on a target machine using mokutil.

Files
- sign_kernel.sh    : basic script to create keys and sign a kernel (vmlinuz-linux -> vmlinuz-linux.signed)
- enroll_mok.sh     : helper commands to import the MOK on a live system using mokutil
- README.md         : human-readable steps and caveats

Caveats
- This does NOT produce a signed shim or signed GRUB binary. For full Secure Boot support on many machines you'll need to use the shim approach and sign GRUB and the kernel.
- You must enroll the generated MOK (public key) on each target machine via mokutil or UEFI firmware key management.
