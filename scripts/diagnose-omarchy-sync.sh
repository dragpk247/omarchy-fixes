#!/usr/bin/env bash

# diagnose-omarchy-sync.sh - Diagnostic tool to inspect state synchronization across Omarchy components

set -euo pipefail

echo "=================================================="
echo "       Omarchy System Synchronization Audit       "
echo "=================================================="
echo ""

# 1. Menu Layer & Quickshell Sync
echo "[1] Checking Quickshell Menu Layer & IPC..."
MENU_LAYER=$(hyprctl layers 2>/dev/null | grep "namespace: omarchy-menu" || true)
if [[ -n "$MENU_LAYER" ]]; then
  echo "    - Menu layer surface: ACTIVE (Visible on screen)"
else
  echo "    - Menu layer surface: INACTIVE (Hidden)"
fi

if command -v omarchy-menu >/dev/null 2>&1; then
  MENU_PATH=$(which omarchy-menu)
  echo "    - Active omarchy-menu binary: $MENU_PATH"
  PING_RES=$(omarchy-menu ping 2>&1 || true)
  if [[ "$PING_RES" == *"ok"* ]]; then
    echo "    - Quickshell Menu IPC Ping: OK"
  else
    echo "    - Quickshell Menu IPC Ping: FAILED / NOT RESPONDING ($PING_RES)"
  fi
fi

# Check autostart hook
if grep -q "omarchy-menu close" "$HOME/.config/hypr/autostart.lua" 2>/dev/null; then
  echo "    - Autostart synchronization: ENABLED in ~/.config/hypr/autostart.lua"
else
  echo "    - Autostart synchronization: NOT FOUND in ~/.config/hypr/autostart.lua (Consider adding o.exec_on_start(\"omarchy-menu close\"))"
fi

echo ""

# 2. Night Light (hyprsunset) Sync
echo "[2] Checking Night Light (hyprsunset) Sync..."
if pgrep -x hyprsunset >/dev/null 2>&1; then
  SUNSET_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null || echo "Unknown")
  echo "    - hyprsunset process: RUNNING"
  echo "    - Active color temperature: $SUNSET_TEMP"
else
  echo "    - hyprsunset process: NOT RUNNING"
fi

echo ""

# 3. Idle / Stay-Awake Status
echo "[3] Checking Idle & Stay-Awake Status..."
STAY_AWAKE_FILE="$HOME/.local/state/omarchy/indicators/stay-awake"
if [[ -f "$STAY_AWAKE_FILE" ]]; then
  echo "    - Stay-Awake State File: PRESENT (Sleep/Lock Inhibited)"
else
  echo "    - Stay-Awake State File: ABSENT (Normal Sleep/Lock Schedule Active)"
fi

echo ""

# 4. Audio Engine Status (WirePlumber / PipeWire)
echo "[4] Checking Audio Engine (PipeWire / WirePlumber)..."
if command -v wpctl >/dev/null 2>&1; then
  DEFAULT_SINK=$(wpctl status 2>/dev/null | grep -A 5 "Audio/Sink" | grep "\*" || true)
  if [[ -n "$DEFAULT_SINK" ]]; then
    echo "    - Active Audio Sink: $(echo "$DEFAULT_SINK" | sed 's/^[ \t]*//')"
  else
    echo "    - Active Audio Sink: Default detected"
  fi
fi

echo ""

# 5. Battery Charging Threshold
echo "[5] Checking Battery & Hardware Power Limit..."
BAT_LIMIT="/sys/class/power_supply/BAT0/charge_control_end_threshold"
if [[ -f "$BAT_LIMIT" ]]; then
  echo "    - Charge Control End Threshold: $(cat "$BAT_LIMIT")%"
elif [[ -f "/sys/class/power_supply/BAT1/charge_control_end_threshold" ]]; then
  echo "    - Charge Control End Threshold: $(cat "/sys/class/power_supply/BAT1/charge_control_end_threshold")%"
else
  echo "    - Charge Control End Threshold: Not supported or not accessible on this device"
fi

echo ""
echo "=================================================="
echo "Audit complete! For detailed fix guides, see the fixes/ directory."
echo "=================================================="
