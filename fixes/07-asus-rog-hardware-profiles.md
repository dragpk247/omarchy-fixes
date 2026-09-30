# Fix 07: ROG Asus Hardware Profiles & Battery Limit Desync

## Symptoms
- Battery charge threshold stays at 100% despite toggling 80% limit via shortcut (`SUPER + ALT + B`).
- Fan profiles (Quiet / Performance / Balanced) reset unexpectedly to Balanced after unplugging or suspending the laptop.
- Dedicated GPU status desynchronizes between `supergfxctl` and the battery indicator.

## Root Cause
On ASUS ROG and Zephyrus laptops, power profiles and battery thresholds are managed by the `asus-wmi` kernel module, `asusctl`, and `supergfxctl`.

When AC power is connected or disconnected, the Linux kernel and UPower trigger power profile events that can override custom userspace limits. If a script fails to write to `/sys/class/power_supply/BAT0/charge_control_end_threshold` with appropriate permissions or doesn't persist across reboots, the hardware defaults take over.

## Solutions

### 1. Check Active Threshold
```bash
cat /sys/class/power_supply/BAT*/charge_control_end_threshold
```

### 2. Manual Toggle / Resync
```bash
asus-battery-toggle
asus-profile-toggle
```

### 3. Check Asus Daemon Status
```bash
systemctl status asusd.service supergfxd.service
```

### 4. GPU Mode Check
```bash
supergfxctl -g
```
