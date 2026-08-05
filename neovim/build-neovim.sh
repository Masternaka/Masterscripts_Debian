#!/usr/bin/env bash
# DESC: Build Neovim from source and create .deb package

set -e

echo "==============================================="
echo "  ButterScripts: Build Neovim from Source     "
echo "==============================================="
echo

echo "Installing build prerequisites..."
sudo apt update
sudo apt install -y ninja-build gettext cmake unzip curl git

ORIG_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Cloning Neovim repository..."
git clone https://github.com/neovim/neovim
cd neovim

# Get latest stable tag
git fetch --tags
LATEST_TAG=$(git tag -l 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -1)
echo "Building version: $LATEST_TAG"
git checkout "$LATEST_TAG"

echo "Building Neovim..."
make clean || true
make CMAKE_BUILD_TYPE=Release -j$(nproc)

echo "Creating Debian package..."
cd build
cpack -G DEB

# Copy and rename deb to match butterrepo convention
DEB_FILE=$(ls nvim-linux*.deb 2>/dev/null | head -1)
if [ -n "$DEB_FILE" ]; then
    VERSION=$(echo "$LATEST_TAG" | sed 's/^v//')
    FINAL_NAME="neovim_${VERSION}_amd64.deb"
    cp "$DEB_FILE" "$ORIG_DIR/$FINAL_NAME"
    echo "Package: $ORIG_DIR/$FINAL_NAME"
fi

# Clean up
cd
rm -rf "$TEMP_DIR"

echo
echo "Build complete!"
echo "To install: sudo dpkg -i $ORIG_DIR/$FINAL_NAME"
echo "==============================================="
