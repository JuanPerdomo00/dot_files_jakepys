#!/bin/bash

bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

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
        output+="${bars[$value]}"
    done

    printf '%s\n' "$output"
done
