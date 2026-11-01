#!/usr/bin/env bash
set -u
PAPER_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
export PAPER_DIR
export STARSHIP_SESSION_KEY=paper

height="$(hyprctl monitors -j 2>/dev/null | jq -r '[.[] | select(.focused)][0].height // 1440' 2>/dev/null)"
[[ "$height" =~ ^[0-9]+$ ]] || height=1440
size="$(awk -v h="$height" 'BEGIN { printf "%.1f", 21.7 * h / 1440 }')"

exec kitty --config "$PAPER_DIR/apps/kitty/paper.conf" \
    -o "font_size=$size" \
    -o "shell=fish --init-command 'source $PAPER_DIR/apps/fish/paper.fish'" \
    "$@"
