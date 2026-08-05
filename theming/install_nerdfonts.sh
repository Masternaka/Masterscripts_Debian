#!/usr/bin/env bash
# DESC: Download and install popular Nerd Fonts for terminal and code editor use

# Nerd Fonts Installer
# A script to download and install popular Nerd Fonts

# Set color variables for better readability
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
check_dependencies() {
    # Map of required command -> apt package providing it
    # (fontconfig provides fc-cache, used to refresh the font cache below)
    local -A deps=([wget]=wget [unzip]=unzip [fc-cache]=fontconfig)

    for cmd in "${!deps[@]}"; do
        if ! command_exists "$cmd"; then
            local pkg="${deps[$cmd]}"
            echo -e "${YELLOW}Installing required dependency: $pkg${NC}"
            sudo apt install -y "$pkg" || {
                echo -e "${RED}Failed to install $pkg. Please install it manually.${NC}"
                exit 1
            }
        fi
    done
    echo -e "${GREEN}All dependencies are satisfied.${NC}"
}

# Array of font names
# Trimmed to the fonts actually referenced by configs across the JustAGuy Linux repos.
fonts=(
    "JetBrainsMono"          # default font, used ~everywhere
    "RobotoMono"             # polybar/waybar/awesome/qtile bar font
    "SourceCodePro"          # "SauceCodePro" — st/ghostty/wezterm terminal font
    "Lilex"                  # sway/swayfx/ghostty/wezterm
    "FiraCode"               # st fallback font
    "NerdFontsSymbolsOnly"   # "Symbols Nerd Font Mono" — st glyph fallback
)

# Font version and directories
FONT_VERSION="v3.4.0"
FONTS_DIR="$HOME/.local/share/fonts"
TEMP_DIR="/tmp/nerdfonts_install_$$" # Using PID to avoid conflicts

# Create necessary directories
mkdir -p "$FONTS_DIR"
mkdir -p "$TEMP_DIR"

# Main installation function
install_nerd_fonts() {
    local installed=0
    local skipped=0
    local failed=0
    
    echo -e "\n${BLUE}===== Nerd Fonts Installer =====${NC}"
    echo -e "${BLUE}Installing fonts to:${NC} $FONTS_DIR"
    
    # Start timer
    local start_time=$(date +%s)
    
    # First check dependencies
    check_dependencies
    
    # Process each font in the array
    for font in "${fonts[@]}"; do
        echo -e "\n${BLUE}Processing:${NC} $font"
        
        # Check if font is already installed
        if [ -d "$FONTS_DIR/$font" ] && [ "$(ls -A "$FONTS_DIR/$font" 2>/dev/null)" ]; then
            echo -e "  ${YELLOW}➤ $font is already installed. Skipping.${NC}"
            ((skipped++))
        else
            echo -e "  ${BLUE}⚙ Downloading $font...${NC}"
            
            # Download the font zip file with a timeout
            if wget --timeout=30 -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${font}.zip" -P "$TEMP_DIR"; then
                echo -e "  ${BLUE}⚙ Extracting $font...${NC}"
                
                # Create font directory
                mkdir -p "$FONTS_DIR/$font"
                
                # Extract the font with error handling
                if unzip -q "$TEMP_DIR/${font}.zip" -d "$FONTS_DIR/$font/" 2>/dev/null; then
                    echo -e "  ${GREEN}✓ Successfully installed $font${NC}"
                    ((installed++))
                else
                    echo -e "  ${RED}✗ Failed to extract $font${NC}"
                    rm -rf "$FONTS_DIR/$font" # Clean up the incomplete font directory
                    ((failed++))
                fi
                
                # Clean up the zip file
                rm -f "$TEMP_DIR/${font}.zip"
            else
                echo -e "  ${RED}✗ Failed to download $font${NC}"
                ((failed++))
            fi
        fi
    done
    
    # Update font cache
    echo -e "\n${BLUE}Updating font cache...${NC}"
    fc-cache -f
    
    # End timer and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Print summary
    echo -e "\n${BLUE}====== Installation Summary ======${NC}"
    echo -e "  ${GREEN}✓ Successfully installed:${NC} $installed fonts"
    echo -e "  ${YELLOW}➤ Already installed (skipped):${NC} $skipped fonts"
    echo -e "  ${RED}✗ Failed to install:${NC} $failed fonts"
    echo -e "  ${BLUE}⏱ Total time:${NC} $duration seconds"
    echo -e "${BLUE}==============================${NC}"
    echo -e "Fonts installed in: $FONTS_DIR"
}

# Handle script interruption
cleanup() {
    echo -e "\n${YELLOW}Script interrupted. Cleaning up...${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
}

# Set the trap for SIGINT (Ctrl+C)
trap cleanup SIGINT

# Run the installation
install_nerd_fonts

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}Installation process completed.${NC}"
