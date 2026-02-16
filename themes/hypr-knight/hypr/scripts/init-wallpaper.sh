#!/bin/bash

# Kill any existing hyprpaper instance
killall hyprpaper
sleep 0.5

# Start hyprpaper
hyprpaper &

# Wait for it to initialize
sleep 1

# Set the wallpaper
WALLPAPER="$HOME/.config/hypr/wallpapers/batmobile.jpg"

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
