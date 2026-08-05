#!/usr/bin/env bash
# DESC: Interactive installer for optional applications from butterscripts and APT repositories

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Base URL for raw butterscripts on Butterforge.
BASE="https://justaguy.dev/drew/butterscripts/raw/branch/main"

# Lean driverless core: modern IPP/AirPrint/eSCL printers + network scanning.
# No cups-pdf — virtual pkg, no install candidate, aborts apt (issue #5).
declare -a PRINTER_PACKAGES=(
    cups cups-client cups-filters cups-browsed
    avahi-daemon ipp-usb printer-driver-cups-pdf
    system-config-printer sane-utils sane-airscan simple-scan
)

# Full-coverage add-on for old/non-driverless printers. printer-driver-all
# ships drivers as Recommends -> install --with-recommends or they're skipped.
declare -a PRINTER_DRIVER_PACKAGES=(printer-driver-all hplip)

# Core Bluetooth stack. Audio plugin is server-dependent, added at install time.
declare -a BLUETOOTH_PACKAGES=(bluez bluez-tools blueman)

# Banner shown once on the next show_header, then cleared — lets actions report
# their result on the menu instead of pausing for "Press Enter".
LAST_ACTION=""

# Inside butterknife's chroot `sudo reboot` is a no-op; hide reboot there.
IN_CHROOT=false
ischroot 2>/dev/null && IN_CHROOT=true

show_header() {
    clear
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}           BUTTER APPLICATIONS INSTALLER                 ${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    if [ -n "$LAST_ACTION" ]; then
        echo -e "$LAST_ACTION"
        LAST_ACTION=""
    else
        echo -e "${YELLOW}This script will help you install various applications${NC}"
        echo -e "${YELLOW}from the butterscripts repository and APT packages.${NC}"
    fi
    echo
}

ask_yes_no() {
    local response
    while true; do
        read -rp "$1 [y/n]: " response
        case "${response,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo -e "${RED}Please answer yes or no.${NC}" ;;
        esac
    done
}

# Install a group of packages. Leading --with-recommends forces Recommends
# (needed when a metapackage's payload is Recommends, e.g. printer-driver-all).
install_package_group() {
    local apt_opts=()
    [[ "$1" == "--with-recommends" ]] && { apt_opts+=(--install-recommends); shift; }
    local packages=("$@") enable_cups=false enable_bt=false

    for pkg in "${packages[@]}"; do
        [[ "$pkg" == cups ]] && enable_cups=true
        [[ "$pkg" == bluetooth || "$pkg" == bluez ]] && enable_bt=true
    done

    echo -e "${YELLOW}Updating package lists...${NC}"
    sudo apt-get update
    echo -e "${YELLOW}Installing packages...${NC}"
    sudo apt-get install -y "${apt_opts[@]}" "${packages[@]}" || return 1

    if [ "$enable_cups" = true ]; then
        echo -e "${YELLOW}Enabling CUPS service...${NC}"
        sudo systemctl enable --now cups
    fi
    if [ "$enable_bt" = true ]; then
        echo -e "${YELLOW}Enabling Bluetooth service...${NC}"
        sudo systemctl enable --now bluetooth
    fi
    [ "$enable_cups" = true ] || [ "$enable_bt" = true ] && \
        echo -e "${YELLOW}NOTE: a reboot is recommended so services start cleanly.${NC}"
    return 0
}

# Download a butterscript to /tmp ($1=url, $2=name). Returns non-zero on failure.
download_script() {
    echo -e "${YELLOW}Downloading $2...${NC}"
    rm -f "/tmp/$2"
    if ! wget -q "$1" -O "/tmp/$2" || [ ! -s "/tmp/$2" ]; then
        rm -f "/tmp/$2"
        echo -e "${RED}Download failed: $2${NC}"
        return 1
    fi
    chmod +x "/tmp/$2"
    echo -e "${GREEN}Download complete.${NC}"
}

# Download and run a butterscript, reporting the result via LAST_ACTION.
# Args: <url> <name> <label> [extra args passed to the script]
fetch_run() {
    local url="$1" name="$2" label="$3"; shift 3
    download_script "$url" "$name" || { LAST_ACTION="${RED}$label download failed.${NC}"; return; }
    if bash "/tmp/$name" "$@"; then
        LAST_ACTION="${GREEN}$label installed.${NC}"
    else
        LAST_ACTION="${RED}$label installation failed or was cancelled.${NC}"
    fi
}

# Clone a butter repo to /tmp and run its install.sh. Args: <repo-url> <label>
clone_install() {
    local repo="$1" label="$2" tmp="/tmp/${2,,}-$$"
    echo -e "${CYAN}Installing $label...${NC} (your rc file will be backed up)"
    if ! git clone --quiet "$repo" "$tmp" 2>/dev/null; then
        LAST_ACTION="${RED}Failed to clone $label repository.${NC}"
        return
    fi
    if ( cd "$tmp" && SKIP_CONFIRMATION=true bash install.sh ); then
        LAST_ACTION="${GREEN}$label installed.${NC}"
    else
        LAST_ACTION="${RED}$label installation failed or was cancelled.${NC}"
    fi
    rm -rf "$tmp"
}

install_fastfetch() {
    show_header
    echo -e "${CYAN}Installing Fastfetch...${NC}"
    mkdir -p /tmp/fastfetch-configs
    local c
    for c in config.jsonc minimal.jsonc server.jsonc; do
        wget -q "$BASE/fastfetch/$c" -O "/tmp/fastfetch-configs/$c"
    done
    export script_dir="/tmp/fastfetch-configs"
    fetch_run "$BASE/fastfetch/install_fastfetch.sh" install_fastfetch.sh "Fastfetch"
}

# Printer Support: lean driverless, or full driver coverage.
install_printer_support() {
    local choice packages=("${PRINTER_PACKAGES[@]}") opts=()

    show_header
    echo -e "${CYAN}Printer & Scanner Support${NC}"
    echo -e "${CYAN}1. ${NC}Driverless - CUPS + auto-discovery, modern printers (lean)"
    echo -e "${CYAN}2. ${NC}Full drivers - adds every driver + HP, for older printers (~70MB)"
    echo -e "${CYAN}q. ${NC}Back"
    echo
    read -rp "Enter your choice [1-2, q]: " choice

    case "$choice" in
        1) ;;
        2) packages+=("${PRINTER_DRIVER_PACKAGES[@]}"); opts=(--with-recommends) ;;
        q|Q) return ;;
        *) LAST_ACTION="${RED}Invalid option.${NC}"; return ;;
    esac

    if install_package_group "${opts[@]}" "${packages[@]}"; then
        LAST_ACTION="${GREEN}Printer & scanner support installed.${NC}\n${YELLOW}Manage via system-config-printer, simple-scan, or http://localhost:631${NC}"
    else
        LAST_ACTION="${RED}Printer support installation failed.${NC}"
    fi
}

install_bluetooth_support() {
    show_header
    echo -e "${CYAN}Installing Bluetooth Support...${NC}"

    # BT audio plugin: libspa for PipeWire (default), pulseaudio module only if
    # PulseAudio is in use and PipeWire isn't — mixing them kills sound.
    local audio=libspa-0.2-bluetooth
    if ! dpkg -s pipewire &>/dev/null && dpkg -s pulseaudio &>/dev/null; then
        audio=pulseaudio-module-bluetooth
    fi
    local packages=("${BLUETOOTH_PACKAGES[@]}" "$audio")

    echo -e "${YELLOW}Installing: ${packages[*]}${NC}"
    echo
    if install_package_group "${packages[@]}"; then
        LAST_ACTION="${GREEN}Bluetooth support installed.${NC}\n${YELLOW}Use the Bluetooth Manager (blueman) to connect devices.${NC}"
    else
        LAST_ACTION="${RED}Bluetooth support installation failed.${NC}"
    fi
}

# Prompt for picks from a category (nameref $1) and append to selections ($3),
# showing the running total so far.
prompt_category() {
    local -n category_array=$1
    local category_name=$2
    local -n selections=$3
    local choice num

    show_header
    [ "${#selections[@]}" -gt 0 ] && \
        echo -e "${GREEN}Selected so far (${#selections[@]}): ${selections[*]}${NC}\n"
    echo -e "${CYAN}Select ${category_name}:${NC}"
    echo -e "${YELLOW}Type space-separated numbers, or press Enter to skip.${NC}\n"
    for i in "${!category_array[@]}"; do
        echo -e "${CYAN}$((i+1)). ${NC}${category_array[$i]}"
    done
    echo
    read -rp "> " choice

    for num in $choice; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#category_array[@]}" ]; then
            selections+=("${category_array[$((num-1))]}")
        fi
    done
}

# shellcheck disable=SC2034  # category arrays are consumed by prompt_category via nameref
install_apt_packages() {
    local file_managers=(thunar pcmanfm krusader nautilus nemo dolphin ranger nnn lf)
    local graphics=(gimp flameshot eog sxiv qimgv inkscape maim)
    local terminals=(alacritty gnome-terminal kitty konsole terminator xfce4-terminal)
    local text_editors=(kate gedit l3afpad mousepad pluma)
    local multimedia=(mpv vlc audacity kdenlive obs-studio rhythmbox ncmpcpp mkvtoolnix-gui)
    local utilities=(gparted gnome-disk-utility nitrogen numlockx galculator cpu-x dnsutils whois curl tree btop htop bat brightnessctl)
    local all_selections=() custom_input=""

    prompt_category file_managers "File Managers"           all_selections
    prompt_category graphics      "Graphics Applications"   all_selections
    prompt_category terminals     "Terminal Emulators"      all_selections
    prompt_category text_editors  "Text Editors"            all_selections
    prompt_category multimedia    "Multimedia Applications" all_selections
    prompt_category utilities     "Utilities"               all_selections

    show_header
    [ "${#all_selections[@]}" -gt 0 ] && \
        echo -e "${GREEN}Selected so far (${#all_selections[@]}): ${all_selections[*]}${NC}\n"
    echo -e "${CYAN}LibreOffice Installation:${NC}"
    echo -e "${YELLOW}Complete office suite (Writer, Calc, Impress, Draw, Math, Base)${NC}\n"
    ask_yes_no "Do you want to install LibreOffice?" && all_selections+=(libreoffice)

    show_header
    echo -e "${CYAN}Custom Package Installation:${NC}"
    echo -e "${YELLOW}Enter extra package names (space-separated) or press Enter to skip:${NC}\n"
    read -rp "> " custom_input

    if [[ -n "$custom_input" ]]; then
        local valid_custom=() invalid_custom=() pkg
        for pkg in $custom_input; do
            if apt-cache show "$pkg" &>/dev/null; then
                valid_custom+=("$pkg")
            else
                invalid_custom+=("$pkg")
            fi
        done
        # One unknown name aborts the whole apt transaction, so drop unknowns
        # rather than letting a typo wipe out the curated picks.
        if [ "${#invalid_custom[@]}" -gt 0 ]; then
            echo -e "\n${RED}Not found, will be skipped: ${invalid_custom[*]}${NC}"
            [ "${#valid_custom[@]}" -gt 0 ] && echo -e "${GREEN}Will install: ${valid_custom[*]}${NC}"
            read -rp "Press Enter to continue..."
        fi
        all_selections+=("${valid_custom[@]}")
    fi

    if [ ${#all_selections[@]} -eq 0 ]; then
        LAST_ACTION="${YELLOW}No packages selected.${NC}"
        return
    fi

    show_header
    echo -e "${CYAN}Selected packages (${#all_selections[@]}):${NC} ${all_selections[*]}\n"
    if ! ask_yes_no "Install these packages?"; then
        LAST_ACTION="${YELLOW}APT installation cancelled.${NC}"
        return
    fi
    if install_package_group "${all_selections[@]}"; then
        LAST_ACTION="${GREEN}APT packages installed (${#all_selections[@]}).${NC}"
    else
        LAST_ACTION="${RED}APT installation failed.${NC}"
    fi
}

show_butterscripts_menu() {
    local choice
    while true; do
        show_header
        echo -e "${YELLOW}Select a ButterScript to install:${NC}"
        echo -e "${CYAN}1. ${NC}ButterBash - Modular bash configuration framework ⭐"
        echo -e "${CYAN}2. ${NC}ButterZsh - Modular zsh configuration framework ⭐"
        echo -e "${CYAN}3. ${NC}Geany - Text Editor with plugins (ButterRepo 2.1 or APT)"
        echo -e "${CYAN}4. ${NC}Browsers - Firefox, LibreWolf, Brave, Floorp, Chromium, Zen"
        echo -e "${CYAN}5. ${NC}Discord - Chat and Voice Application"
        echo -e "${CYAN}6. ${NC}Fastfetch - System Information Display Tool"
        echo -e "${CYAN}7. ${NC}Neovim - pick config (vim motions, GUI keys, or vanilla)"
        echo -e "${CYAN}8. ${NC}WezTerm - GPU-accelerated Terminal (Nightly + config)"
        echo -e "${CYAN}9. ${NC}Ghostty - GPU-accelerated Terminal (ButterRepo + config)"
        echo -e "${CYAN}q. ${NC}Back"
        echo
        echo -e "${YELLOW}NOTE: each installer has its own options; install one at a time.${NC}\n"
        read -rp "Enter your choice [1-9, q]: " choice

        case $choice in
            1) clone_install https://justaguy.dev/drew/butterbash.git "ButterBash" ;;
            2) clone_install https://justaguy.dev/drew/butterzsh.git "ButterZsh" ;;
            3) fetch_run "$BASE/setup/install_geany.sh"       install_geany.sh    "Geany" ;;
            4) fetch_run "$BASE/browsers/install_browsers.sh" install_browsers.sh "Browsers" ;;
            5) fetch_run "$BASE/discord/discord"              discord             "Discord" install ;;
            6) install_fastfetch ;;
            7) fetch_run "$BASE/neovim/neovim.sh"             neovim.sh           "Neovim" ;;
            8) fetch_run "$BASE/wezterm/install_wezterm.sh"   install_wezterm.sh  "WezTerm" ;;
            9) fetch_run "$BASE/ghostty/install_ghostty.sh"   install_ghostty.sh  "Ghostty" ;;
            q|Q) return ;;
            *) echo -e "${RED}Invalid option.${NC}" ;;
        esac
    done
}

# Install a stock Debian DE (task-*-desktop) + the firmware/codec userland a
# desktop install adds. Coexists with whatever WM wm-chooser installed.
install_desktop_environment() {
    local choice="${1:-}" pkg dm name

    show_header
    echo -e "${CYAN}Install a Desktop Environment${NC}"
    echo -e "${YELLOW}Stock Debian task-*-desktop + firmware, VA/VDPAU and codecs.${NC}"
    echo -e "${YELLOW}Pulls 1-2GB; expect 5-15 minutes depending on link speed.${NC}\n"

    if [ -z "$choice" ]; then
        if [ -r /etc/X11/default-display-manager ]; then
            echo -e "  ${CYAN}Current display manager:${NC} $(cat /etc/X11/default-display-manager)"
        else
            echo -e "  ${CYAN}Current display manager:${NC} none (console login)"
        fi
        echo
        echo -e "  ${BOLD}Full desktops:${NC}"
        echo -e "  ${CYAN}1.${NC} KDE Plasma  (task-kde-desktop, sddm)"
        echo -e "  ${CYAN}2.${NC} GNOME       (task-gnome-desktop, gdm3)"
        echo -e "  ${CYAN}3.${NC} Cinnamon    (task-cinnamon-desktop, lightdm)"
        echo
        echo -e "  ${BOLD}Lighter desktops:${NC}"
        echo -e "  ${CYAN}4.${NC} XFCE        (task-xfce-desktop, lightdm)"
        echo -e "  ${CYAN}5.${NC} MATE        (task-mate-desktop, lightdm)"
        echo -e "  ${CYAN}6.${NC} LXQt        (task-lxqt-desktop, sddm)"
        echo
        echo -e "  ${BOLD}From ButterRepo (unofficial packages, amd64):${NC}"
        echo -e "  ${CYAN}7.${NC} COSMIC      (cosmic-desktop, cosmic-greeter)"
        echo
        echo -e "  ${CYAN}q.${NC} Cancel"
        echo
        read -rp "Enter your choice [1-7, q]: " choice
    fi

    case "$choice" in
        1) name="KDE Plasma"; pkg="task-kde-desktop";      dm="sddm"    ;;
        2) name="GNOME";      pkg="task-gnome-desktop";    dm="gdm3"    ;;
        3) name="Cinnamon";   pkg="task-cinnamon-desktop"; dm="lightdm" ;;
        4) name="XFCE";       pkg="task-xfce-desktop";     dm="lightdm" ;;
        5) name="MATE";       pkg="task-mate-desktop";     dm="lightdm" ;;
        6) name="LXQt";       pkg="task-lxqt-desktop";     dm="sddm"    ;;
        7|cosmic) name="COSMIC"; pkg="cosmic-desktop";     dm="cosmic-greeter" ;;
        q|Q) LAST_ACTION="${YELLOW}Desktop installation cancelled.${NC}"; return ;;
        *)   LAST_ACTION="${RED}Invalid option.${NC}"; return ;;
    esac

    if [ "$pkg" = cosmic-desktop ]; then
        if [ "$(dpkg --print-architecture)" != amd64 ]; then
            LAST_ACTION="${RED}COSMIC packages are amd64-only.${NC}"
            return
        fi
        echo -e "\n${YELLOW}COSMIC installs from the unofficial cosmic-trixie ButterRepo and${NC}"
        echo -e "${YELLOW}needs GPU acceleration (in a VM, enable 3D / virtio-gpu).${NC}"
    fi

    echo
    if ! ask_yes_no "Install $name now?"; then
        LAST_ACTION="${YELLOW}Desktop installation cancelled.${NC}"
        return
    fi

    # COSMIC will never ship in trixie's archive; pull it from cosmic-trixie.
    if [ "$pkg" = cosmic-desktop ]; then
        local cosmic_repo="https://apt.justaguy.dev/cosmic-trixie"
        echo -e "\n${YELLOW}Adding cosmic-trixie repository...${NC}"
        if ! sudo wget -q "$cosmic_repo/key.asc" -O /usr/share/keyrings/cosmic-trixie.asc; then
            sudo rm -f /usr/share/keyrings/cosmic-trixie.asc
            LAST_ACTION="${RED}Failed to fetch the cosmic-trixie signing key.${NC}"
            return
        fi
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cosmic-trixie.asc] $cosmic_repo trixie main" | \
            sudo tee /etc/apt/sources.list.d/cosmic-trixie.list >/dev/null
    fi

    # va-driver-all picks the right VA-API driver per GPU; apt skips anything
    # already in the base, so this is safe to send through every time.
    local media_stack=(
        firmware-linux firmware-linux-nonfree firmware-intel-graphics
        va-driver-all vdpau-driver-all
        mesa-va-drivers mesa-vdpau-drivers libvdpau-va-gl1
        libavcodec-extra ffmpeg
        gstreamer1.0-plugins-good gstreamer1.0-plugins-bad
        gstreamer1.0-plugins-ugly gstreamer1.0-libav
    )

    echo -e "\n${YELLOW}Preseeding default display manager to $dm...${NC}"
    echo "$dm shared/default-x-display-manager select $dm" | sudo debconf-set-selections

    echo -e "${YELLOW}Updating package lists...${NC}"
    sudo apt-get update

    echo -e "${YELLOW}Installing firmware + media stack + $pkg (this will take a while)...${NC}"
    # $dm explicit: cinnamon-core's DM dep is an OR satisfied by any installed
    # display manager, so the task alone won't pull lightdm onto such systems.
    if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${media_stack[@]}" "$pkg" "$dm"; then
        LAST_ACTION="${RED}$name installation failed. Check output above for details.${NC}"
        return
    fi

    # Backfill Recommends skipped by butterknife's --no-install-recommends base
    # (NM mobile-broadband, alsa-ucm-conf, rtkit, the perl/libwww stack, ...).
    echo -e "${YELLOW}Backfilling recommended packages...${NC}"
    sudo apt-get install -y --fix-policy

    # Enable the DM via plain symlinks: works in the installer chroot, and
    # gdm3/sddm ship empty [Install] sections so `systemctl enable` is a no-op.
    sudo ln -sf "/lib/systemd/system/$dm.service" /etc/systemd/system/display-manager.service
    sudo ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
    LAST_ACTION="${GREEN}$name installed.${NC}\n${YELLOW}Reboot to reach the $dm login screen, then pick $name from the session menu.${NC}"

    if [ "$IN_CHROOT" = false ] && ask_yes_no "Reboot now to start the $dm login screen?"; then
        echo -e "${GREEN}Rebooting...${NC}"; sleep 2; sudo reboot
    fi
}

reboot_system() {
    show_header
    echo -e "${CYAN}System Reboot${NC}"
    echo -e "${YELLOW}Recommended after installing system services or drivers.${NC}\n"
    if ask_yes_no "Reboot the system now?"; then
        echo -e "${GREEN}Initiating system reboot...${NC}"; sleep 2; sudo reboot
    else
        LAST_ACTION="${YELLOW}Reboot cancelled.${NC}"
    fi
}

show_main_menu() {
    local choice last_choice
    while true; do
        show_header
        echo -e "${YELLOW}Please select an installation option:${NC}"
        echo -e "${CYAN}1. ${NC}Butterscripts Installers"
        echo -e "${CYAN}2. ${NC}APT Package Installation"
        echo -e "${CYAN}3. ${NC}Printer Support"
        echo -e "${CYAN}4. ${NC}Bluetooth Support"
        echo -e "${CYAN}5. ${NC}Desktop Environment (KDE/GNOME/XFCE/Cinnamon/MATE/LXQt/COSMIC)"
        if [ "$IN_CHROOT" = false ]; then
            echo -e "${CYAN}6. ${NC}Reboot System"
            last_choice="6, q"
        else
            last_choice="q"
        fi
        echo -e "${CYAN}q. ${NC}Quit"
        echo
        read -rp "Enter your choice [1-5, $last_choice]: " choice

        case $choice in
            1) show_butterscripts_menu ;;
            2) install_apt_packages ;;
            3) install_printer_support ;;
            4) install_bluetooth_support ;;
            5) install_desktop_environment ;;
            6) [ "$IN_CHROOT" = false ] && reboot_system || LAST_ACTION="${RED}Invalid option.${NC}" ;;
            q|Q) echo -e "${GREEN}Exiting installer. Thank you for using Butter Installer!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option.${NC}" ;;
        esac
    done
}

# wget is required for downloading scripts.
if ! command -v wget &>/dev/null; then
    echo -e "${YELLOW}Installing wget (required for downloads)...${NC}"
    sudo apt-get update && sudo apt-get install -y wget
fi

# Direct mode: `optional_tools.sh cosmic` skips the menus and goes straight to
# the COSMIC install — butterknife's wm-chooser COSMIC entry uses this. The
# result banner that would land on the menu prints before exit instead.
if [ "${1:-}" = cosmic ]; then
    install_desktop_environment cosmic
    echo -e "$LAST_ACTION"
    exit 0
fi

show_main_menu
