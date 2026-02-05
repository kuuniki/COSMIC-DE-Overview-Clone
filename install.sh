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

# Backup original if it exists and hasn't been backed up yet
if [ -f "/usr/bin/cosmic-workspaces" ] && [ ! -f "/usr/bin/cosmic-workspaces.original" ]; then
    echo "Backing up original cosmic-workspaces..."
    sudo mv /usr/bin/cosmic-workspaces /usr/bin/cosmic-workspaces.original
    echo "Original backed up to /usr/bin/cosmic-workspaces.original"
elif [ -f "/usr/bin/cosmic-workspaces.original" ]; then
    echo "Original already backed up, skipping..."
fi

# Configure Super key to open Workspaces
SHORTCUTS_CONFIG="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom"
echo "Configuring Super key to open Workspaces..."

if [ -f "$SHORTCUTS_CONFIG" ]; then
    # Backup existing config
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
echo "To restore the original cosmic-workspaces:"
echo "  sudo mv /usr/bin/cosmic-workspaces.original /usr/bin/cosmic-workspaces"
echo "  (Your shortcuts config backup is at ${SHORTCUTS_CONFIG}.backup.*)"
echo ""
EOF

chmod +x install.sh
