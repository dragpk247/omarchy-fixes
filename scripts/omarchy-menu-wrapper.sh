#!/bin/bash

# Custom Omarchy Menu Wrapper with Self-Healing Desync Detection & Alerting
# Wraps /usr/share/omarchy/bin/omarchy-menu to catch Quickshell state desyncs.

set -euo pipefail

REAL_MENU="/usr/share/omarchy/bin/omarchy-menu"
verb="${1-toggle}"
route="${2-root}"

# For any verb other than toggle, delegate directly
if [[ "$verb" != "toggle" ]]; then
  exec "$REAL_MENU" "$@"
fi

is_menu_layer_visible() {
  hyprctl layers 2>/dev/null | grep -q "namespace: omarchy-menu"
}

if is_menu_layer_visible; then
  # Menu is currently visible on screen; user wants to close it
  exec "$REAL_MENU" close
fi

# Menu is NOT visible; user wants to open it
"$REAL_MENU" toggle "$route"

# Give Quickshell/Wayland a moment to render the layer surface
sleep 0.08

if is_menu_layer_visible; then
  # Successfully opened
  exit 0
fi

# If we reached here, the menu layer is STILL not visible.
# This means Quickshell's internal opened state was desynchronized (it ran hide() instead of summon()).

# 1. Alert user via desktop notification (Option A + B: notifies and includes manual reset action)
if command -v omarchy-notification-send >/dev/null 2>&1; then
  omarchy-notification-send \
    -g "󰀻" \
    -u normal \
    "Menu Desync Detected" \
    "Menu state was desynchronized. Auto-recovered. Click to force full reset." \
    --exec "$REAL_MENU" close &
fi

# 2. Trigger auto-reset fix immediately (Option A: seamless recovery)
"$REAL_MENU" close
sleep 0.05
exec "$REAL_MENU" summon "$route"
