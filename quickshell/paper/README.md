# Paper

Torn-paper rice: cream sheets, washi tape, handwriting, on a painted dusk.

    ~/.config/scripts/rice.sh set paper

Regenerate the art with `tools/gen_*.py` (needs pycairo, numpy, Pillow, fontTools).
`gen_fonts.py` also needs the upstream Gaegu and Shadows Into Light Two files as input.

## Where things live

| Path | What |
| --- | --- |
| `quickshell/paper/` | the shell, assets, kitty, fish, fastfetch and Firefox setups |
| `hypr/rices/paper.lua` | Hyprland overrides and the `paper` layout |
| `theme/paper/` | GTK colours |
| `~/.config/paper/config.json` | settings, todos, notes (edited from SUPER + I) |
| `~/.config/paper/hypr.lua` | layout and input choices, written by Settings |
| `~/.local/share/paper-rice/firefox` | Firefox profile, separate from your own |

## How the torn windows work

Hyprland draws rectangles, so each window gets a torn sheet from a bottom layer
shell surface that follows it. kitty and Firefox are transparent and sit on that
sheet. Files and Settings are shell windows that draw their own edges.

A transparent window floated over another shows the one below, since its sheet
is under every window. Tiled windows never overlap, so this only touches floats.

## Fonts

Gaegu and Shadows Into Light Two, both SIL OFL. Paper Mono is derived from Gaegu
by `tools/gen_fonts.py`, which also adds the French accents Gaegu lacks.
