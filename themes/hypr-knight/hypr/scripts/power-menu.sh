#!/bin/bash

# Configuration
# Usage: echo -e "Option" | wofi -d

entries=" Lock\n Logout\n Suspend\n Reboot\n Shutdown"

selected=$(echo -e "$entries" | wofi --width 250 --height 240 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

case $selected in
  lock)
    hyprlock
    ;;
  logout)
    hyprctl dispatch exit
    ;;
  suspend)
    systemctl suspend
    ;;
  reboot)
    systemctl reboot
    ;;
  shutdown)
    systemctl poweroff
    ;;
esac
