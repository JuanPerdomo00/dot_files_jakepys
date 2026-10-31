#!/bin/bash

bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
colors=("#39a0ff" "#36c5f0" "#32e0d0" "#45e878" "#b5ed50" "#ffe066" "#ffad42" "#ff5c7a")

cava -p <(
    cat <<'EOF'
[general]
framerate = 30
bars = 14

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
) | while IFS= read -r line; do
    output=""

    IFS=';' read -ra values <<<"$line"

    for value in "${values[@]}"; do
        [[ "$value" =~ ^[0-7]$ ]] || continue
        output+="<span foreground='${colors[$value]}'>${bars[$value]}</span>"
    done

    printf '%s\n' "$output"
done
