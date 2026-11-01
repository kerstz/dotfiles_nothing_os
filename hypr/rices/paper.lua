RED      = "rgba(e27268ff)"
INACTIVE = "rgba(c9bca6ff)"
BG       = "rgba(2c4a6eff)"

local PAPER_DIR = shellDir
local REF_W, REF_H = 890, 642

local function insets(cls)
    if cls == "org.quickshell" then
        return { top = -8, side = -8, bottom = -8 }
    end
    if cls == "paper-firefox" then
        return { top = 3, side = 3, bottom = 3 }
    end
    return { top = 34, side = 10, bottom = 8 }
end

local function role(cls)
    if cls == "kitty" then return "terminal" end
    if cls == "org.quickshell" then return "files" end
    if cls == "paper-firefox" or cls == "firefox" or cls == "chromium" then return "browser" end
    return nil
end

local SLOTS = {
    terminal = { 15, 25, 500, 317 },
    files    = { 527, 30, 361, 328 },
    browser  = { 12, 370, 740, 265 },
}

local function place(target, box, u)
    local cls = target.window and target.window.class or ""
    local i = insets(cls)
    target:place({
        x = box.x + i.side * u,
        y = box.y + i.top * u,
        w = box.w - 2 * i.side * u,
        h = box.h - (i.top + i.bottom) * u,
    })
end

local function slot(area, s)
    local sx, sy = area.w / REF_W, area.h / REF_H
    return { x = area.x + s[1] * sx, y = area.y + s[2] * sy, w = s[3] * sx, h = s[4] * sy }
end

local function trio(ctx, u)
    local used, ordered = {}, {}
    for _, name in ipairs({ "terminal", "files", "browser" }) do
        for _, t in ipairs(ctx.targets) do
            local cls = t.window and t.window.class or ""
            if not used[t] and role(cls) == name then
                used[t] = true
                ordered[name] = t
                break
            end
        end
    end
    for _, name in ipairs({ "terminal", "files", "browser" }) do
        if not ordered[name] then
            for _, t in ipairs(ctx.targets) do
                if not used[t] then
                    used[t] = true
                    ordered[name] = t
                    break
                end
            end
        end
    end
    for name, t in pairs(ordered) do
        place(t, slot(ctx.area, SLOTS[name]), u)
    end
end

if hl.layout and hl.layout.register then
    hl.layout.register("paper", {
        recalculate = function(ctx)
            local n = #ctx.targets
            if n == 0 then return end
            local a = ctx.area
            local u = a.h / REF_H
            local m, g = 14 * u, 12 * u
            local x, y, w, h = a.x + m, a.y + 26 * u, a.w - 2 * m, a.h - 34 * u

            if n == 3 then
                trio(ctx, u)
            elseif n == 1 then
                place(ctx.targets[1], { x = x, y = y, w = w, h = h }, u)
            else
                local cols = math.ceil(math.sqrt(n))
                local rows = math.ceil(n / cols)
                local cw = (w - g * (cols - 1)) / cols
                local ch = (h - g * (rows - 1)) / rows
                for i, t in ipairs(ctx.targets) do
                    local col = (i - 1) % cols
                    local row = math.floor((i - 1) / cols)
                    place(t, { x = x + col * (cw + g), y = y + row * (ch + g), w = cw, h = ch }, u)
                end
            end
        end,
        layout_msg = function()
            return false
        end,
    })
end

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
        layout = "lua:paper",
        resize_on_border = true,
        extend_border_grab_area = 12,
        col = {
            active_border = RED,
            inactive_border = INACTIVE,
        },
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = false,
        blur = { enabled = false },
        shadow = { enabled = false },
        glow = { enabled = false },
    },
    misc = {
        background_color = BG,
    },
})

hl.curve("paperEase", { type = "bezier", points = { { 0.22, 1.0 }, { 0.36, 1.0 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 2.4, bezier = "paperEase" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 2.2, bezier = "paperEase", style = "gnomed" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.8, bezier = "paperEase", style = "gnomed" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 1.4, bezier = "paperEase" })
hl.animation({ leaf = "layers",        enabled = true, speed = 2.0, bezier = "paperEase", style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.0, bezier = "paperEase", style = "fade" })

terminal = PAPER_DIR .. "/apps/paper-term.sh"
fileManager = "qs -p " .. PAPER_DIR .. " ipc call files toggle"
browser = PAPER_DIR .. "/apps/paper-firefox.sh"

for _, key in ipairs({ mainMod .. " + Return", mainMod .. " + T", "CTRL + ALT + T", mainMod .. " + E", mainMod .. " + W" }) do
    hl.unbind(key)
end

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))

hl.window_rule({
    name  = "paper-settings",
    match = { class = "^org\\.quickshell$", title = "^Paper Settings$" },
    float  = true,
    center = true,
})

local overrides = (os.getenv("HOME") or "") .. "/.config/paper/hypr.lua"
local fh = io.open(overrides)
if fh then
    fh:close()
    pcall(dofile, overrides)
end
