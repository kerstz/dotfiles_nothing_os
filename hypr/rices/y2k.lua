-- rice overrides for "y2k": turn-of-millennium desktop. Loaded by
-- hypr/hyprland.lua after the base config, before custom.lua. Loud
-- saturated chrome, thick colourful window frames, hard square corners,
-- snappy no-float motion. The shell lives in quickshell/y2k/.

-- Palette (shared slots). The frame below uses an explicit gradient, so
-- RED is set only to keep the slot meaningful.
RED      = "rgba(ff2d9bff)"
INACTIVE = "rgba(808890ff)"
BG       = "rgba(00a2a2ff)"

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 6,
        border_size = 4,
        col = {
            -- Magenta -> electric blue -> lime chrome, 45 degrees.
            active_border   = "rgba(ff2d9bff) rgba(2d6cffff) rgba(7cff3fff) 45deg",
            inactive_border = INACTIVE,
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        -- Hard 9x corners: no rounding at all.
        rounding       = 0,
        rounding_power = 2.0,

        -- Flat and opaque, like a real CRT desktop.
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = { enabled = false },

        shadow = {
            enabled = true,
            range   = 10,
            render_power = 4,
            color   = 0xaa000000,
            offset  = "3 3",
        },

        -- A loud cyan halo on the focused window.
        glow = {
            enabled        = true,
            color          = 0x6619e0e0,
            color_inactive = 0x00000000,
            range          = 10,
            render_power   = 2,
        },
    },

    misc = {
        background_color = BG,
    },
})

-- Chunky, snappy motion with a small pop. Y2K UIs zoomed; nothing floats.
hl.curve("y2kPop",  { type = "bezier", points = { { 0.20, 1.25 }, { 0.40, 1.0 } } })
hl.curve("y2kSnap", { type = "bezier", points = { { 0.30, 1.0 },  { 0.40, 1.0 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 4.0, bezier = "y2kSnap" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.5, bezier = "y2kPop",  style = "popin 70%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 4.0, bezier = "y2kSnap", style = "popin 80%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 5.0, bezier = "y2kSnap" })
hl.animation({ leaf = "border",        enabled = true, speed = 8.0, bezier = "y2kSnap" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5.0, bezier = "y2kSnap", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5.0, bezier = "y2kSnap", style = "slide" })

-- cool-retro-term carries the CRT immersion best; fall back to a normal
-- terminal so the Return bind still opens something if it is not installed.
terminal = firstAvailable({ "cool-retro-term", "kitty", "foot", "alacritty", "ghostty", "wezterm" }, "xterm")
