#!/usr/bin/env bash
# DESC: Install WezTerm terminal emulator from official repository
# ============================================
# Install WezTerm - Terminal Emulator
# ============================================
set -e

# Helper functions
die() {
    echo "ERROR: $1"
    exit 1
}

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
        sudo apt update || die "Failed to update package list."
        sudo apt install -y curl wget gnupg ca-certificates unzip || die "Failed to install dependencies."
    fi
}

# Install WezTerm from the official apt repository
install_wezterm() {
    if command_exists wezterm; then
        echo "WezTerm is already installed. Skipping installation."
        return
    fi

    echo "Installing WezTerm nightly..."

    # Add WezTerm repository
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg || die "Failed to add WezTerm GPG key."
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list || die "Failed to add WezTerm repository."
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

    # Update package list and install
    sudo apt update || die "Failed to update package list."
    sudo apt install -y wezterm-nightly || die "Failed to install WezTerm nightly."
}

# Nerd Fonts referenced by the bundled configs (nerd-fonts release asset names)
FONT_VERSION="v3.4.0"
WEZTERM_FONTS=("Lilex" "SourceCodePro")

# Install the Nerd Fonts the configs use (skips any already present)
setup_fonts() {
    local fonts_dir="$HOME/.local/share/fonts"
    local tmp_dir installed=0
    mkdir -p "$fonts_dir"

    echo "Installing Nerd Fonts used by the WezTerm configs..."
    tmp_dir="$(mktemp -d)"

    for font in "${WEZTERM_FONTS[@]}"; do
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

# Download and install the configuration files
setup_config() {
    echo "Setting up WezTerm configuration..."
    CONFIG_DIR="$HOME/.config/wezterm"
    mkdir -p "$CONFIG_DIR"

    # Download main configuration
    CONFIG_URL="https://justaguy.dev/drew/butterscripts/raw/branch/main/wezterm/wezterm.lua"
    wget -O "$CONFIG_DIR/wezterm.lua" "$CONFIG_URL" || die "Failed to download WezTerm config."

    # Download minimal configuration as alternative
    MINIMAL_URL="https://justaguy.dev/drew/butterscripts/raw/branch/main/wezterm/wezterm-minimal-iterm.lua"
    wget -O "$CONFIG_DIR/wezterm-minimal-iterm.lua" "$MINIMAL_URL" || echo "Warning: Failed to download minimal config (optional)."

    echo ""
    echo "WezTerm installation and configuration complete."
    echo ""
    echo "Two configurations have been installed:"
    echo "  - Full config (active): $CONFIG_DIR/wezterm.lua"
    echo "  - Minimal config: $CONFIG_DIR/wezterm-minimal-iterm.lua"
    echo ""
    echo "To switch to minimal config, run:"
    echo "  mv ~/.config/wezterm/wezterm.lua ~/.config/wezterm/wezterm-full.lua"
    echo "  mv ~/.config/wezterm/wezterm-minimal-iterm.lua ~/.config/wezterm/wezterm.lua"
    echo ""
}

# Set wezterm as default terminal emulator (fixes Debian 13 defaulting to lxterminal)
set_default_terminal() {
    if command_exists wezterm && command_exists update-alternatives; then
        echo "Setting wezterm as default terminal emulator..."
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/wezterm 60
        sudo update-alternatives --set x-terminal-emulator /usr/bin/wezterm
    fi
}

# Run the installation
ensure_dependencies
install_wezterm
setup_fonts
setup_config
set_default_terminal
