# Fix 02: Night Light (hyprsunset) State Desync

## Symptoms
- The screen color temperature shifts to warm/blue, but the top bar Night Light icon does not illuminate or change state.
- Alternatively, the bar indicator shows Night Light active, but the screen is displaying standard daylight 6500K color.

## Root Cause
In `/usr/share/omarchy/shell/plugins/services/nightlight/Service.qml`, Quickshell only executes its `statusProbe` (`hyprctl hyprsunset temperature`) when the shell first starts up (`Component.onCompleted: refresh()`) or when explicitly toggled through the IPC interface.

If `hyprsunset` restarts, crashes, or is altered by background cron jobs / sunset schedulers directly, Quickshell receives no D-Bus or socket signal and stays in the previous state.

## Solutions

### 1. Manual Resync / Toggle
Force the shell to toggle and re-synchronize:
```bash
omarchy toggle nightlight
```
Or query current temperature:
```bash
hyprctl hyprsunset temperature
```

### 2. Restart Daemon
If `hyprsunset` is unresponsive:
```bash
omarchy restart hyprsunset
```
Or check process status:
```bash
pgrep -l hyprsunset
```
