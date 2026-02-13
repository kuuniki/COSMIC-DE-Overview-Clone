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

# Remove pacman hook
if [ -f "/etc/pacman.d/hooks/cosmic-workspaces-custom.hook" ]; then
    sudo rm /etc/pacman.d/hooks/cosmic-workspaces-custom.hook
    echo "Pacman hook removed."
fi

echo ""
echo "=== Uninstall Complete! ==="
echo "Changes restored automatically. Press Super key to test."
echo ""
