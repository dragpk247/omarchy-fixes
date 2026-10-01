# Fix 08: Laptop Power-Saving & USB-PD Charging Throttling

## Symptoms
- Laptop fails to charge or discharges while plugged into a 3rd-party USB-C PD charger (e.g., 65W–100W GaN chargers like UGREEN, Anker).
- Battery reading gets stuck (e.g., at 3% or near empty), and charging indicator LED blinks/flashes orange.
- High power draw on AC causes voltage droop, tripping SBIOS/EC safety cutoffs (`ERROR! Client (presumably SBIOS) has requested to disable Dynamic Boost DC controller`).
- High refresh rate (120Hz+) and Hyprland visual effects consume excessive wattage, draining the battery even while plugged in.

## Root Cause
1. **Manufacturer Embedded Controller (EC) Caps on 3rd-Party PD:** Laptops such as the ASUS ROG Flow series restrict non-OEM USB-C chargers to ~60W–65W.
2. **Auto-Performance Power Surge:** Connecting AC power automatically triggers daemons (like `asusd` and `nvidia-powerd`) to switch the system into `Performance` mode, spiking CPU/GPU boost wattage beyond what the 3rd-party charger can supply.
3. **Display & Compositor Overhead:** Running high refresh rates (120Hz/165Hz) and heavy Hyprland animations draws continuous power from the iGPU/dGPU and memory controller.

## Automated Solution

We provide an automated optimizer and continuous systemd service that enforces conservative, efficient power-saving states even while on AC power.

### 1. What the Optimizer Tunes
- **Display Refresh Rate:** Caps internal laptop display at **60Hz** via Hyprland's native Lua IPC (`hl.monitor`).
- **Hyprland Effects:** Disables heavy animations (`hl.config({ animations = { enabled = false } })`) to minimize render loop wakeups.
- **CPU Energy-Performance-Preference (`EPP`):** Writes `power` to `/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference`.
- **Platform Profile:** Locks ACPI platform profile to `quiet` (`/sys/firmware/acpi/platform_profile`).
- **PCIe Active State Power Management:** Enables `powersave` on PCIe links.
- **Discrete GPU:** Ensures runtime suspend (`supergfxctl -m Hybrid` or `Integrated` with `nvidia-powerd` masked).

### 2. Manual Commands & Service Management
```bash
# Check running power optimizer status
systemctl --user status omarchy-power-optimizer.service

# Manually trigger power-saving profile
omarchy-power-profile

# View active power rate and battery inflow
cat /sys/class/power_supply/BAT*/status
cat /sys/class/power_supply/BAT*/power_now
```

### 3. Files Included in Repository
- `scripts/omarchy-power-profile`: Script that applies the hardware, CPU, and Hyprland power profiles.
- `scripts/omarchy-power-monitor`: Monitoring loop that applies profiles on power state changes.
- `scripts/omarchy-power-optimizer.service`: Systemd user service unit for autostart.
