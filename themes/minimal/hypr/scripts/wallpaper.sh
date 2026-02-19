#!/bin/bash
# Select wallpaper with Zenity and apply it

# 1. Open File Picker
IMAGE=$(zenity --file-selection --title="Select Wallpaper" --file-filter="Images | *.jpg *.jpeg *.png *.gif")

# 2. Check if user selected something
if [ -z "$IMAGE" ]; then
    exit 0
fi

# 3. Update Config File (Persist across reboots)
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Replace preload line
sed -i "s|^preload = .*|preload = $IMAGE|" "$CONFIG_FILE"
# Replace wallpaper line (assuming "," for all monitors)
sed -i "s|^wallpaper = .*|wallpaper = ,$IMAGE|" "$CONFIG_FILE"

# 4. Apply Instantly (Live)
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$IMAGE"
hyprctl hyprpaper wallpaper ",$IMAGE"

# Notify user
notify-send "Wallpaper Updated" "Changed to $(basename "$IMAGE")"
