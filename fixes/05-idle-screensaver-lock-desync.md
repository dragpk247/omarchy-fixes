# Fix 05: Idle, Screensaver & Lock Screen Desync

## Symptoms
- The system screen fails to turn off or lock after the configured timeout.
- The "Stay Awake" (caffeine) icon shows inactive, but the system never idles.
- Alternatively, the screen sleeps unexpectedly even while watching a video or presenting.

## Root Cause
Omarchy coordinates idle timers via both `hypridle` and Quickshell's custom idle plugin (`plugins/services/idle/Service.qml`).

1. **State File Desync:** The "Stay Awake" toggle writes a state file at `~/.local/state/omarchy/indicators/stay-awake`. If this file is created by an external script or left behind after an improper shutdown, sleep/lock is permanently inhibited.
2. **Wayland Inhibit Locks:** Web browsers (e.g. Chrome/Firefox playing audio or media) or games can hold Wayland idle inhibitor locks without updating Omarchy's bar widget.

## Solutions

### 1. Check & Clear the Stay-Awake File
```bash
# Check if inhibited:
ls -l ~/.local/state/omarchy/indicators/stay-awake

# Clear inhibition:
rm -f ~/.local/state/omarchy/indicators/stay-awake
omarchy toggle idle
```

### 2. Inspect Idle Service Status
```bash
omarchy-shell shell call idle status "{}"
```

### 3. Check for Wayland Idle Inhibitors
```bash
hyprctl layers | grep -i idle
```
