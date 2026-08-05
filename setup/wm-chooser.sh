#!/usr/bin/env bash
# Butterbian WM Chooser
# Install one or more window managers from justaguylinux setup repos
# Usage: bash wm-chooser.sh

BOLD="\e[1m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

REPO_BASE="https://justaguy.dev/drew"

declare -a WM_NAMES=(
    ""
    "awesomewm"
    "bspwm"
    "dwm"
    "i3"
    "openbox"
    "qtile"
    "sway"
    "swayfx"
)

clear
echo -e "${BOLD}${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║       Butterbian WM Chooser          ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  Select window manager(s) to install:\n"
echo -e "  ${BOLD}  X11:${RESET}"
echo -e "  ${CYAN}1)${RESET} awesome       Highly configurable tiling WM (Lua)"
echo -e "  ${CYAN}2)${RESET} bspwm         Binary space partitioning WM"
echo -e "  ${CYAN}3)${RESET} dwm           Dynamic window manager (suckless)"
echo -e "  ${CYAN}4)${RESET} i3            Tiling WM with great documentation"
echo -e "  ${CYAN}5)${RESET} openbox       Configured stacking WM (Butterbian)"
echo -e "  ${CYAN}6)${RESET} qtile         Tiling WM written in Python"
echo ""
echo -e "  ${BOLD}  Wayland:${RESET}"
echo -e "  ${CYAN}7)${RESET} sway          i3-compatible Wayland compositor"
echo -e "  ${CYAN}8)${RESET} swayfx        Sway with eye candy"
echo ""
echo -e "  ${YELLOW}0)${RESET} Cancel"
echo ""
echo -e "  ${BOLD}You can select multiple: e.g., 3 4 7${RESET}"
echo ""

while true; do
    read -rp "  Enter choice(s): " input

    [[ "$input" == "0" ]] && {
        echo -e "\n  ${YELLOW}Cancelled.${RESET}\n"
        exit 0
    }

    valid=true
    choices=()
    for c in $input; do
        if [[ "$c" =~ ^[1-8]$ ]]; then
            choices+=("$c")
        else
            echo -e "  ${RED}Invalid choice: $c${RESET}"
            valid=false
            break
        fi
    done

    [[ "$valid" == true ]] && [[ ${#choices[@]} -gt 0 ]] && break
    echo -e "  ${RED}Enter numbers 1-8 separated by spaces, or 0 to cancel.${RESET}"
done

# Remove duplicates
choices=($(printf '%s\n' "${choices[@]}" | sort -u))

echo ""
echo -e "  ${BOLD}You selected:${RESET}"
for c in "${choices[@]}"; do
    echo -e "    ${CYAN}→${RESET} ${WM_NAMES[$c]}"
done
echo ""
read -rp "  Proceed with installation? [Y/n] " confirm
[[ "$confirm" =~ ^[Nn]$ ]] && {
    echo -e "\n  ${YELLOW}Cancelled.${RESET}\n"
    exit 0
}

# Disable Timeshift apt hook during setup (avoid snapshots of partial installs)
APT_HOOK="/etc/apt/apt.conf.d/80timeshift-snapshot"
if [ -f "$APT_HOOK" ]; then
    sudo mv "$APT_HOOK" "${APT_HOOK}.disabled"
fi

reenable_hook() {
    if [ -f "${APT_HOOK}.disabled" ]; then
        sudo mv "${APT_HOOK}.disabled" "$APT_HOOK"
    fi
}
trap reenable_hook EXIT

# Install each selected WM
ORIG_DIR="$(pwd)"
total=${#choices[@]}
current=0

for c in "${choices[@]}"; do
    current=$((current + 1))
    wm_name="${WM_NAMES[$c]}"
    REPO_URL="${REPO_BASE}/${wm_name}-setup"

    echo ""
    echo -e "  ${BOLD}${CYAN}[$current/$total] Installing ${wm_name}...${RESET}\n"

    TEMP_DIR=$(mktemp -d)

    echo -e "  ${YELLOW}Cloning ${REPO_URL}...${RESET}\n"
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/${wm_name}-setup" || {
        echo -e "  ${RED}Failed to clone ${wm_name}-setup. Skipping.${RESET}"
        rm -rf "$TEMP_DIR"
        continue
    }

    cd "$TEMP_DIR/${wm_name}-setup"
    echo -e "  ${YELLOW}Running install.sh...${RESET}\n"
    bash install.sh || {
        echo -e "\n  ${RED}${wm_name} install.sh encountered an error.${RESET}"
    }

    cd "$ORIG_DIR"
    rm -rf "$TEMP_DIR"
done

# Take Timeshift snapshot if available
if command -v timeshift &>/dev/null; then
    echo ""
    echo -e "  ${YELLOW}Creating Timeshift snapshot...${RESET}"
    sudo timeshift --btrfs --create --comments "Post WM install" --scripted 2>/dev/null || true
fi

echo ""
echo -e "  ${GREEN}${BOLD}Installation complete!${RESET}"
echo -e "  Log out and select your WM from the session menu.\n"
