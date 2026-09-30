# Fix 03: Workspaces Widget & Hyprland IPC Desync

## Symptoms
- The top status bar highlights workspace 1, even though you are actively focused on workspace 3.
- After connecting or disconnecting an external monitor (HDMI / DisplayPort) or closing a laptop lid, workspace dots are missing or misplaced.

## Root Cause
Quickshell listens to Hyprland compositor events through `/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`.

During monitor hotplugging, Hyprland reallocates workspaces across physical displays. If an event is dropped during the Wayland output reconfiguration, or if the socket buffer overflows during rapid workspace switching, Quickshell's model can retain stale workspace mappings.

## Solutions

### 1. Rapid Socket Resync
Switching workspaces once forwards a new `workspace>>` and `focusedmon>>` event down `.socket2.sock`:
```bash
hyprctl dispatch workspace e+1
hyprctl dispatch workspace e-1
```

### 2. Restart Shell
To completely rebuild the bar layout across all connected monitors:
```bash
omarchy restart shell
```
