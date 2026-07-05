#!/usr/bin/env bash
set -euo pipefail

title="NebulaOS Live Installer"
msg=$(cat <<'EOF'
NebulaOS live environment is ready.

This image includes a guided installer scaffold for installing NebulaOS to disk.

Recommended flow:
1. Review the installer guide at /usr/share/doc/nebulaos/installer-guide.txt
2. Prepare your target drive with a partition manager or terminal tools.
3. Run the NebulaOS install helper from /usr/local/bin/install-nebulaos.sh once your target is ready.

The installer workflow is intentionally scaffolded for future archiso integration.
EOF
)

if command -v kdialog >/dev/null 2>&1; then
  kdialog --title "$title" --msgbox "$msg"
elif command -v zenity >/dev/null 2>&1; then
  zenity --info --title "$title" --text "$msg"
else
  printf '%s\n' "$msg"
fi
