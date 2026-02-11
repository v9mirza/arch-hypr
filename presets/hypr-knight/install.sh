#!/bin/bash
# v9-hyprdots bootstrap (Modern Edition)
# "Tactical, Fast, Deterministic"

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
LOG="/tmp/v9-bootstrap.log"

# --- Helpers ---
print_banner() {
    clear
    echo -e "${DIM}----------------------------------------------------------------${RESET}"
    echo -e "${B}"
    cat << "EOF"
 ██╗   ██╗ █████╗     ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██████╗  ██████╗ ████████╗███████╗
 ██║   ██║██╔══██╗    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
 ██║   ██║╚██████║    ███████║ ╚████╔╝ ██████╔╝██████╔╝██║  ██║██║   ██║   ██║   ███████╗
 ╚██╗ ██╔╝ ╚═══██║    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║  ██║██║   ██║   ██║   ╚════██║
  ╚████╔╝  ██████║    ██║  ██║   ██║   ██║     ██║  ██║██████╔╝╚██████╔╝   ██║   ███████║
   ╚═══╝   ╚═════╝    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
EOF
    echo -e "${RESET}"
    echo -e "${DIM}----------------------------------------------------------------${RESET}"
    echo -e "${C} :: v9-hyprdots Hypr-Knight :: ${DIM}v2.1${RESET}"
    echo
}

step() {
    echo -e "${B}::${RESET} ${W}$1${RESET}"
}

success() {
    echo -e "   ${G}✔${RESET} $1"
}

error() {
    echo -e "   ${R}✖${RESET} $1"
}

warn() {
    echo -e "   ${C}‼${RESET} $1"
}

# $1 = Message, $2.. = Command
run_with_spinner() {
    local msg="$1"
    shift
    
    echo -n -e "   ${DIM}→${RESET} $msg... "
    
    # Run command in background
    "$@" &> "$LOG" &
    local pid=$!
    
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "[%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${G}Done${RESET}"
    else
        echo -e "${R}Fail${RESET}"
        return $exit_code
    fi
}

# --- Checks ---
print_banner

# Root Check
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Sudo Refresh
step "Authenticating"
if sudo -v; then
    success "Sudo privileges active"
else
    error "Sudo failed"
    exit 1
fi

# Keep Sudo Alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Arch Check
if [[ ! -f /etc/arch-release ]]; then
    error "This script is designed for Arch Linux only."
    exit 1
fi

# Network Check
if ! ping -c 1 archlinux.org &> /dev/null; then
    error "No internet connection detected."
    exit 1
fi

# --- 1. System Update ---
step "Updating System"
if run_with_spinner "Syncing Repos & Updating" sudo pacman -Syu --noconfirm; then
    success "System Updated"
else
    error "Update Failed (Check $LOG)"
    exit 1
fi

# --- 2. Package Installation ---
step "Installing Packages"
sudo pacman -S --noconfirm archlinux-keyring &> /dev/null

FAILED_PKGS=()

for file in pkgs/*.txt; do
    echo -e "   ${B}::${RESET} Reading ${W}$(basename "$file")${RESET}"
    while read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        
        if run_with_spinner "Installing $pkg" sudo pacman -S --needed --noconfirm "$pkg"; then
            :
        else
            FAILED_PKGS+=("$pkg")
        fi
    done < "$file"
done

# --- 3. Services ---
step "Enabling Services"
run_with_spinner "NetworkManager" sudo systemctl enable --now NetworkManager
run_with_spinner "Bluetooth" sudo systemctl enable --now bluetooth
run_with_spinner "Avahi" sudo systemctl enable --now avahi-daemon
success "Services verified"

# --- 4. FetchX ---
step "Installing FetchX"
if run_with_spinner "Downloading & Installing" bash -c "curl -fsSL https://raw.githubusercontent.com/v9mirza/fetchx/main/install.sh | bash"; then
    success "FetchX Ready"
else
    warn "FetchX installation failed"
fi

# --- 5. Configuration ---
step "Deploying Configs"

if [[ ! -f config/hypr/hyprland.conf ]]; then
    error "Missing config/hypr/hyprland.conf"
    exit 1
fi

mkdir -p ~/.config

# Backup
for d in hypr waybar dunst kitty wofi cava btop; do
    if [[ -d ~/.config/$d ]]; then
        mv ~/.config/$d ~/.config/$d.bak
        echo -e "   ${DIM}→ Backed up $d${RESET}"
    fi
done

# Copy
if run_with_spinner "Syncing Dotfiles" rsync -av --delete config/ ~/.config/; then
    success "Dotfiles applied"
fi

cp config/mimeapps.list ~/.config/mimeapps.list
chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true

# --- 6. GTK & Shell ---
step "Finalizing Setup"

# Hyprland Entry
if ! command -v Hyprland &> /dev/null; then
    run_with_spinner "Installing Hyprland" sudo pacman -S --noconfirm hyprland
fi

sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Exec=Hyprland
Type=Application
EOF

# Starship
if ! grep -q "starship init bash" ~/.bashrc; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    success "Starship added to .bashrc"
fi

# GTK Theme
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 11
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-application-prefer-dark-theme=1
EOF

# Font Cache
run_with_spinner "Updating Font Cache" fc-cache -fv



# --- Summary ---
echo
echo -e "${G}${BOLD}Installation Complete!${RESET}"
if (( ${#FAILED_PKGS[@]} )); then
    echo
    warn "Some packages failed to install:"
    printf '  - %s\n' "${FAILED_PKGS[@]}"
fi
echo
echo -e "  To start your session:"
echo -e "  ${C}1.${RESET} Reboot your system"
echo -e "  ${C}2.${RESET} Select 'Hyprland' at login"
echo
