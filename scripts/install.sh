#!/usr/bin/env bash

# install.sh - Installs Omarchy Menu Self-Healing Wrapper and Autostart Sync

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
AUTOSTART_FILE="$HOME/.config/hypr/autostart.lua"

echo "=== Installing Omarchy Fixes & Self-Healing Utilities ==="

# 1. Install omarchy-menu wrapper
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/omarchy-menu-wrapper.sh" "$BIN_DIR/omarchy-menu"
chmod +x "$BIN_DIR/omarchy-menu"
echo "[✓] Installed self-healing wrapper to $BIN_DIR/omarchy-menu"

# 2. Configure autostart sync if not already present
if [[ -f "$AUTOSTART_FILE" ]]; then
  if grep -q "omarchy-menu close" "$AUTOSTART_FILE"; then
    echo "[✓] Autostart sync already configured in $AUTOSTART_FILE"
  else
    echo "" >> "$AUTOSTART_FILE"
    echo "-- Ensure menu IPC state is cleanly initialized and synchronized on session startup" >> "$AUTOSTART_FILE"
    echo 'o.exec_on_start("omarchy-menu close")' >> "$AUTOSTART_FILE"
    echo "[✓] Added autostart sync hook to $AUTOSTART_FILE"
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload >/dev/null 2>&1 || true
    fi
  fi
fi

# 3. Install power profile optimizer & service
cp "$SCRIPT_DIR/omarchy-power-profile" "$BIN_DIR/omarchy-power-profile"
cp "$SCRIPT_DIR/omarchy-power-monitor" "$BIN_DIR/omarchy-power-monitor"
chmod +x "$BIN_DIR/omarchy-power-profile" "$BIN_DIR/omarchy-power-monitor"
mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/omarchy-power-optimizer.service" "$HOME/.config/systemd/user/omarchy-power-optimizer.service"
systemctl --user daemon-reload
systemctl --user enable --now omarchy-power-optimizer.service >/dev/null 2>&1 || true
echo "[✓] Installed and enabled omarchy-power-optimizer service"

echo ""
echo "Installation complete! All fixes and services are now active."
