#!/usr/bin/env bash
# DESC: Install kitty terminal emulator from the official Debian repository
# ============================================
# Install kitty - Terminal Emulator
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
    for cmd in curl wget unzip; do
        command_exists "$cmd" || missing+=("$cmd")
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Installing required dependencies: ${missing[*]}..."
        sudo apt update || die "Failed to update package list."
        sudo apt install -y curl wget ca-certificates unzip || die "Failed to install dependencies."
    fi
}

# Install kitty from the official Debian repository (no third-party repo needed)
install_kitty() {
    if command_exists kitty; then
        echo "kitty is already installed. Skipping installation."
        return
    fi

    echo "Installing kitty..."
    sudo apt update || die "Failed to update package list."
    sudo apt install -y kitty || die "Failed to install kitty."
}

# Nerd Fonts referenced by the bundled config (nerd-fonts release asset names)
FONT_VERSION="v3.4.0"
KITTY_FONTS=("Lilex" "SourceCodePro")

# Install the Nerd Fonts the config uses (skips any already present)
setup_fonts() {
    local fonts_dir="$HOME/.local/share/fonts"
    local tmp_dir installed=0
    mkdir -p "$fonts_dir"

    echo "Installing Nerd Fonts used by the kitty config..."
    tmp_dir="$(mktemp -d)"

    for font in "${KITTY_FONTS[@]}"; do
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
    echo "Setting up kitty configuration..."
    CONFIG_DIR="$HOME/.config/kitty"
    mkdir -p "$CONFIG_DIR"

    BASE_URL="https://justaguy.dev/drew/butterscripts/raw/branch/main/kitty"

    # Preserve any existing config before overwriting
    if [ -f "$CONFIG_DIR/kitty.conf" ]; then
        BACKUP="$CONFIG_DIR/kitty.conf.backup.$(date +%Y%m%d%H%M%S)"
        cp "$CONFIG_DIR/kitty.conf" "$BACKUP"
        echo "Existing kitty.conf backed up to $BACKUP"
    fi

    # Main config
    wget -O "$CONFIG_DIR/kitty.conf" "$BASE_URL/kitty.conf" || die "Failed to download kitty config."
    # Default theme seed (GitHub Dark) — included by kitty.conf
    wget -O "$CONFIG_DIR/current-theme.conf" "$BASE_URL/current-theme.conf" || die "Failed to download theme seed."

    # Custom themes not shipped by upstream kitty-themes but referenced by the
    # WM theme switchers (resolved by `kitty +kitten themes "<name>"`).
    mkdir -p "$CONFIG_DIR/themes"
    wget -O "$CONFIG_DIR/themes/trapped-in-amber.conf" "$BASE_URL/themes/trapped-in-amber.conf" \
        || echo "Warning: failed to download 'Trapped in Amber' theme (the WM amber theme won't render in kitty until present)."

    # Pre-warm the kitten's theme cache (~/.cache/kitty/kitty-themes.zip) so the
    # first WM theme switch resolves bundled themes instantly and works offline.
    if command_exists kitty; then
        echo "Pre-warming kitty theme cache..."
        kitty +kitten themes --cache-age=1000 --dump-theme "GitHub Dark" >/dev/null 2>&1 \
            || echo "Warning: could not pre-warm theme cache (it will download on first theme switch)."
    fi

    echo ""
    echo "kitty installation and configuration complete."
    echo "  Config: $CONFIG_DIR/kitty.conf"
    echo "  Theme:  $CONFIG_DIR/current-theme.conf (GitHub Dark)"
    echo "  Custom: $CONFIG_DIR/themes/ (Trapped in Amber)"
    echo ""
    echo "Change theme any time with:  kitty +kitten themes"
    echo ""
}

# Set kitty as default terminal emulator (fixes Debian 13 defaulting to lxterminal)
set_default_terminal() {
    if command_exists kitty && command_exists update-alternatives; then
        echo "Setting kitty as default terminal emulator..."
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 60
        sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty
    fi
}

# Run the installation
ensure_dependencies
install_kitty
setup_fonts
setup_config
set_default_terminal
