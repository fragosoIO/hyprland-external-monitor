# Debugging Guide

If the automatic monitor switching isn't working, follow these steps:

## 1. Check if socat is installed
```bash
which socat
```
If nothing appears, install it:
```bash
sudo pacman -S socat
```

## 2. Verify the watcher is running
```bash
ps aux | grep monitor-watcher
```
You should see the process. If not, manually start it:
```bash
~/.config/hypr/scripts/monitor-watcher.sh &
```

## 3. Test monitor-switch.sh manually
With external monitor connected:
```bash
~/.config/hypr/scripts/monitor-switch.sh
```
Your laptop screen should turn off. 

Disconnect the monitor and run again - laptop screen should come back on.

**If this doesn't work, your monitor names are wrong. Run:**
```bash
hyprctl monitors
```
Update the monitor names in `monitor-switch.sh`.

## 4. Check environment variables
From a terminal inside Hyprland, run:
```bash
echo $HYPRLAND_INSTANCE_SIGNATURE
echo $XDG_RUNTIME_DIR
```
Both should show values. If `HYPRLAND_INSTANCE_SIGNATURE` is empty, you need to update `monitor-watcher.sh`:

Replace:
```bash
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
```

With:
```bash
SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n1)
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$SIGNATURE/.socket2.sock
```

## 5. Test if events are being received
Run this command:
```bash
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
```

Or if `HYPRLAND_INSTANCE_SIGNATURE` is empty:
```bash
SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n1)
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$SIGNATURE/.socket2.sock
```

Leave this running, then plug/unplug your monitor. You should see:
- `monitoradded>>HDMI-A-1` (or your monitor name)
- `monitorremoved>>HDMI-A-1`

**If you don't see events:**
- Make sure you're running this from a terminal INSIDE Hyprland (not SSH or another TTY)
- Check if the socket file exists:
  ```bash
  ls -la $XDG_RUNTIME_DIR/hypr/
  ```

## 6. Enable debug logging
Add logging to `monitor-watcher.sh`:

```bash
#!/bin/bash

LOGFILE="/tmp/monitor-watcher.log"
echo "Watcher started at $(date)" > $LOGFILE

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    echo "Event: $line" >> $LOGFILE
    if echo "$line" | grep -q "monitoradded\|monitorremoved"; then
        echo "Monitor event detected at $(date)" >> $LOGFILE
        sleep 1
        ~/.config/hypr/scripts/monitor-switch.sh >> $LOGFILE 2>&1
    fi
done
```

Or if using dynamic signature:
```bash
#!/bin/bash

LOGFILE="/tmp/monitor-watcher.log"
SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n1)

echo "Watcher started at $(date)" > $LOGFILE
echo "Using signature: $SIGNATURE" >> $LOGFILE

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$SIGNATURE/.socket2.sock | while read -r line; do
    echo "Event: $line" >> $LOGFILE
    if echo "$line" | grep -q "monitoradded\|monitorremoved"; then
        echo "Monitor event detected at $(date)" >> $LOGFILE
        sleep 1
        ~/.config/hypr/scripts/monitor-switch.sh >> $LOGFILE 2>&1
    fi
done
```

Kill the old watcher and restart:
```bash
pkill -f monitor-watcher
~/.config/hypr/scripts/monitor-watcher.sh &
```

Check the log:
```bash
cat /tmp/monitor-watcher.log
```

Plug/unplug your monitor and check the log again to see what's happening.

## 7. Common Issues

**Issue:** "No such file or directory" error for socket
- **Fix:** Use dynamic signature lookup (see Step 4)

**Issue:** Script works manually but not automatically
- **Fix:** Kill old processes and restart Hyprland
  ```bash
  pkill -f monitor-watcher
  # Then log out and back in
  ```

**Issue:** Laptop screen doesn't turn off
- **Fix:** Wrong monitor names in `monitor-switch.sh`. Check with `hyprctl monitors`

**Issue:** Events not detected
- **Fix:** Make sure you're running commands from a terminal inside Hyprland, not from SSH or another session
