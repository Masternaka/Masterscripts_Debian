# 🎨 Butter Theming
A simple theming installer for Linux systems.
> **Note:** These scripts install GTK themes, icon packs, and Nerd Fonts on Debian-based systems.

## Features
- Installs Orchis GTK theme and Colloid icon theme with a single command
- Installs popular Nerd Fonts for enhanced terminal and editor experience
- Custom configuration automatically applied
- Clean installation process with status indicators

## Requirements
- Debian-based Linux distribution
- git for cloning repositories
- sudo privileges for installing dependencies
- wget/unzip for font installation

## Installation
To install the themes and fonts:
```bash
# Clone repository
git clone https://justaguy.dev/drew/butterscripts.git
# Navigate to theming directory
cd butterscripts/theming
# Make scripts executable
chmod +x install_theme.sh install_minimal_theme.sh install_nerdfonts.sh
# Run the full theme installer (qtile theme switcher variants)
./install_theme.sh
# OR run the minimal theme installer (single GTK theme + icons, for WMs without a theme switcher)
./install_minimal_theme.sh
# Run the font installer
./install_nerdfonts.sh
```

## How It Works
The scripts:

### install_theme.sh
1. Installs multiple Orchis GTK theme variants (Grey, Green, Purple, Orange, Pink, Nord, Dracula) from https://github.com/vinceliuice/Orchis-theme — intended for use with the qtile theme switcher
2. Installs Colloid icon theme variants (Grey Dracula, Dracula, Orange) from https://github.com/vinceliuice/Colloid-icon-theme
3. Configures GTK2 and GTK3 settings to use the installed themes

### install_minimal_theme.sh
1. Installs a single Orchis Grey Dark GTK theme + Colloid Grey Dracula Dark icons
2. Preserves your currently-active theme if both are already installed
3. Intended for WM setups that don't need multiple theme variants

### install_nerdfonts.sh
1. Checks for and installs necessary dependencies (unzip)
2. Downloads and installs popular Nerd Fonts from the official repository
3. Only installs fonts that aren't already on your system
4. Updates font cache to make new fonts immediately available

### ytsubs.sh
Utility script (unrelated to theming) that fetches a YouTube channel's subscriber count via the YouTube Data API v3. Requires `YOUTUBE_API_KEY` to be set.

## Included Nerd Fonts
- JetBrainsMono
- FiraCode
- Hack
- CascadiaCode
- SourceCodePro
- RobotoMono
- Meslo
- UbuntuMono
- Inconsolata
- VictorMono
- Mononoki
- Terminus

## Project Info
Made for Linux users who want a consistent and beautiful desktop theme with minimal effort.

---
## 🧈 Built For
- **Butterbian Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast
> Butterbian Linux is a joke... for now.

---
## 📫 Author
**JustAGuy Linux**  
🎥 [YouTube](https://youtube.com/@JustAGuyLinux)  

---
More scripts coming soon. Use what you need, fork what you like, tweak everything.
