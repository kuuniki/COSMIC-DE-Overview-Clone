cat > install.sh << 'EOF'
#!/bin/bash
set -e  # Exit on error

echo "=== Cosmic Workspaces with Launcher Integration - Installation ==="
echo ""

# Check if we're in the right directory
if [ ! -f "Cargo.toml" ]; then
    echo "Error: Please run this script from the cosmic-workspaces-epoch directory"
    exit 1
fi

# Build the release binary
echo "Building release binary..."
cargo build --release

if [ ! -f "target/release/cosmic-workspaces" ]; then
    echo "Error: Build failed - binary not found"
    exit 1
fi

echo "Build successful!"
echo ""

# Backup original with incremental numbering
if [ -f "/usr/bin/cosmic-workspaces" ]; then
    echo "Backing up original cosmic-workspaces..."
    
    # Find next available backup number
    BACKUP_NUM=1
    while [ -f "/usr/bin/cosmic-workspaces.backup${BACKUP_NUM}" ]; do
        BACKUP_NUM=$((BACKUP_NUM + 1))
    done
    
    sudo cp /usr/bin/cosmic-workspaces "/usr/bin/cosmic-workspaces.backup${BACKUP_NUM}"
    echo "Original backed up to /usr/bin/cosmic-workspaces.backup${BACKUP_NUM}"
fi

# Configure Super key to open Workspaces
SHORTCUTS_CONFIG="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom"
echo "Configuring Super key to open Workspaces..."

if [ -f "$SHORTCUTS_CONFIG" ]; then
    # Backup existing config with timestamp
    cp "$SHORTCUTS_CONFIG" "${SHORTCUTS_CONFIG}.backup.$(date +%s)"
fi

# Write the Super key binding
cat > "$SHORTCUTS_CONFIG" << 'SHORTCUTS'
{
    (
        modifiers: [
            Super,
        ],
    ): System(WorkspaceOverview),
}
SHORTCUTS

echo "Super key configured to open Workspaces"

# Kill existing process
echo "Stopping cosmic-workspaces..."
sudo pkill -9 -f cosmic-workspaces 2>/dev/null || true
sleep 1

# Copy our version
echo "Installing custom cosmic-workspaces..."
sudo cp target/release/cosmic-workspaces /usr/bin/cosmic-workspaces
sudo chmod +x /usr/bin/cosmic-workspaces

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "Press Super (Meta/Windows key) to test the launcher integration"
echo ""
echo "Features:"
echo "  ✓ Press Super to open workspaces with integrated launcher"
echo "  ✓ Type to search apps immediately (no clicking needed)"
echo "  ✓ Space key works in search"
echo "  ✓ Arrow keys to navigate results"
echo "  ✓ Enter to launch selected app"
echo "  ✓ Click dock items to close workspace view"
echo "  ✓ Max 10 results with dark themed background (#0c0d1f)"
echo ""
echo "To restore a backup:"
echo "  sudo cp /usr/bin/cosmic-workspaces.backupN /usr/bin/cosmic-workspaces"
echo "  (where N is the backup number you want to restore)"
echo ""
EOF

chmod +x install.sh
