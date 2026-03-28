#!/bin/bash
# Select wallpaper with Zenity and apply it

set -e

CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# 1. Open file picker
IMAGE=$(zenity --file-selection --title="Select Wallpaper" --file-filter="Images | *.jpg *.jpeg *.png *.gif *.webp")

# 2. Exit when no file was selected
if [[ -z "$IMAGE" ]]; then
    exit 0
fi

# Resolve to absolute path for hyprpaper
if command -v realpath >/dev/null 2>&1; then
    IMAGE=$(realpath "$IMAGE")
fi

mkdir -p "$(dirname "$CONFIG_FILE")"
touch "$CONFIG_FILE"

escape_sed() {
    printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

set_or_append() {
    local key="$1"
    local value="$2"
    local escaped
    escaped=$(escape_sed "$value")

    if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$CONFIG_FILE"; then
        sed -Ei "s|^[[:space:]]*${key}[[:space:]]*=.*|${key} = ${escaped}|" "$CONFIG_FILE"
    else
        printf '%s = %s\n' "$key" "$value" >> "$CONFIG_FILE"
    fi
}

# 3. Persist selected wallpaper
set_or_append "preload" "$IMAGE"
set_or_append "wallpaper" ",$IMAGE"
set_or_append "ipc" "on"

# 4. Apply live when possible
if pgrep -x hyprpaper >/dev/null 2>&1 && command -v hyprctl >/dev/null 2>&1; then
    if ! hyprctl hyprpaper unload all >/dev/null 2>&1; then
        pkill -x hyprpaper >/dev/null 2>&1 || true
        hyprpaper >/dev/null 2>&1 &
        sleep 0.3
    fi

    hyprctl hyprpaper preload "$IMAGE" >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper ",$IMAGE" >/dev/null 2>&1 || true
else
    pkill -x hyprpaper >/dev/null 2>&1 || true
    hyprpaper >/dev/null 2>&1 &
fi

notify-send "Wallpaper Updated" "Changed to $(basename "$IMAGE")"
