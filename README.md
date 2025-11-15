#Omarchy Hyprland Automatic Monitor Switching

**Applicable for Omarchy** 
Automatically disable your laptop screen when an external monitor is connected, and re-enable it when disconnected.

## Setup

### 1. Install socat
```bash
sudo pacman -S socat
```

### 2. Find your monitor names
```bash
hyprctl monitors
```
Note your laptop screen (usually `eDP-1`) and external monitor names (e.g., `HDMI-A-1`, `DP-1`).

### 3. Create scripts directory
```bash
mkdir -p ~/.config/hypr/scripts
```

### 4. Add the scripts
- Create `~/.config/hypr/scripts/monitor-switch.sh`
- Create `~/.config/hypr/scripts/monitor-watcher.sh`

Update monitor names in `monitor-switch.sh` to match your setup.

### 5. Make scripts executable
```bash
chmod +x ~/.config/hypr/scripts/monitor-switch.sh
chmod +x ~/.config/hypr/scripts/monitor-watcher.sh
```

### 6. Add to Hyprland Monitor config
Edit `~/.config/hypr/monitors.conf` and add:
```bash
exec-once = ~/.config/hypr/scripts/monitor-watcher.sh
```

### 7. Restart Hyprland
Log out and log back in.

## Uninstallation

```bash
# Remove from Hyprland config
# Delete the exec-once line from ~/.config/hypr/monitors.conf

# Stop the watcher
pkill -f monitor-watcher

# Remove scripts (optional)
rm -rf ~/.config/hypr/scripts/
```
