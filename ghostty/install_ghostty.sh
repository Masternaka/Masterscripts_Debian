#!/usr/bin/env bash
# DESC: Install Ghostty terminal emulator from ButterRepo
set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Make sure the tools this script needs are present
ensure_dependencies() {
    local missing=()
    for cmd in curl wget gpg unzip; do
        command_exists "$cmd" || missing+=("$cmd")
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Installing required dependencies: ${missing[*]}..."
        sudo apt update || { echo "ERROR: Failed to update package list."; exit 1; }
        sudo apt install -y curl wget gnupg ca-certificates unzip || { echo "ERROR: Failed to install dependencies."; exit 1; }
    fi
}

# Nerd Fonts referenced by the config (nerd-fonts release asset names)
FONT_VERSION="v3.4.0"
GHOSTTY_FONTS=("Lilex" "SourceCodePro")

# Install the Nerd Fonts the config uses (skips any already present)
setup_fonts() {
    local fonts_dir="$HOME/.local/share/fonts"
    local tmp_dir installed=0
    mkdir -p "$fonts_dir"

    echo "Installing Nerd Fonts used by the Ghostty config..."
    tmp_dir="$(mktemp -d)"

    for font in "${GHOSTTY_FONTS[@]}"; do
        if [ -d "$fonts_dir/$font" ] && [ -n "$(ls -A "$fonts_dir/$font" 2>/dev/null)" ]; then
            echo "  $font already installed. Skipping."
            continue
        fi

        echo "  Downloading $font..."
        if wget -q --timeout=30 -O "$tmp_dir/$font.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${font}.zip"; then
            mkdir -p "$fonts_dir/$font"
            if unzip -q "$tmp_dir/$font.zip" -d "$fonts_dir/$font/" 2>/dev/null; then
                echo "  Installed $font."
                installed=$((installed + 1))
            else
                echo "  Warning: failed to extract $font (skipping)."
                rm -rf "${fonts_dir:?}/$font"
            fi
        else
            echo "  Warning: failed to download $font (skipping)."
        fi
    done

    rm -rf "$tmp_dir"

    if [ "$installed" -gt 0 ] && command_exists fc-cache; then
        echo "Updating font cache..."
        fc-cache -f >/dev/null 2>&1
    fi
}

ensure_dependencies

if ! [ -f /etc/apt/sources.list.d/butterrepo.list ] || ! [ -f /usr/share/keyrings/butterrepo.gpg ]; then
    echo "ButterRepo not found. Adding it now..."
    wget -qO- "https://justaguy.dev/drew/butterscripts/raw/branch/main/setup/add_butterrepo.sh" | bash
fi

if command_exists ghostty; then
    echo "Ghostty is already installed. Skipping installation."
else
    echo "Installing Ghostty..."
    sudo apt install -y ghostty || { echo "ERROR: Failed to install Ghostty."; exit 1; }
    echo "Ghostty installed successfully."
fi

setup_fonts

echo "Setting up Ghostty configuration..."
CONFIG_DIR="$HOME/.config/ghostty"
mkdir -p "$CONFIG_DIR"

BASE_URL="https://justaguy.dev/drew/butterscripts/raw/branch/main/ghostty"
wget -O "$CONFIG_DIR/config" "$BASE_URL/config" || { echo "ERROR: Failed to download Ghostty config."; exit 1; }
sed -i "s|gtk-custom-css = .*|gtk-custom-css = $CONFIG_DIR/style.css|" "$CONFIG_DIR/config"
wget -O "$CONFIG_DIR/style.css" "$BASE_URL/style.css" || echo "Warning: Failed to download style.css (optional)."

if command -v update-alternatives &>/dev/null; then
    echo "Setting ghostty as default terminal emulator..."
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50
    sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
fi

echo ""
echo "Ghostty configuration complete."
echo "  Config: $CONFIG_DIR/config"
echo "  Style:  $CONFIG_DIR/style.css"
echo ""
