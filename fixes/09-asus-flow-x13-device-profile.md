# Device Profile: ASUS ROG Flow X13 (GV301QE) Optimizations

Comprehensive hardware-specific tuning and battery optimization guide for the **ASUS ROG Flow X13 (GV301QE)** running Omarchy (Arch Linux + Hyprland + Quickshell).

---

## 💻 Hardware Specifications
* **CPU:** AMD Ryzen 9 5900HS (8 cores, 16 threads)
* **iGPU:** AMD Cezanne Radeon Graphics (`amdgpu`)
* **dGPU:** NVIDIA GeForce RTX 3050 Ti Laptop GPU (`nvidia`)
* **Display Panel:** Sharp LQ134N1JW52 (13.4" 16:10, 1920x1200 @ 60Hz / 120Hz)
* **Audio Codec:** Realtek ALC294 (`snd_hda_intel`)
* **Battery:** 62 Wh Li-ion
* **Charging Interface:** USB-PD (Proprietary 100W Asus VDM, 65W standard 3rd-party cap)

---

## ⚡ Applied Optimizations

### 1. AMD Cezanne Adaptive Backlight Management (ABM)
* **Sysfs Path:** `/sys/class/drm/card*-eDP-1/amdgpu/panel_power_savings`
* **Configuration:** Level `1`
* **Impact:** Analyzes on-screen pixel contrast and intelligently dims backlight LED current. Provides ~1.0W–1.5W power reduction with imperceptible color shift.

### 2. Kernel NMI Watchdog Deactivation
* **Sysctl File:** `/etc/sysctl.d/99-zzz-laptop-battery-optimizations.conf` (`kernel.nmi_watchdog = 0`)
* **Impact:** Eliminates periodic hardware tick interrupts across all 16 CPU threads, allowing the Ryzen 5900HS to drop and remain in deep CPU C-states (C6/C8/C10).

### 3. Extended NVMe Storage Writeback Window
* **Sysctl File:** `/etc/sysctl.d/99-zzz-laptop-battery-optimizations.conf` (`vm.dirty_writeback_centisecs = 6000`)
* **Impact:** Extends memory cache disk flushing from 15 seconds to 60 seconds, allowing the NVMe SSD controller and PCIe bus to stay in Autonomous Power State Transitions (APST) sleep.

### 4. Audio Codec Fast Standby
* **Sysfs Path:** `/sys/module/snd_hda_intel/parameters/power_save`
* **Configuration:** `1` second (down from 10s default)
* **Impact:** Suspends the Realtek ALC294 DAC amplifier into low-power D3cold standby after 1 second of audio silence.

### 5. Display Refresh Rate & Scaling Controls
* **Utility:** `omarchy-hyprland-refresh-rate [60|120]`
* **Hyprland Menu Widget:** Seamless 60Hz / 120Hz quick-switch pill buttons integrated directly into the Omarchy top-bar display panel.
* **Impact:** Capping at 60Hz halves GPU display bus scanout frequency, saving 1.5W–3W on battery.

### 6. NVIDIA Dynamic Boost & Power Daemon Throttling Prevention
* **Systemd:** `systemctl mask nvidia-powerd`
* **Impact:** Prevents the dGPU from pulling 35W+ power spikes when AC connects, avoiding voltage droop and preventing 3rd-party 65W/100W GaN chargers (e.g., UGREEN, Anker) from tripping into safety cutoff.

### 7. PCIe ASPM & ACPI Platform Profile
* **Platform Profile:** Locked to `quiet` (`/sys/firmware/acpi/platform_profile`)
* **CPU EPP:** Set to `power` (`/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference`)
* **PCIe ASPM:** Set to `powersave` (`/sys/module/pcie_aspm/parameters/policy`)

---

## 🛠️ Validation & Monitoring

Verify the active hardware power states with this quick audit:

```bash
# Check AMD panel power savings
cat /sys/class/drm/card*-eDP-1/amdgpu/panel_power_savings  # Output: 1

# Check audio codec power save
cat /sys/module/snd_hda_intel/parameters/power_save       # Output: 1

# Check kernel NMI watchdog & writeback
sysctl kernel.nmi_watchdog vm.dirty_writeback_centisecs    # Output: 0, 6000

# Check active refresh rate
omarchy-hyprland-refresh-rate                             # Output: 60 (or 120)

# Check active battery inflow / discharge rate
cat /sys/class/power_supply/BAT*/status
cat /sys/class/power_supply/BAT*/power_now
```
