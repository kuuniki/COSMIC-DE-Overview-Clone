#!/bin/bash
set -e

echo "=================================="
echo "COSMIC Workspaces Launcher Installer"
echo "=================================="
echo ""

# Check if running COSMIC
if ! pgrep -x "cosmic-comp" > /dev/null; then
    echo "⚠️  Warning: COSMIC desktop doesn't appear to be running"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for Rust
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust is not installed. Install it from: https://rustup.rs/"
    exit 1
fi

echo "✓ Rust found"

# Backup original
echo ""
echo "📦 Backing up original cosmic-workspaces..."
if [ -f /usr/bin/cosmic-workspaces ] && [ ! -f /usr/bin/cosmic-workspaces.backup ]; then
    sudo cp /usr/bin/cosmic-workspaces /usr/bin/cosmic-workspaces.backup
    echo "✓ Backup created at /usr/bin/cosmic-workspaces.backup"
elif [ -f /usr/bin/cosmic-workspaces.backup ]; then
    echo "✓ Backup already exists"
fi

# Build
echo ""
echo "🔨 Building cosmic-workspaces with launcher integration..."
echo "   This may take a few minutes..."
cargo build --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✓ Build successful"

# Install
echo ""
echo "📥 Installing..."
sudo pkill -9 -f cosmic-workspaces 2>/dev/null || true
sudo cp target/release/cosmic-workspaces /usr/bin/cosmic-workspaces

echo ""
echo "✅ Installation complete!"
echo ""
echo "Usage:"
echo "  • Press Super+D to open workspace overview"
echo "  • Start typing immediately to search"
echo "  • Use arrow keys to navigate, Enter to launch"
echo "  • Press Escape to close"
echo ""
echo "To restore original:"
echo "  sudo cp /usr/bin/cosmic-workspaces.backup /usr/bin/cosmic-workspaces"
echo ""
echo "Enjoy! 🚀"
