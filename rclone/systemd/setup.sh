#!/bin/bash

echo "Installing rclone mounts"

# Error handling setup
set -e
trap 'echo "Error occurred on line $LINENO" >&2' ERR
trap 'printf "    \033[0;31mScript interrupted\033[0m\n" >&2; exit 1' INT

# First check that rclone is installed
if ! command -v rclone &> /dev/null
then
    echo "rclone is not installed. Please install it first."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Absolute path to configs dir: $SCRIPT_DIR"

# Link systemd services
mkdir -p ~/.config/systemd/user/
ln -sf "$SCRIPT_DIR/gdrive.service" ~/.config/systemd/user/
ln -sf "$SCRIPT_DIR/onedrive.service" ~/.config/systemd/user/
# ln -sf "$SCRIPT_DIR/dropbox.service" ~/.config/systemd/user/

# Create mount directories
mkdir -p ~/Google-Drive
mkdir -p ~/OneDrive
# mkdir -p ~/Dropbox

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable --now gdrive.service
systemctl --user enable --now onedrive.service
# systemctl --user enable --now dropbox.service

ALL_MOUNTS_PASSED=true

if ! rclone listremotes | grep -q "gdrive:"; then
    echo "Error: gdrive remote was not configured in rclone"
    ALL_MOUNTS_PASSED=false
else
    echo "gdrive remote appears configured."
fi

if ! rclone listremotes | grep -q "onedrive:"; then
    echo "Error: onedrive remote was not configured in rclone"
    ALL_MOUNTS_PASSED=false
else
    echo "onedrive remote appears configured."
fi

if ! ALL_MOUNTS_PASSED; then
    printf "\033[0;31mERROR\033[0m: Not all mounts were successful.\n"
    exit 1
fi
