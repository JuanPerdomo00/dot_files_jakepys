#!/bin/bash

if ! command -v checkupdates >/dev/null 2>&1; then
    echo "checkupdates not installed (pacman-contrib)" >&2
    exit 0
fi

if ! command -v paru >/dev/null 2>&1; then
    echo "paru not installed" >&2
    exit 0
fi

OFFICIAL=$(checkupdates 2>/dev/null | wc -l)
AUR=$(paru -Qua 2>/dev/null | wc -l)

OUTPUT=""
if [ "$OFFICIAL" -gt 0 ]; then
    OUTPUT+="󰏗 $OFFICIAL"
fi
if [ "$AUR" -gt 0 ]; then
    [ -n "$OUTPUT" ] && OUTPUT+=" "
    OUTPUT+=" $AUR"
fi

echo "$OUTPUT"
