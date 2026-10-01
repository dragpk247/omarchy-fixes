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

## Universal Global Laptop Architecture

While **Fix 09** targets specific ASUS ROG Flow hardware, **Fix 08** is the **Universal / Global Laptop Profile** designed to optimize **any modern laptop** running Omarchy (Dell XPS, Lenovo ThinkPad/Legion, Framework, HP Spectre, Acer, ASUS, etc.), supporting both **Intel Core** and **AMD Ryzen** architectures.

### 1. Global Hardware-Agnostic Optimizations
- **Universal ACPI Platform Profile:** Leverages the Linux kernel standard `/sys/firmware/acpi/platform_profile` (`quiet`, `balanced`, `performance`) supported by Dell, Lenovo, HP, Framework, and ASUS.
- **Universal CPU Energy-Performance Bias (`EPP`):** Automatically detects and applies `power` scaling across all CPU cores for both `intel_pstate` and `amd-pstate-epp` drivers (`/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference`).
- **Universal PCIe ASPM:** Enforces link-state power management (`powersave`) across all PCIe buses via `/sys/module/pcie_aspm/parameters/policy`.
- **Universal Audio Fast-Sleep:** Puts Intel/Realtek HDA audio codecs into low-power D3cold state after 1s of silence (`/sys/module/snd_hda_intel/parameters/power_save = 1`).
- **Universal Storage APST Sleep:** Extends dirty page flushing from 15s to 60s (`vm.dirty_writeback_centisecs = 6000`), letting any NVMe SSD controller enter deep Autonomous Power State Transitions (APST).
- **Universal CPU Deep C-States:** Disables continuous NMI watchdog timer interrupts (`kernel.nmi_watchdog = 0`) so all Intel/AMD CPU threads stay asleep during idle.
- **Universal Wayland Compositor Throttling:** Disables unnecessary Hyprland animation loops to minimize continuous GPU wakeups.

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
