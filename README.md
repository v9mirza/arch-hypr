<div align="center">
    <h1>V9-Hyprdots</h1>
    <p>
        <a href="https://archlinux.org"><img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux" /></a>
        <a href="https://hyprland.org"><img src="https://img.shields.io/badge/Hyprland-2E3440?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland" /></a>
        <a href="https://github.com/v9mirza/v9-hyprdots"><img src="https://img.shields.io/badge/Version-2.0-6f7a80?style=for-the-badge" alt="Version" /></a>
    </p>
    <h3><i>"Blur the shell, not the work."</i></h3>
    <br />
</div>

A highly optimized, modular configuration system for Hyprland on Arch Linux.
Designed for focus, performance, and aesthetic perfection.

---

## Features

- **Unified Installer**: One script to handle dependencies, config deployment, and theme selection.
- **Theme Switcher**: Hot-swap between themes instantly with `switch-theme`.
- **Performance First**: Zero-bloat configs optimized for speed and fluidity.
- **Consolidated Wallpapers**: Centralized management for all your backgrounds.
- **Modular**: Components (Waybar, Dunst, Wofi) are styled to match each theme perfectly.

---

## Installation

Get up and running in seconds. The installer handles the rest.

```bash
git clone https://github.com/v9mirza/v9-hyprdots.git
cd v9-hyprdots
chmod +x install.sh
./install.sh
```

---

## Themes

### 1. Minimal

> _The focused workspace._

- **Palette**: Monochrome Dark (`#0f0f0f`)
- **Aesthetic**: Clean, sharp, distraction-free.
- **Best For**: Deep work, coding, writing.

### 2. Hypr-Knight

> _The cinematic experience._

- **Palette**: Deep Charcoal & Gotham Grey
- **Aesthetic**: Moody, intense, inspired by the Dark Knight.
- **Best For**: Creative sessions, night owls.

---

## Utilities

### Theme Switcher

Switch themes on the fly without breaking your workflow.

```bash
switch-theme              # Interactive menu
switch-theme minimal      # Direct switch
switch-theme hypr-knight  # Direct switch
```

### Wallpaper Manager

Wallpapers are managed automatically.

- Location: `~/.config/hypr/wallpapers/`
- Configuration: `~/.config/hypr/hyprpaper.conf`

---

## Keybindings

### 🚀 Applications

| Key                | Action                  |
| :----------------- | :---------------------- |
| `Super` + `Return` | Open Terminal (Ghostty) |
| `Super` + `Space`  | App Launcher (Wofi)     |
| `Super` + `E`      | File Manager (Yazi)     |
| `Super` + `B`      | Browser (Firefox)       |
| `Super` + `M`      | System Monitor (Btop)   |

### 🪟 Windows & Workspaces

| Key                          | Action                   |
| :--------------------------- | :----------------------- |
| `Super` + `Q`                | Close Active Window      |
| `Super` + `F`                | Toggle Floating Window   |
| `Super` + `1`..`9`           | Switch Workspace         |
| `Super` + `Shift` + `1`..`9` | Move Window to Workspace |

### 🛠 System & Tools

| Key                   | Action                        |
| :-------------------- | :---------------------------- |
| `Super` + `W`         | **Wallpaper Selector** (New!) |
| `Super` + `X`         | Power Menu (Shutdown/Reboot)  |
| `Super` + `L`         | Lock Screen                   |
| `Super` + `V`         | Clipboard Manager             |
| `Super` + `Alt` + `T` | Theme Switcher                |
| `Print`               | Screenshot (Full Screen)      |
| `Shift` + `Print`     | Screenshot (Region)           |

### 🔊 Media & Controls

| Key            | Action            |
| :------------- | :---------------- |
| `Vol Up/Down`  | Adjust Volume     |
| `Mute`         | Mute Audio/Mic    |
| `Brit Up/Down` | Adjust Brightness |

---

## Credits

- **WM**: [Hyprland](https://hyprland.org)
- **Bar**: [Waybar](https://github.com/Alexays/Waybar)
- **Terminal**: [Ghostty](https://github.com/ghostty-org/ghostty)
- **Launcher**: [Wofi](https://hg.sr.ht/~scoopta/wofi)
- **Notifications**: [Dunst](https://dunst-project.org/)

---

<div align="center">
    Made with ❤️ by <b>v9mirza</b>
</div>
