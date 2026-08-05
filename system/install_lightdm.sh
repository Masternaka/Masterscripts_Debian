#!/usr/bin/env bash
# DESC: Install and configure a display manager (LightDM, GDM, SDDM, LXDM, Ly)

# ===========================================
# Display Manager Installation Script
# ===========================================

# Clear the screen at the start to ensure script runs at the top of TTY
clear

# Set colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display script header
show_header() {
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}         DISPLAY MANAGER INSTALLATION SCRIPT             ${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${YELLOW}This script will help you install a display manager${NC}"
    echo -e "${YELLOW}for your system. LightDM is the recommended option.${NC}"
    echo
}

# Function to handle script exit
cleanup() {
    exit ${1:-0}
}

# Trap Ctrl+C
trap 'echo -e "\n${RED}Script interrupted.${NC}"; cleanup 1' INT

# Function to check if a package is installed
is_package_installed() {
    local package="$1"
    dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"
}

# Function to check if a service is enabled (active or will start at boot)
service_active_and_enabled() {
    local service="$1"
    sudo systemctl is-enabled --quiet "$service" 2>/dev/null
}

# Check if GDM is installed and enabled
check_gdm() {
    is_package_installed gdm3 && service_active_and_enabled gdm
}

# Check if SDDM is installed and enabled
check_sddm() {
    is_package_installed sddm && service_active_and_enabled sddm
}

# Check if LightDM is installed and enabled
check_lightdm() {
    is_package_installed lightdm && service_active_and_enabled lightdm
}

# Check if LXDM is installed and enabled
check_lxdm() {
    is_package_installed lxdm && service_active_and_enabled lxdm
}

# Check if Ly is the active display manager. Debian ships Ly as a systemd
# template (ly@.service) rather than a static ly.service, so systemctl
# is-enabled ly returns "not found" even when Ly is configured. The canonical
# signal is the display-manager.service symlink target.
check_ly() {
    is_package_installed ly && \
        [ "$(basename "$(readlink /etc/systemd/system/display-manager.service 2>/dev/null)" 2>/dev/null)" \
          = "ly@.service" ]
}

# Check if SLiM is installed and enabled
check_slim() {
    is_package_installed slim && service_active_and_enabled slim
}

# Function to install and enable LightDM
install_lightdm() {
    echo -e "${GREEN}Installing LightDM with GTK greeter...${NC}"
    # xserver-xorg, dbus-x11, fonts-cantarell are pulled explicitly because the
    # GTK greeter is X-based; without them, Wayland-only WMs (e.g. sway) boot
    # to a TTY.
    if ! sudo apt install -y --no-install-recommends \
        lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
        xserver-xorg dbus-x11 fonts-cantarell \
        gnome-themes-extra; then
        echo -e "${RED}Failed to install LightDM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable lightdm
    sudo systemctl set-default graphical.target

    local bg_line="background=#0a0a0e"
    if [ -f /usr/share/backgrounds/butterknife/butterknife-greeter.png ]; then
        bg_line="background=/usr/share/backgrounds/butterknife/butterknife-greeter.png"
    fi
    local avatar_line=""
    if [ -f /usr/share/butterbian/logo.png ]; then
        avatar_line="default-user-image = /usr/share/butterbian/logo.png"
    fi
    sudo tee /etc/lightdm/lightdm-gtk-greeter.conf >/dev/null <<EOF
[greeter]
${bg_line}
${avatar_line}
theme-name = Adwaita-dark
icon-theme-name = Adwaita
font-name = Cantarell 11
xft-antialias = true
xft-hintstyle = slight
xft-rgba = rgb
position = 50%,center 50%,center
clock-format = %a %b %-d  %H:%M
indicators = ~host;~spacer;~clock;~spacer;~session;~language;~a11y;~power
EOF

    # Default session: the freshest .desktop in xsessions/wayland-sessions is
    # the WM that triggered this install. Check both dirs so Wayland-only WMs
    # (sway, hyprland) get picked up too. user-session= only seeds the FIRST
    # login; lightdm saves the user's pick afterward.
    # greeter-hide-users=false shows the user as a click-to-login entry, so
    # repeat logins are one click + password (no username re-typing).
    local default_session=""
    default_session=$(ls -t /usr/share/xsessions/*.desktop \
        /usr/share/wayland-sessions/*.desktop 2>/dev/null \
        | head -n1 | xargs -r basename -s .desktop)
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    {
        echo "[Seat:*]"
        echo "greeter-hide-users=false"
        [ -n "$default_session" ] && echo "user-session=$default_session"
    } | sudo tee /etc/lightdm/lightdm.conf.d/50-butterbian.conf >/dev/null

    echo -e "${GREEN}LightDM has been installed and enabled.${NC}"
    if [ -n "$default_session" ]; then
        echo -e "${GREEN}Default session: ${default_session}${NC}"
    fi
    echo -e "${YELLOW}Tweak the greeter later via lightdm-gtk-greeter-settings.${NC}"
}

# Function to install and enable GDM3
install_gdm() {
    echo -e "${GREEN}Installing GDM3...${NC}"
    if ! sudo apt install -y gdm3; then
        echo -e "${RED}Failed to install GDM3.${NC}"
        cleanup 1
    fi
    sudo systemctl enable gdm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}GDM3 has been installed and enabled.${NC}"
    echo -e "${YELLOW}Note: GDM3 is resource-intensive compared to other display managers.${NC}"
}

# Function to install and enable SDDM
install_sddm() {
    echo -e "${GREEN}Installing minimal SDDM...${NC}"
    if ! sudo apt install -y --no-install-recommends sddm; then
        echo -e "${RED}Failed to install SDDM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable sddm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}SDDM has been installed and enabled.${NC}"
}

# Function to install and enable LXDM
install_lxdm() {
    echo -e "${GREEN}Installing LXDM...${NC}"
    if ! sudo apt install -y --no-install-recommends lxdm; then
        echo -e "${RED}Failed to install LXDM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable lxdm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}LXDM has been installed and enabled.${NC}"
}

# Function to install and enable Ly
install_ly() {
    echo -e "${GREEN}Installing Ly...${NC}"
    if ! sudo apt install -y ly; then
        echo -e "${RED}Failed to install Ly.${NC}"
        cleanup 1
    fi
    # Debian ships ly@.service as a template; bind it to tty2 (avoids fighting
    # the default getty on tty1) and point display-manager.service at it so
    # systemd brings it up at boot.
    sudo systemctl disable getty@tty2.service 2>/dev/null || true
    sudo systemctl enable ly@tty2.service
    sudo ln -sf /lib/systemd/system/ly@.service /etc/systemd/system/display-manager.service
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}Ly has been installed and enabled on tty2.${NC}"
}

# Print header
show_header

# Check which display managers are installed and enabled
if check_lightdm; then
    echo -e "${GREEN}LightDM is already installed and enabled (recommended).${NC}"
    exit 0
elif check_gdm; then
    echo -e "${GREEN}GDM3 is already installed and enabled.${NC}"
    exit 0
elif check_sddm; then
    echo -e "${GREEN}SDDM is already installed and enabled.${NC}"
    exit 0
elif check_lxdm; then
    echo -e "${GREEN}LXDM is already installed and enabled.${NC}"
    exit 0
elif check_ly; then
    echo -e "${GREEN}Ly is already installed and enabled.${NC}"
    exit 0
elif check_slim; then
    echo -e "${GREEN}SLiM is already installed and enabled.${NC}"
    exit 0
fi

# If none of the above are installed, offer a choice to the user
echo -e "${YELLOW}No supported display manager found.${NC}"

# Menu for user choice
echo -e "\n${CYAN}Choose an option (or '0' to skip):${NC}"
echo -e "${CYAN}1. ${NC}Install LightDM (recommended) - Lightweight and feature-rich"
echo -e "${CYAN}2. ${NC}Install minimal GDM3 - GNOME Display Manager"
echo -e "${CYAN}3. ${NC}Install minimal SDDM - Simple Desktop Display Manager"
echo -e "${CYAN}4. ${NC}Install LXDM - LXDE Display Manager"
echo -e "${CYAN}5. ${NC}Install Ly - TUI Display Manager"

read -p "Enter your choice (0/1/2/3/4/5): " choice

# Skip exits before this; everything else needs a fresh package index.
if [[ "$choice" != "0" ]]; then
    sudo apt update
fi

case $choice in
    0)
        echo -e "${YELLOW}Skipping installation.${NC}"
        exit 0
        ;;
    1)
        install_lightdm
        ;;
    2)
        install_gdm
        ;;
    3)
        install_sddm
        ;;
    4)
        install_lxdm
        ;;
    5)
        install_ly
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

cleanup
