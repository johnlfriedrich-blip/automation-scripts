#!/bin/bash
echo "WSL Sync Check - $(date)"
onedrive_status=$(grep -i "up to date" /mnt/c/Users/JohnFriedrich/AppData/Local/Microsoft/OneDrive/logs/Business1/* | tail -1)

if [[ -n "$onedrive_status" ]]; then
    echo "OneDrive appears synced."
else
    echo "Sync status unclear or outdated."
fi