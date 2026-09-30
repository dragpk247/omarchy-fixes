# Fix 04: Desktop Theme & Application Palette Desync

## Symptoms
- After running `omarchy theme set <theme>`, the status bar changes color, but terminals, GTK applications, or the wallpaper remain on the previous theme.
- Open applications display mismatched dark/light mode accents.

## Root Cause
A theme change in Omarchy broadcasts modifications across multiple independent subsystems:
1. `~/.config/hypr/` look and feel colors
2. Quickshell bar `colors.toml`
3. Terminal configuration files (Alacritty / Kitty / Foot / Ghostty)
4. GTK 3/4 via `gsettings`
5. Qt 5/6 via Kvantum / `qt6ct`
6. Wallpaper daemon (hyprpaper / swww / wbg)

If a custom theme hook under `~/.config/omarchy/hooks/theme-set.d/` returns an error or blocks, the rest of the theme pipeline aborts. Additionally, certain running apps do not re-read their config without an explicit signal or window restart.

## Solutions

### 1. Force Full Theme Re-application
```bash
omarchy theme set <theme-name>
```

### 2. Reset Theme Components
```bash
omarchy refresh theme
omarchy restart terminal
```

### 3. Check for Failing Theme Hooks
Inspect custom automation hooks:
```bash
ls -la ~/.config/omarchy/hooks/theme-set.d/
```
Ensure all hook scripts have executable permissions (`chmod +x`) and exit with status code 0.
