# Fix 11: Spotify Performance & Battery Optimizer (Wayland + Background Throttling)

## Symptoms
- Spotify consumes 15%–25% continuous CPU even while playing basic audio or sitting in the background.
- Fuzzy or blurry interface and text scaling on fractional Wayland displays (e.g. 1.6x on 1920x1200 / 2560x1600).
- High GPU render cycles and memory footprint caused by animated looping Canvas videos and unthrottled Chromium Embedded Framework (CEF) render loops when the window is hidden or on another workspace.

---

## ⚡ Root Cause
By default on Linux, Spotify launches in **XWayland emulation mode** (`--ozone-platform=x11`), using software CPU rendering instead of GPU rasterization for UI composition. Furthermore, CEF does not throttle background iframe and DOM paint events when the window is hidden behind other applications or moved to inactive workspaces.

---

## 🚀 Optimization Solution

### 1. Native Wayland & Hardware Acceleration
We wrap the Spotify executable with performance and power-efficiency flags:
- `--ozone-platform=wayland`: Eliminates the XWayland translation layer; provides crystal-sharp vector fonts at fractional scaling (1.6x).
- `--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder`: Offloads video decoding to the AMD VCN / Intel VA-API engine.
- `--enable-gpu-rasterization` & `--enable-zero-copy`: Directly renders UI tiles in GPU VRAM without CPU-to-RAM round trips.

### 2. Deep Background Throttling (When Hidden or Inactive)
- `ThrottleDisplayNoneAndVisibilityHiddenCrossOriginIframes`: Suspends background DOM render trees when the Spotify window is not actively visible.
- `WebContentsFrameRateLimiting`: Caps frame rates to minimum thresholds when running behind other active windows.
- `--disable-background-networking`: Suppresses unneeded Chromium background telemetry ping intervals.

---

## 🛠️ Files Installed
- **Launcher Wrapper:** [`~/.local/bin/spotify`](file:///home/jpi/.local/bin/spotify) (Overrides `/usr/bin/spotify` in user `$PATH`).
- **Desktop Launcher Override:** [`~/.local/share/applications/spotify.desktop`](file:///home/jpi/.local/share/applications/spotify.desktop).

## 📊 Verification
```bash
# Check running Spotify platform
ps aux | grep -i spotify | grep ozone-platform=wayland

# Check active CPU usage (should drop from 20%+ down to ~4%-8% active, <1% background)
top -b -n 1 -p $(pgrep -d',' -f "/opt/spotify/spotify")
```
