#!/usr/bin/env bash
set -u
PAPER_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
FONTS="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/paper-rice"
mkdir -p "$FONTS"
cp -f "$PAPER_DIR/assets/fonts/"*.ttf "$FONTS/"
command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$FONTS" >/dev/null 2>&1
exit 0
