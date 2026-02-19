#!/bin/bash
# v9-hyprdots Theme Switcher
# Usage: ./switch-theme.sh

set -e

# --- Palette ---
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
R='\033[0;31m'
G='\033[0;32m'
B='\033[0;34m'
C='\033[0;36m'
W='\033[1;37m'
LOG="/tmp/v9-theme-switch.log"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$SCRIPT_DIR" # Assuming script is run from repo root or similiar for now, improved logic below

# Ensure we can find the themes directory
if [[ -d "$SCRIPT_DIR/themes" ]]; then
    THEMES_DIR="$SCRIPT_DIR/themes"
elif [[ -d "$HOME/.config/v9-hyprdots/themes" ]]; then
    THEMES_DIR="$HOME/.config/v9-hyprdots/themes"
elif [[ -d "$SCRIPT_DIR/../themes" ]]; then
    THEMES_DIR="$SCRIPT_DIR/../themes"
else
    # Fallback/Error
    THEMES_DIR=""
fi

print_banner() {
    clear
    echo -e "${DIM}----------------------------------------------------------------${RESET}"
    echo -e "${C} :: v9-hyprdots Theme Switcher :: ${Reset}"
    echo -e "${DIM}----------------------------------------------------------------${RESET}"
    echo
}

step() {
    echo -e "${B}>>${RESET} ${W}$1${RESET}"
}

success() {
    echo -e "   ${G}OK${RESET} $1"
}

error() {
    echo -e "   ${R}ERROR${RESET} $1"
}

warn() {
    echo -e "   ${C}warn${RESET} $1"
}

select_theme() {
    echo -e "Select a theme to apply:"
    echo -e "   ${B}1)${RESET} Minimal"
    echo -e "   ${B}2)${RESET} Hypr-Knight"
    echo -n -e "Enter choice [1-2]: "
    read -r choice

    case $choice in
        1) THEME="minimal" ;;
        2) THEME="hypr-knight" ;;
        *) error "Invalid choice"; exit 1 ;;
    esac
}

apply_theme() {
    local theme_path="$THEMES_DIR/$THEME"
    
    if [[ ! -d "$theme_path" ]]; then
        error "Theme directory not found: $theme_path"
        exit 1
    fi

    step "Applying theme: ${BOLD}$THEME${RESET}"

    # Backup existing configs
    mkdir -p ~/.config
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$HOME/.config/v9_backup_$TIMESTAMP"
    
    mkdir -p "$BACKUP_DIR"
    
    # List of directories to manage
    DIRS=(hypr waybar dunst kitty wofi cava btop)
    
    for d in "${DIRS[@]}"; do
        if [[ -d "$HOME/.config/$d" ]]; then
            cp -r "$HOME/.config/$d" "$BACKUP_DIR/"
        fi
    done
    success "Backup created at $BACKUP_DIR"

    # Copy new configs
    # We use rsync to merge/overwrite. 
    # Note: We are copying contents of themes/<theme>/ to ~/.config/
    
    echo -n -e "   ${DIM}→${RESET} Syncing configs... "
    if rsync -av "$theme_path/" "$HOME/.config/" &> "$LOG"; then
         # Fix wallpaper path to be absolute (hyprpaper requirement)
         sed -i "s|~|$HOME|g" "$HOME/.config/hypr/hyprpaper.conf" || true
         echo -e "${G}Done${RESET}"
    else
         echo -e "${R}Fail${RESET}"
         exit 1
    fi
    
    # Reload Hyprland if running
    if pgrep -x "Hyprland" > /dev/null; then
        step "Reloading Hyprland..."
        hyprctl reload &> /dev/null
        
        # Reload key components explicitly if needed
        killall -SIGUSR2 waybar 2>/dev/null || true
        killall dunst 2>/dev/null || true
        
        # Reload Wallpaper
        step "Reloading Wallpaper..."
        pkill hyprpaper || true
        sleep 1
        hyprpaper &>/dev/null &
        
        success "Hyprland reloaded"
    else
        warn "Hyprland not running. configs applied for next session."
    fi
}

# --- Main ---
print_banner

if [[ ! -d "$THEMES_DIR" ]]; then
    error "Themes directory not found at $THEMES_DIR"
    echo "Please run this script from the repository root or ensure 'themes' folder exists."
    exit 1
fi

if [[ -n "$1" ]]; then
    THEME="$1"
    # rudimentary validation
    if [[ ! -d "$THEMES_DIR/$THEME" ]]; then
         error "Invalid theme specified: $THEME"
         exit 1
    fi
else
    select_theme
fi

apply_theme

echo
success "Theme setup complete!"
echo
