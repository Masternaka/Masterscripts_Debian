# 🧈 Butter kitty

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![Debian](https://img.shields.io/badge/debian-based-red.svg)](https://www.debian.org/)
[![kitty](https://img.shields.io/badge/kitty-GPU%20terminal-purple.svg)](https://sw.kovidgoyal.net/kitty/)
[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

A simple kitty terminal emulator installer for Linux systems.

> **Note:** kitty ships in the **official Debian repository**, so this is the
> simplest installer of the bunch — a plain `apt install`, no third-party repo
> or GPG key required.

## Features
- Installs kitty with a single command (straight from Debian's repo)
- Custom configuration automatically applied
- Native tabs + splits, plain-text config, GPU-accelerated

## 📋 Requirements
- **OS:** Debian-based Linux distribution
- **Tools:** Installs its own dependencies (`curl`, `wget`, `unzip`) if missing
- **Permissions:** `sudo` privileges for installation

## 🚀 Quick Start
```bash
# Clone repository
git clone https://justaguy.dev/drew/butterscripts.git
# Navigate to kitty directory
cd butterscripts/kitty
# Make executable
chmod +x install_kitty.sh
# Run the installer
./install_kitty.sh
```

## ⚙️ How It Works
1. **Dependencies** — installs `curl`, `wget`, `unzip` if any are missing
2. **Installation** — `sudo apt install kitty` (no extra repos)
3. **Fonts** — installs the Nerd Fonts the config uses (Lilex + SauceCodePro), skipping any already present
4. **Configuration** — sets up `~/.config/kitty/` (`kitty.conf`, `current-theme.conf`, and the custom `themes/`)
5. **Default Terminal** — sets kitty as the default terminal emulator (Debian 13+), replacing lxterminal

## ✨ Configuration

### 🎨 Color Scheme
- Ships with **GitHub Dark** as the default
- Colors live in `current-theme.conf` (included by `kitty.conf`)
- Swap themes any time with kitty's bundled collection:
  ```bash
  kitty +kitten themes
  ```
- A custom **Trapped in Amber** theme (converted from iTerm2-Color-Schemes) is bundled under `themes/` for use by the WM theme switchers

### ⌨️ Keybindings (ALT + key)

**Splits / panes:**
- `ALT + Enter` — split horizontally
- `ALT + SHIFT + Enter` — split vertically
- `ALT + SHIFT + Arrows` / `ALT + Up`,`Down` — move between splits
- `ALT + SHIFT + z` — toggle zoom (stack layout)
- `ALT + SHIFT + =` — swap split with active
- `ALT + w` — close window (with confirmation)

**Tabs:**
- `ALT + t` — new tab
- `ALT + Left/Right` — previous / next tab
- `ALT + 1-8` — go to tab 1-8
- `CTRL + SHIFT + ALT + Left/Right` — move tab

**Other:**
- `ALT + c` / `ALT + v` — copy / paste
- `ALT + =` / `ALT + -` / `ALT + 0` — font size up / down / reset

### 🖱️ Mouse Bindings
- Right-click — copy selection
- Middle-click — split horizontally
- Shift + Middle-click — close window

### 🔤 Font & Performance
- Font: SauceCodePro Nerd Font Mono (size 17), Lilex fallback
- Cell tweaks (line height 110%, width 102%), light hinting
- 98% background opacity, low input latency, GPU-accelerated

## 🔄 Theme Switching
kitty's `+kitten themes` reads the bundled **kitty-themes** collection (derived
from iTerm2-Color-Schemes). Custom schemes not in that set live in
`~/.config/kitty/themes/` and resolve by their `## name:` field — which is how
the WM theme switchers apply `kitty = <name>`.

---
## 🧈 Built For
- **Butterbian Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast

---

## ☕ Support
If this setup has been helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## 📺 Watch on YouTube
🎥 Check out [JustAGuy Linux on YouTube](https://www.youtube.com/@JustAGuyLinux)

---
More scripts coming soon. Use what you need, fork what you like, tweak everything.
