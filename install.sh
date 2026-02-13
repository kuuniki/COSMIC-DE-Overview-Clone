#!/bin/bash
set -e

echo "=== Cosmic Workspaces with Launcher Integration - Installation ==="
echo ""

if [ ! -f "Cargo.toml" ]; then
    echo "Error: Please run this script from the cosmic-workspaces-epoch directory"
    exit 1
fi

INSTALL_DIR="$(pwd)"

echo "Building release binary..."
cargo build --release

if [ ! -f "target/release/cosmic-workspaces" ]; then
    echo "Error: Build failed"
    exit 1
fi
echo "Build successful!"
echo ""

# Backup binary with incremental numbering
if [ -f "/usr/bin/cosmic-workspaces" ]; then
    BACKUP_NUM=1
    while [ -f "/usr/bin/cosmic-workspaces.backup${BACKUP_NUM}" ]; do
        BACKUP_NUM=$((BACKUP_NUM + 1))
    done
    echo "Backing up to /usr/bin/cosmic-workspaces.backup${BACKUP_NUM}..."
    sudo cp /usr/bin/cosmic-workspaces "/usr/bin/cosmic-workspaces.backup${BACKUP_NUM}"
fi

# Configure Super key
SHORTCUTS_CONFIG="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom"
echo "Configuring Super key to open Workspaces..."
if [ -f "$SHORTCUTS_CONFIG" ]; then
    cp "$SHORTCUTS_CONFIG" "${SHORTCUTS_CONFIG}.backup.$(date +%s)"
fi
cat > "$SHORTCUTS_CONFIG" << 'SHORTCUTS'
{
    (
        modifiers: [
            Super,
        ],
    ): System(WorkspaceOverview),
}
SHORTCUTS
echo "Super key configured!"

# Install atomically
echo "Installing..."
sudo cp target/release/cosmic-workspaces /usr/bin/cosmic-workspaces.new
sudo chmod +x /usr/bin/cosmic-workspaces.new
sudo mv /usr/bin/cosmic-workspaces.new /usr/bin/cosmic-workspaces

# Restart so new binary takes effect
echo "Restarting cosmic-workspaces..."
sudo killall cosmic-workspaces 2>/dev/null || true
sleep 1
echo "Installed successfully!"

# Pacman hook to survive updates
echo "Creating pacman hook..."
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/cosmic-workspaces-custom.hook > /dev/null << HOOK
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = cosmic-workspaces

[Action]
Description = Reinstalling custom cosmic-workspaces with launcher integration...
When = PostTransaction
Exec = /bin/sh -c 'cp ${INSTALL_DIR}/target/release/cosmic-workspaces /usr/bin/cosmic-workspaces.new && chmod +x /usr/bin/cosmic-workspaces.new && mv /usr/bin/cosmic-workspaces.new /usr/bin/cosmic-workspaces && killall cosmic-workspaces 2>/dev/null || true'
HOOK
echo "Pacman hook installed!"

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "  ✓ Press Super to open workspaces with integrated launcher"
echo "  ✓ Type to search apps immediately"
echo "  ✓ Space, backspace, arrow keys all work"
echo "  ✓ Enter or click to launch"
echo "  ✓ Clicking dock closes the view"
echo "  ✓ Auto-reinstalls after system updates"
echo ""
