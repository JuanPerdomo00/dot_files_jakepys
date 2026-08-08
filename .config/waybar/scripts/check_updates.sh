#!/bin/bash

# Check if necessary commands exist (fail gracefully with valid JSON)
if ! command -v checkupdates >/dev/null 2>&1; then
    echo '{"text": " ", "tooltip": "checkupdates is not installed\nsudo pacman -S pacman-contrib"}'
    exit 0
fi

if ! command -v paru >/dev/null 2>&1; then
    echo '{"text": " ", "tooltip": "paru is not installed"}'
    exit 0
fi

# Get official repo updates
OFFICIAL=$(checkupdates 2>/dev/null | wc -l)

# Get AUR updates
AUR=$(paru -Qua 2>/dev/null | wc -l)

# Calculate total updates
TOTAL=$((OFFICIAL + AUR))

if [ "$TOTAL" -gt 0 ]; then
    OUTPUT=""
    if [ "$OFFICIAL" -gt 0 ]; then
        OUTPUT+="󰏗 $OFFICIAL"
    fi
    if [ "$AUR" -gt 0 ]; then
        [ -n "$OUTPUT" ] && OUTPUT+=" "
        OUTPUT+="󰚰 $AUR"
    fi

    # Build JSON output for waybar
    echo "{\"text\": \"$OUTPUT\", \"tooltip\": \"Official: $OFFICIAL\\nAUR: $AUR\"}"
else
    # Empty output for waybar (no updates)
    echo '{"text": ""}'
fi
