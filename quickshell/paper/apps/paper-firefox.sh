#!/usr/bin/env bash
set -u
PAPER_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
PROFILE="${XDG_DATA_HOME:-$HOME/.local/share}/paper-rice/firefox"
CHROME="$PROFILE/chrome"

mkdir -p "$CHROME/img"
cp -f "$PAPER_DIR/apps/firefox/user.js" "$PROFILE/user.js"
cp -f "$PAPER_DIR/apps/firefox/chrome/"*.css "$CHROME/"
cp -f "$PAPER_DIR/assets/icons/"*.png "$CHROME/img/"
cp -f "$PAPER_DIR/assets/doodles/"*.png "$CHROME/img/"
cp -f "$PAPER_DIR/assets/paper/"tape_*.png "$PAPER_DIR/assets/paper/card_note.png" "$CHROME/img/"

height="$(hyprctl monitors -j 2>/dev/null | jq -r '[.[] | select(.focused)][0].height // 1440' 2>/dev/null)"
[[ "$height" =~ ^[0-9]+$ ]] || height=1440
unit="$(awk -v h="$height" 'BEGIN { printf "%.3f", h / 720 }')"

hour="$(date +%-H)"
if (( hour < 12 )); then greeting="Good Morning!"
elif (( hour < 18 )); then greeting="Good Afternoon!"
else greeting="Good Evening!"
fi

cat > "$CHROME/generated.css" <<CSS
:root { --pu: ${unit}px; --greeting: "${greeting}"; }
CSS

{
    printf ':root {\n'
    for name in icons/search icons/youtube icons/github icons/reddit icons/arch icons/add_circle \
        doodles/sun doodles/leaf doodles/smile doodles/town paper/tape_gray paper/tape_pink paper/card_note; do
        printf -- '--img-%s: url("data:image/png;base64,%s");\n' "${name##*/}" "$(base64 -w0 "$PAPER_DIR/assets/$name.png")"
    done
    printf '}\n'
} > "$CHROME/images.css"

exec firefox --new-instance --profile "$PROFILE" --name paper-firefox --class paper-firefox "$@"
