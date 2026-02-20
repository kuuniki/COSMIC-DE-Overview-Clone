#!/bin/bash
set -e

echo "=== Restoring original cosmic-workspaces ==="
echo ""

# Find latest backup
BACKUP_NUM=1
while [ -f "/usr/bin/cosmic-workspaces.backup$((BACKUP_NUM + 1))" ]; do
    BACKUP_NUM=$((BACKUP_NUM + 1))
done

if [ ! -f "/usr/bin/cosmic-workspaces.backup${BACKUP_NUM}" ]; then
    echo "Error: No backup found at /usr/bin/cosmic-workspaces.backup1"
    exit 1
fi

echo "Restoring from backup ${BACKUP_NUM}..."
sudo cp "/usr/bin/cosmic-workspaces.backup${BACKUP_NUM}" /usr/bin/cosmic-workspaces.new
sudo mv /usr/bin/cosmic-workspaces.new /usr/bin/cosmic-workspaces
sudo killall cosmic-workspaces 2>/dev/null || true


# Restore keyboard shortcut backup
SHORTCUTS_CONFIG="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom"
LATEST_SHORTCUT_BACKUP=""
for f in "${SHORTCUTS_CONFIG}".backup.*; do
    if [ -f "$f" ]; then
        LATEST_SHORTCUT_BACKUP="$f"
    fi
done
if [ -n "$LATEST_SHORTCUT_BACKUP" ]; then
    cp "$LATEST_SHORTCUT_BACKUP" "$SHORTCUTS_CONFIG"
    echo "Keyboard shortcuts restored from backup."
else
    echo "No shortcut backup found; you may need to reconfigure your Super key."
fi

# Restore workspace layout backup
WORKSPACE_CONFIG="$HOME/.config/cosmic/com.system76.CosmicWorkspaces.toml"
LATEST_WS_BACKUP=""
for f in "${WORKSPACE_CONFIG}".backup.*; do
    if [ -f "$f" ]; then
        LATEST_WS_BACKUP="$f"
    fi
done
if [ -n "$LATEST_WS_BACKUP" ]; then
    cp "$LATEST_WS_BACKUP" "$WORKSPACE_CONFIG"
    echo "Workspace layout restored from backup."
fi

# Remove stable binary copy
if [ -d "/usr/local/lib/cosmic-workspaces-overview" ]; then
    sudo rm -rf /usr/local/lib/cosmic-workspaces-overview
    echo "Removed cached binary."
fi
# Remove pacman hook if present
if [ -f "/etc/pacman.d/hooks/cosmic-workspaces-custom.hook" ]; then
    sudo rm /etc/pacman.d/hooks/cosmic-workspaces-custom.hook
    echo "Pacman hook removed."
fi

echo ""
echo "=== Uninstall Complete! ==="
echo "Changes restored automatically. Press Super key to test."
echo ""
