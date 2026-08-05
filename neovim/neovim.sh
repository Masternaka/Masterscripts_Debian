#!/usr/bin/env bash
# DESC: Install Neovim (latest, via ButterRepo) plus a JustAGuyLinux config
# neovim.sh [nvim|butter-nvim]
#   nvim        - standard config, vim motions            (justaguy.dev/drew/nvim)
#   butter-nvim - GUI keybinds (Ctrl+S), no vim motions   (justaguy.dev/drew/butter-nvim)
# Pass the config as an argument, or omit it to be prompted.
# -----------------------------------------------------------

set -e  # Exit immediately if a command exits with a non-zero status

CONFIG="${1:-}"

# Pick a config if one wasn't passed as an argument
if [ -z "$CONFIG" ]; then
    echo "Which Neovim configuration?"
    echo "  1) nvim        - standard config, vim motions"
    echo "  2) butter-nvim - GUI keybinds (Ctrl+S/Z/C/V), no vim motions"
    echo "  3) none        - just install Neovim (no config)"
    read -rp "Choice [1-3]: " choice
    case "$choice" in
        1) CONFIG="nvim" ;;
        2) CONFIG="butter-nvim" ;;
        3) CONFIG="none" ;;
        *) echo "Invalid choice."; exit 1 ;;
    esac
fi

case "$CONFIG" in
    nvim|butter-nvim|none) ;;
    *) echo "Unknown config: '$CONFIG' (use: nvim | butter-nvim | none)"; exit 1 ;;
esac

echo "==============================================="
echo "  ButterScripts: Neovim Setup ($CONFIG)"
echo "==============================================="

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt update
sudo apt install -y git ripgrep fd-find curl gpg

# Add ButterRepo if not already added (ships current-stable neovim)
if [ ! -f /etc/apt/sources.list.d/butterrepo.list ]; then
    echo "🔧 Adding ButterRepo..."
    curl -fsSL https://apt.justaguy.dev/key.asc | sudo gpg --dearmor -o /usr/share/keyrings/butterrepo.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/butterrepo.gpg] https://apt.justaguy.dev stable main" | sudo tee /etc/apt/sources.list.d/butterrepo.list
    sudo apt update
fi

echo "📦 Installing Neovim..."
sudo apt install -y neovim

# Vanilla: stop here, leave any existing config untouched
if [ "$CONFIG" = "none" ]; then
    echo
    echo "✨ Neovim installed (no config). ✨"
    echo "Launch with: nvim"
    echo "==============================================="
    exit 0
fi

# Back up any existing configuration, then clone the chosen one into place.
# Cloning directly into ~/.config/nvim keeps .git, so `git pull` updates it.
NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [ -e "$NVIM_CONFIG_DIR" ]; then
    BACKUP_DIR="$HOME/.config/nvim_backup_$(date +%Y%m%d%H%M%S)"
    echo "💾 Backing up existing configuration to $BACKUP_DIR"
    mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi
mkdir -p "$HOME/.config"
echo "🔄 Cloning $CONFIG configuration..."
git clone "https://justaguy.dev/drew/$CONFIG" "$NVIM_CONFIG_DIR"

echo
echo "✨ Installation complete! ✨"
echo "Launch with: nvim   (plugins install automatically on first run)"
echo "==============================================="
