# Fix 06: Audio Volume & Mute State Desync (PipeWire / WirePlumber)

## Symptoms
- Adjusting audio via external hardware (DAC wheel, Bluetooth headphone buttons, physical keyboard volume dial) changes the volume, but the Omarchy status bar icon or OSD does not update.
- Audio is muted in WirePlumber, but the bar shows sound active.

## Root Cause
Quickshell communicates with PipeWire through WirePlumber. When external devices alter the audio stream directly at the hardware layer, or when the system wakes from sleep, WirePlumber's node properties update, but Quickshell's event listener may miss the node change event.

## Solutions

### 1. Toggle Audio State to Force Sync
```bash
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

### 2. Inspect PipeWire Sink Status
```bash
wpctl status | grep -A 8 "Audio/Sink"
```

### 3. Restart Audio Daemons
If WirePlumber has crashed or stopped publishing D-Bus signals:
```bash
systemctl --user restart pipewire wireplumber pipewire-pulse
```
