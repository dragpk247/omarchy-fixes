# Fix 01: Quickshell Menu State Desync & Dead Shortcut

## Symptoms
- Pressing `SUPER + SPACE` (or `SUPER + ALT + SPACE`) fails to open the menu.
- The keybinding appears dead on the first press, but might work after a second press or after running terminal commands.
- Standalone Super (Windows key) does not trigger any action.

## Root Cause
1. **Modifier vs Trigger:** Hyprland configures `SUPER` strictly as a modifier key (`modmask: 64`). Pressing Super alone is not bound by default; it requires an accompanying key like `SPACE`.
2. **Quickshell State Desync:** In `/usr/share/omarchy/shell/shell.qml`, `omarchy-menu toggle` queries `isPluginOpen(id)`:
   ```javascript
   function toggle(pluginId, payloadJson) {
     var id = shell.pluginRegistry.resolveEnabledId(pluginId)
     return isPluginOpen(id) ? hide(id) : summon(id, payloadJson)
   }
   ```
   If a user plugin (like a cloned `jpi.menu`) closes due to focus loss or Wayland layer-surface dismissal without Quickshell setting `opened = false`, Quickshell believes the window is already open. On the next toggle press, it runs `hide()` on an already invisible window.

## Solutions

### 1. Self-Healing Wrapper (Automatic Detection & Recovery)
Install the wrapper at `~/.local/bin/omarchy-menu`:
- Checks `hyprctl layers` for `namespace: omarchy-menu`.
- If the menu was closed and fails to appear after a toggle, it recognizes the desync.
- Fires a desktop notification alert with an action button.
- Immediately executes `close` and `summon`, popping the menu open without wasted keystrokes.

### 2. Autostart Clean State Sync
In `~/.config/hypr/autostart.lua`:
```lua
o.exec_on_start("omarchy-menu close")
```
This ensures the menu state is initialized to `false` when logging in.

### 3. Immediate CLI Recovery
If ever stuck manually:
```bash
omarchy-menu close
omarchy-menu ping
omarchy-menu toggle
```
