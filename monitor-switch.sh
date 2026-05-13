#!/bin/bash

LAPTOP="eDP-1"
EXTERNAL="" # will be determined dynamically

if hyprctl monitors | grep -q "HDMI-A-1\|DP-1"; then
  # External monitor connected - disable laptop screen
  # First, find the active external monitor name
  EXTERNAL=$(hyprctl monitors | grep -E "Monitor HDMI-A-1|Monitor DP-1" | head -n1 | awk '{print $2}')

  # Move all workspaces from laptop to external monitor
  for ws in $(hyprctl workspaces | grep -B1 "$LAPTOP" | grep "ID" | awk '{print $3}'); do
    hyprctl dispatch moveworkspacetomonitor "$ws $EXTERNAL"
  done

  # Now disable the laptop screen
  hyprctl keyword monitor "$LAPTOP,disable"
else
  # No external monitor - enable laptop screen
  hyprctl keyword monitor "$LAPTOP,preferred,auto,1"
fi
