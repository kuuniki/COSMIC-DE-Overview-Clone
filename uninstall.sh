#!/bin/bash

echo "Restoring original COSMIC Workspaces..."

if [ ! -f /usr/bin/cosmic-workspaces.backup ]; then
    echo "❌ Backup not found at /usr/bin/cosmic-workspaces.backup"
    exit 1
fi

sudo pkill -9 -f cosmic-workspaces 2>/dev/null || true
sudo cp /usr/bin/cosmic-workspaces.backup /usr/bin/cosmic-workspaces

echo "✅ Original cosmic-workspaces restored!"
