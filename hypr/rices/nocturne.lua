-- rice overrides for "nocturne": dark violet, cold, glacial, Windows-like.
-- loaded by hypr/hyprland.lua after the base config, before custom.lua.
-- runs with the module globals (hl, mainMod, ROOT, terminal, RED, ...).
-- the shell lives in quickshell/nocturne/; this file is only the hypr side.

-- Icy violet frame, deep violet when idle. Re-applied here because
-- general.lua already consumed the old RED before this file loads.
RED      = "rgba(b69cffff)"
INACTIVE = "rgba(1a1130ff)"
BG       = "rgba(06040fff)"

terminal = "foot"

-- keybinds.lua froze the terminal keys to the base terminal before this
-- file loaded; point them at foot.
hl.unbind(mainMod .. " + Return")
hl.unbind(mainMod .. " + T")
hl.unbind("CTRL + ALT + T")
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T",       hl.dsp.exec_cmd(terminal))

hl.config({
    general = {
        -- Glacial breathing room: wider than nothing's dense grid.
        gaps_in   = 6,
        gaps_out  = 12,
        border_size = 2,
        col = {
            active_border   = RED,
            inactive_border = INACTIVE,
        },
        layout = "dwindle",
        snap = { enabled = true, window_gap = 8, monitor_gap = 12 },
        resize_on_border = true,
    },

    decoration = {
        -- Frosted panels want a generous, drawn corner.
        rounding       = 14,
        rounding_power = 2.0,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        -- Cold frosted glass, unlike nothing's matte.
        blur = {
            enabled    = true,
            size       = 6,
            passes     = 3,
            noise      = 0.02,
            contrast   = 1.0,
            brightness = 0.7,
            vibrancy   = 0.25,
            vibrancy_darkness = 0.1,
            popups     = true,
        },

        shadow = {
            enabled      = true,
            range        = 30,
            render_power = 3,
            color        = 0x55120a2e,
            offset       = "0 8",
        },

        -- A violet halo on the focused window.
        glow = {
            enabled        = true,
            color          = 0x55b69cff,
            color_inactive = 0x00000000,
            range          = 14,
            render_power   = 2,
        },
    },

    animations = { enabled = true },

    misc = {
        background_color = BG,
    },
})

-- Smooth glacial glide: slower, softer landing than the stock snap.
hl.curve("glacier", { type = "bezier", points = { {0.22, 1.0}, {0.42, 1.0} } })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.5, bezier = "glacier", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.6, bezier = "glacier", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.5, bezier = "glacier" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.6, bezier = "glacier" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5.0, bezier = "glacier", style = "slidefade 20%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.4, bezier = "glacier", style = "slidefade 20%" })

-- Foot, themed to nocturne, kept a touch translucent for the frosted look.
hl.window_rule({
    name  = "nocturne-foot",
    match = { class = "^(foot|footclient)$" },
    opacity = "0.95 0.88",
})

-- Launchers and dialogs float, centred, as on a classic desktop.
hl.window_rule({
    name  = "nocturne-float-dialogs",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
    center = true,
})

-- ── Windows-like window management ───────────────────────────────────
-- Alt+Tab cycles windows; Super+Up/Down maximise and restore; dwindle
-- tiling plus Hyprland snap give the edge-snap/half-tile feel.
hl.bind("ALT + Tab",          hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + Tab",  hl.dsp.window.cycle_next({ prev = true }))
hl.bind(mainMod .. " + Up",   hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + Down", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M",    hl.dsp.global("quickshell:sessionToggle"))
