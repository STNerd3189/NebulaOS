#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.config"
cat > "$HOME/.config/nebulaos-first-run" <<'EOF'
NebulaOS first-run setup complete.
EOF

notify-send "NebulaOS" "Welcome to NebulaOS. Your creator-gamer workspace is ready." || true
