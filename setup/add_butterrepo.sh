#!/usr/bin/env bash
# DESC: Add butterrepo APT repository if not already configured
# Usage: source this script or run it directly
#   source /path/to/add_butterrepo.sh
#   OR
#   wget -qO- "https://justaguy.dev/drew/butterscripts/raw/branch/main/setup/add_butterrepo.sh" | bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

add_butterrepo() {
    if [ -f /etc/apt/sources.list.d/butterrepo.list ] && [ -f /usr/share/keyrings/butterrepo.gpg ]; then
        echo -e "${YELLOW}ButterRepo already configured.${NC}"
        return 0
    fi

    echo -e "${YELLOW}Adding ButterRepo APT repository...${NC}"
    sudo apt-get install -y curl gnupg
    curl -fsSL https://apt.justaguy.dev/key.asc | sudo gpg --dearmor -o /usr/share/keyrings/butterrepo.gpg || { echo "ERROR: Failed to add ButterRepo GPG key." >&2; return 1; }
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/butterrepo.gpg] https://apt.justaguy.dev stable main" | sudo tee /etc/apt/sources.list.d/butterrepo.list
    sudo apt-get update
    echo -e "${GREEN}ButterRepo added successfully.${NC}"
}

add_butterrepo
