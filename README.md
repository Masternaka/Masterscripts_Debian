# 🧈 butterscripts
![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Stars](https://img.shields.io/gitea/stars/drew/butterscripts?gitea_url=https://justaguy.dev&style=for-the-badge&logo=forgejo&logoColor=white&color=yellow&label=Stars)
![Forks](https://img.shields.io/gitea/forks/drew/butterscripts?gitea_url=https://justaguy.dev&style=for-the-badge&logo=forgejo&logoColor=white&color=blue&label=Forks)
![Last Commit](https://img.shields.io/gitea/last-commit/drew/butterscripts?gitea_url=https://justaguy.dev&style=for-the-badge&logo=forgejo&logoColor=white&color=green&label=Last%20Commit)

A modular collection of scripts I use across my Debian setups — minimal and practical. These scripts automate installs, configure tools, apply theming, and tweak the system just how I like it.

---

## Overview

Butterscripts is a collection of utility scripts that help streamline various tasks in Linux. These scripts are organized into different directories based on their functionality and purpose, making it easy to find the script you need.

## Repository Structure

The repository is organized into the following directories:


### `/browsers`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/browsers)
- **brave**: Brave browser
- **firefox**: Firefox latest
- **floorp**: Floorp
- **zen**: Zen browser
- **more**

---

### `/discord` 

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/discord)
- **Install**: Discord latest binary and built-in updater.

---

### `/fastfetch`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/fastfetch)
- **fastfetch**: fastfetch latest
- **Auto alias**: for Bash, Zsh, and Fish
- **5 configurations**: default, debian-red, fancy, minimal, neon, justaguy and server

---

### `/ghostty`

- **install_ghostty.sh**: Installs Ghostty terminal emulator from ButterRepo (default terminal for all WM setups)
- **config**: Curated configuration file for Ghostty (GitHub Dark theme, splits, tabs, keybinds)
- **style.css**: Custom GTK CSS for Ghostty tab bar styling

---

### `/git`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/git)
- **ghee**: The git workflow in one program — repo hub, stage/unstage cockpit, commit/file pickers, ssh picker, commit-and-push flow, multi-repo dashboard and sweep
- **today.sh**: Today's commit counts across repos

---

### `/kitty`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/kitty)
- **install_kitty.sh**: Installs kitty terminal emulator from the official Debian repository (no third-party repo needed)
- **kitty.conf**: Curated configuration (GitHub Dark theme, splits, tabs, ALT keybinds)
- **current-theme.conf**: Default theme seed; swap with `kitty +kitten themes`
- **themes/**: Custom themes (Trapped in Amber) used by the WM theme switchers

---

### `/media`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/media)
- **clipmkv**: Losslessly clip an mkv by start/end timestamps
- **mergemkvs**: Losslessly concatenate every mkv in `~/Videos`
- **stripgeo**: Removes GPS/location metadata from images (exiftool)

---

### `/neovim`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/neovim)
- **neovim.sh**: Installs Neovim + a JustAGuyLinux config (`nvim` vim-motions, or `butter-nvim` GUI keybinds)
- **build-neovim.sh**: Builds and installs Neovim from source code

---

### `/setup`

- **add_butterrepo.sh**: Adds the ButterRepo APT repository
- **install_caligula.sh**: Installs Caligula disk imaging TUI
- **install_geany.sh**: Installs Geany text editor (APT or ButterRepo options)
- **install_mise.sh**: Installs mise (dev-tool version manager) + wires shell activation
- **install_picom.sh**: Installs Picom compositor
- **optional_tools.sh**: Interactive installer for development tools including [ButterBash](https://justaguy.dev/drew/butterbash) ⭐
- **wm-chooser.sh**: Multi-select window manager installer (awesome, bspwm, dwm, i3, openbox, qtile, sway, swayfx)

---

### `/st`

- **install_st.sh**: Installs st (simple terminal)

---

### `/system`

- **install_bluetooth.sh**: Installs and configures Bluetooth support
- **install_lightdm.sh**: Installs LightDM display manager
- **install_printer_support.sh**: Sets up printer support

---

### `/theming`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/theming)
- **nerdfonts**: Installs curated list of popular Nerd Fonts.
- **install-theme**: Installs my favorite GTK theme and Dracula Dark icon theme

---

### `/wezterm`

- [Installation and Documentation](https://justaguy.dev/drew/butterscripts/src/branch/main/wezterm)
- **install_wezterm.sh**: Installs WezTerm terminal emulator from official nightly repository (available via optional_tools)
- **wezterm.lua**: Curated lua configuration file for WezTerm

---

### `/zed`

- **settings.json**: Curated configuration file for Zed text editor

---

Thanks to all contributors and the open source community for inspiration and code references.
## 🧈 Built For

- **Butterbian Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast

> Butterbian Linux was a joke. The joke got an ISO. The ISO got a website. Send help.

---

## License

GPL-2.0 - See [LICENSE](LICENSE) for details.

## Support

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## Connect

- [YouTube](https://youtube.com/@justaguylinux) — tutorials and guides
- [Butterforge](https://justaguy.dev/drew) — source code and projects
- [The Butter Lab](https://lab.justaguylinux.com) — Discourse forum
- [The Churn](https://justaguylinux.chat) — community chat (Fluxer)
- [Wiki](https://justaguy.wiki) — documentation and guides
- [Mastodon](https://fosstodon.org/@justaguylinux) — @justaguylinux@fosstodon.org
- [Butterbian](https://butterbian.org) — a Debian-based distro

---

Made with butter by JustAGuyLinux
