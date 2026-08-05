# 🧈 Butter WezTerm

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![Debian](https://img.shields.io/badge/debian-based-red.svg)](https://www.debian.org/)
[![WezTerm](https://img.shields.io/badge/WezTerm-nightly-orange.svg)](https://wezfurlong.org/wezterm/)
[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

A simple WezTerm terminal emulator installer for Linux systems.

> **Note:** This script installs WezTerm terminal emulator on Debian-based systems.

## Features
- Installs WezTerm nightly build with a single command
- Custom configuration automatically applied
- Clean installation process

## 📋 Requirements

- **OS:** Debian-based Linux distribution
- **Tools:** Installs its own dependencies (`curl`, `wget`, `gnupg`, `unzip`) if missing
- **Permissions:** `sudo` privileges for installation

## 🚀 Quick Start
To install WezTerm:
```bash
# Clone repository
git clone https://justaguy.dev/drew/butterscripts.git
# Navigate to wezterm directory
cd butterscripts/wezterm
# Make executable
chmod +x install_wezterm.sh
# Run the installer
./install_wezterm.sh
```

## ⚙️ How It Works

The installation script performs the following steps:

1. **Dependencies** - Installs `curl`, `wget`, `gnupg`, and `unzip` if any are missing
2. **Repository Setup** - Adds the WezTerm repository and GPG key
3. **Installation** - Installs the latest WezTerm nightly build
4. **Fonts** - Installs the Nerd Fonts the configs use (Lilex + SauceCodePro), skipping any already present
5. **Configuration** - Sets up configuration in `~/.config/wezterm`
6. **Custom Config** - Applies the optimized configuration from this repository (see [Alternative Configs](#alternative-configurations) for other options)
7. **Default Terminal** - Sets WezTerm as the default terminal emulator (Debian 13+)
   - Configures the system to use WezTerm when file managers like Thunar launch a terminal
   - Replaces the default lxterminal

**Note:** For Thunar custom actions to work properly, you may need to manually configure:
- Edit → Configure custom actions in Thunar
- Add action: `wezterm start --cwd %f`
- This ensures "Open Terminal Here" opens WezTerm in the correct directory

## ✨ Configuration Features

The included configuration provides a powerful, customizable terminal experience:

### 🎨 Color Scheme
- GitHub Dark theme with carefully selected colors
- 98% background opacity for subtle transparency
- Custom tab bar styling with blue active tabs

### ⌨️ Keybindings (ALT + key)

**Pane Management:**
- `ALT + Enter` - Split pane horizontally (50/50)
- `ALT + SHIFT + Enter` - Split pane vertically (50/50)
- `ALT + w` - Close current pane (with confirmation)
- `ALT + Arrow Keys` - Navigate between panes

**Tab Management:**
- `ALT + t` - New tab
- `ALT + q` - Close tab (with confirmation)
- `ALT + 1-8` - Switch to tab 1-8
- `CTRL+ALT + 1-8` - Move tab to position 1-8
- `CTRL+ALT + Left/Right` - Move tab left/right relative
- `CTRL+ALT + Up/Down` - Switch to last active tab

**Other:**
- `ALT + c` - Copy selection
- `ALT + v` - Paste from clipboard
- `ALT + =` - Increase font size
- `ALT + -` - Decrease font size
- `ALT + 0` - Reset font size

### 🔤 Font Settings
- Primary: Lilex Nerd Font Mono Regular (size 17)
- Fallback: SauceCodePro Nerd Font Mono (WezTerm adds its built-in symbol/emoji fallback automatically)
- Window frame: Lilex Nerd Font Mono Italic (size 12)
- Line height: 1.1
- Optimized rendering with FreeType (Light/HorizontalLcd)

### ⚡ Performance
- 120 FPS max refresh rate
- OpenGL frontend with EGL preference
- Hardware acceleration enabled
- Optimized for responsiveness

### 🖱️ Mouse Bindings
- Right-click to copy selection
- Middle-click to split pane horizontally
- Shift + Middle-click to close pane

### 🔄 iTerm2 Compatibility
WezTerm has built-in support for iTerm2's shell integration protocols:
- **iTerm2 Image Protocol** - Display inline images in the terminal
- **OSC 7** - Automatic working directory tracking
- **OSC 133** - Semantic prompt zones (Input/Output/Prompt)
- **OSC 1337** - User variables for tracking shell state

This means shell integration scripts and tools designed for iTerm2 will often work automatically in WezTerm, making it easier to migrate from iTerm2 or use iTerm2-compatible tools.

## Alternative Configurations

The default installation uses a custom GitHub Dark theme with hand-crafted color palette. If you prefer a simpler setup using iTerm2 color schemes:

**Minimal iTerm2 Config:**
```bash
wget -O ~/.config/wezterm/wezterm.lua \
  https://justaguy.dev/drew/butterscripts/raw/branch/main/wezterm/wezterm-minimal-iterm.lua
```

This minimal config:
- Uses WezTerm's built-in iTerm2 color schemes (100+ included)
- Same keybindings as the default config
- Simpler, easier to customize
- Change theme by setting `config.color_scheme = "Dracula"` (or any other scheme name)

**Popular iTerm2 schemes included (exact names):**
- Dracula
- Kanagawa (Gogh)
- Gruvbox Dark (Gogh) or GruvboxDark
- nord
- Tokyo Night
- Catppuccin Mocha
- One Dark (Gogh)

See the full list: [WezTerm Color Schemes](https://wezfurlong.org/wezterm/colorschemes/index.html)

## Project Info
Made for Linux users who want a powerful terminal emulator with simple installation.

---
## 🧈 Built For
- **Butterbian Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast
> Butterbian Linux is a joke... for now.

---

## ☕ Support

If this setup has been helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## 📺 Watch on YouTube

Want to see how it looks and works?
🎥 Check out [JustAGuy Linux on YouTube](https://www.youtube.com/@JustAGuyLinux)

---
More scripts coming soon. Use what you need, fork what you like, tweak everything.
