#!/usr/bin/env bash
# DESC: Install various web browsers (Chrome, Firefox, Brave, etc.)

# Browser Installation Scripts for Debian Stable
# This script provides installation methods for various browsers
# targeting the latest versions available for Debian Stable

# Set colors for output (matching lightdm script)
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Debian
if [ ! -f /etc/debian_version ]; then
    echo -e "${RED}This script is optimized for Debian. Your system may not be compatible.${NC}"
    read -p "Continue anyway? (y/n): " continue_anyway
    if [[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]]; then
        exit 1
    fi
fi

# Track if dependencies have been installed this session
DEPS_INSTALLED=false

# Make sure we have basic dependencies
ensure_dependencies() {
    if [ "$DEPS_INSTALLED" = true ]; then
        return
    fi
    echo -e "${GREEN}Installing essential dependencies...${NC}"
    sudo apt update
    sudo apt install -y wget curl apt-transport-https gnupg ca-certificates software-properties-common
    DEPS_INSTALLED=true
}

# Choose browsers to install
show_menu() {
    clear
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}         BROWSER INSTALLATION SCRIPTS (DEBIAN)          ${NC}"
    echo -e "${CYAN}=========================================================${NC}"

    if is_installed firefox-esr; then
        echo -e "${GREEN}  Firefox ESR is already installed (managed by your WM setup).${NC}"
        echo -e "${GREEN}  This script offers additional browsers.${NC}"
        echo ""
    fi

    echo -e "${YELLOW}Enter numbers of browsers to install (separated by spaces):${NC}"
    echo -e "${CYAN}1. ${NC}Helium Browser"
    echo -e "${CYAN}2. ${NC}Firefox Latest"
    echo -e "${CYAN}3. ${NC}LibreWolf"
    echo -e "${CYAN}4. ${NC}Brave"
    echo -e "${CYAN}5. ${NC}Floorp"
    echo -e "${CYAN}6. ${NC}Zen Browser"
    echo -e "${CYAN}7. ${NC}Chromium"
    echo -e "${CYAN}8. ${NC}All Browsers"
    echo -e "${CYAN}9. ${NC}Exit"
    echo -e "${CYAN}=========================================================${NC}"

    # Simple read command with normal terminal behavior
    read -p "Enter your choice(s): " input

    # Check if input is empty
    if [ -z "$input" ]; then
        echo -e "${YELLOW}No selection made. Exiting.${NC}"
        exit 0
    fi

    # Check if user wants to exit with option 9
    if [[ "$input" == "9" ]]; then
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
    fi

    # Install all browsers if option 8 is selected
    if [[ "$input" == "8" ]]; then
        install_helium
        install_firefox
        install_librewolf
        install_brave
        install_floorp
        install_zen
        install_chromium
        echo -e "${GREEN}All browsers have been installed!${NC}"
        exit 0
    fi

    # Process each selection
    for choice in $input; do
        case $choice in
            1) install_helium ;;
            2) install_firefox ;;
            3) install_librewolf ;;
            4) install_brave ;;
            5) install_floorp ;;
            6) install_zen ;;
            7) install_chromium ;;
            *) echo -e "${RED}Invalid choice: $choice (skipping)${NC}" ;;
        esac
    done

    echo -e "${GREEN}Selected browsers have been installed!${NC}"
    exit 0
}

# Function to check if a package is installed
is_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# Function to install Firefox
install_firefox() {
    # Check if Firefox is already installed
    if is_installed firefox-esr || is_installed firefox; then
        if is_installed firefox-esr && ! is_installed firefox; then
            echo -e "${YELLOW}Firefox ESR is currently installed.${NC}"
            echo -e "${CYAN}Choose an option:${NC}"
            echo -e "${CYAN}1. ${NC}Install latest Firefox alongside ESR (both will be available)"
            echo -e "${CYAN}2. ${NC}Remove ESR and install latest Firefox"
            echo -e "${CYAN}3. ${NC}Skip installation (keep ESR only)"
            read -p "Enter your choice (1-3): " firefox_choice
            
            case $firefox_choice in
                1)
                    echo -e "${GREEN}Installing Firefox latest alongside ESR...${NC}"
                    ;;
                2)
                    echo -e "${GREEN}Removing Firefox ESR and installing latest...${NC}"
                    sudo apt remove -y firefox-esr
                    ;;
                3)
                    echo -e "${GREEN}Keeping Firefox ESR. Skipping installation.${NC}"
                    return
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Skipping installation.${NC}"
                    return
                    ;;
            esac
        else
            echo -e "${GREEN}Firefox is already installed. Skipping installation.${NC}"
            return
        fi
    fi
    
    echo -e "${GREEN}Installing Firefox Latest...${NC}"

    # Install dependencies
    ensure_dependencies

    # Remove any old Mozilla repository files if they exist
    sudo rm -f /etc/apt/sources.list.d/mozilla.list
    sudo rm -f /etc/apt/keyrings/packages.mozilla.org.asc
    
    # Create keyrings directory if it doesn't exist
    sudo install -d -m 0755 /etc/apt/keyrings
    
    # Import the Mozilla APT repository signing key
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    
    # Add the Mozilla APT repository
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    
    # Configure APT to prioritize packages from the Mozilla repository
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
    
    # Update and install Firefox
    sudo apt update
    if ! sudo apt install -y firefox; then
        echo -e "${RED}Failed to install Firefox.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Firefox installation completed.${NC}"
    echo -e "${YELLOW}You can run Firefox by typing 'firefox' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install LibreWolf
install_librewolf() {
    # Check if LibreWolf is already installed
    if is_installed librewolf; then
        echo -e "${GREEN}LibreWolf is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing LibreWolf...${NC}"

    # Install dependencies
    ensure_dependencies

    # First, remove any old LibreWolf repository files if they exist
    sudo rm -f \
        /etc/apt/sources.list.d/librewolf.sources \
        /etc/apt/keyrings/librewolf.gpg \
        /etc/apt/preferences.d/librewolf.pref \
        /etc/apt/sources.list.d/librewolf.list \
        /etc/apt/trusted.gpg.d/librewolf.gpg
    
    # Install extrepo tool
    sudo apt update
    sudo apt install -y extrepo
    
    # Enable LibreWolf repository via extrepo
    sudo extrepo enable librewolf
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y librewolf; then
        echo -e "${RED}Failed to install LibreWolf.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}LibreWolf installation complete!${NC}"
    echo -e "${YELLOW}You can run LibreWolf by typing 'librewolf' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Brave
install_brave() {
    # Check if Brave is already installed
    if is_installed brave-browser; then
        echo -e "${GREEN}Brave Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Brave Browser...${NC}"

    # Install dependencies
    ensure_dependencies

    # Add Brave GPG key
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    
    # Add Brave repository
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y brave-browser; then
        echo -e "${RED}Failed to install Brave Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Brave Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Brave by typing 'brave-browser' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Floorp
install_floorp() {
    # Check if Floorp is already installed
    if is_installed floorp; then
        echo -e "${GREEN}Floorp Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Floorp Browser...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Add Floorp GPG key
    curl -fsSL https://ppa.ablaze.one/KEY.gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/Floorp.gpg
    
    # Add Floorp repository
    sudo curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list 'https://ppa.ablaze.one/Floorp.list'
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y floorp; then
        echo -e "${RED}Failed to install Floorp Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Floorp Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Floorp by typing 'floorp' in the terminal or launching it from the applications menu.${NC}"
}

# Function to add butterrepo (shared by Zen and Helium)
add_butterrepo() {
    # Check if butterrepo is already configured
    if [ -f /etc/apt/sources.list.d/butterrepo.list ]; then
        return
    fi

    echo -e "${CYAN}Adding ButterRepo repository...${NC}"

    # Clean up old repository files if they exist
    sudo rm -f /etc/apt/sources.list.d/helium-deb-repo.list /etc/apt/sources.list.d/zen-deb-repo.list
    sudo rm -f /usr/share/keyrings/helium-deb-repo.gpg /usr/share/keyrings/zen-deb-repo.gpg

    # Add repository GPG key
    if ! curl -fsSL https://apt.justaguy.dev/key.asc | sudo gpg --dearmor --yes -o /usr/share/keyrings/butterrepo.gpg; then
        echo -e "${RED}Failed to add ButterRepo repository key.${NC}"
        return 1
    fi

    # Add repository to sources
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/butterrepo.gpg] https://apt.justaguy.dev stable main" | sudo tee /etc/apt/sources.list.d/butterrepo.list > /dev/null

    # Update package list
    sudo apt update
}

# Function to install Zen Browser
install_zen() {
    # Check if Zen Browser is already installed
    if is_installed zen-browser; then
        echo -e "${GREEN}Zen Browser is already installed. Skipping installation.${NC}"
        return
    fi

    echo -e "${GREEN}Installing Zen Browser...${NC}"

    # Install dependencies
    ensure_dependencies

    # Add butterrepo if not already configured
    if ! add_butterrepo; then
        return 1
    fi

    # Update package list and install Zen Browser
    sudo apt update
    if ! sudo apt install -y zen-browser; then
        echo -e "${RED}Failed to install Zen Browser.${NC}"
        return 1
    fi

    echo -e "${GREEN}Zen Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Zen Browser by typing 'zen-browser' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Helium Browser
install_helium() {
    # Check if Helium Browser is already installed
    if is_installed helium-browser; then
        echo -e "${GREEN}Helium Browser is already installed. Skipping installation.${NC}"
        return
    fi

    echo -e "${GREEN}Installing Helium Browser...${NC}"

    # Install dependencies
    ensure_dependencies

    # Add butterrepo if not already configured
    if ! add_butterrepo; then
        return 1
    fi

    # Update package list and install Helium Browser
    sudo apt update
    if ! sudo apt install -y helium-browser; then
        echo -e "${RED}Failed to install Helium Browser.${NC}"
        return 1
    fi

    echo -e "${GREEN}Helium Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Helium Browser by typing 'helium-browser' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Chromium
install_chromium() {
    # Check if Chromium is already installed
    if is_installed chromium || is_installed chromium-browser; then
        echo -e "${GREEN}Chromium Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Chromium Browser...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Install Chromium from Debian repositories
    sudo apt update
    if ! sudo apt install -y chromium; then
        echo -e "${RED}Failed to install Chromium Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Chromium Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Chromium by typing 'chromium' in the terminal or launching it from the applications menu.${NC}"
}

# Ensure we have necessary privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}This script requires sudo privileges for installation.${NC}"
    echo -e "${YELLOW}You'll be prompted for your password when necessary.${NC}"
fi

# Start installation process
show_menu

exit 0
