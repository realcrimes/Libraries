-- // leak it and i  will cut ur  throat :)
if not game:IsLoaded() then game.Loaded:Wait() end

if getgenv().Nebula and typeof(getgenv().Nebula.destroy) == "function" then
    pcall(function() getgenv().Nebula:destroy() end)
    task.wait(0.05)
end

local players      = game:GetService("Players")
local uis          = cloneref(game:GetService("UserInputService"))
local ws           = cloneref(game:GetService("Workspace"))
local http_service = cloneref(game:GetService("HttpService"))
local gui_service  = cloneref(game:GetService("GuiService"))
local coregui      = cloneref(game:GetService("CoreGui"))
local tween_svc    = cloneref(game:GetService("TweenService"))
local run_service  = cloneref(game:GetService("RunService"))
local text_service = game:GetService("TextService")

local vec2   = Vector2.new
local dim2   = UDim2.new
local dim    = UDim.new
local rgb    = Color3.fromRGB
local hex    = Color3.fromHex

local camera     = ws.CurrentCamera
local lp         = players.LocalPlayer
local gui_offset = gui_service:GetGuiInset().Y

local floor, clamp, random = math.floor, math.clamp, math.random
local insert, find, remove, concat = table.insert, table.find, table.remove, table.concat

local theme = {
    bg_dark    = rgb(8,   8,   14),  bg_mid     = rgb(12,  12,  20),
    bg_light   = rgb(18,  18,  28),  bg_element = rgb(10,  10,  16),
    accent     = rgb(90,  90,  200), accent_dim = rgb(50,  50,  120),
    border     = rgb(30,  30,  50),  text_main  = rgb(200, 200, 220),
    text_dim   = rgb(110, 110, 140), text_accent= rgb(140, 140, 240),
}

local theme_presets = {
    Nebula = { bg_dark = rgb(18,18,24), bg_mid = rgb(24,24,32), bg_light = rgb(30,30,40),
        bg_element = rgb(22,22,30), accent = rgb(130,90,180), accent_dim = rgb(80,55,110),
        border = rgb(45,45,60), text_main = rgb(210,210,220), text_dim = rgb(120,120,140),
        text_accent = rgb(160,120,210) },
    Azure = { bg_dark = rgb(14,20,32), bg_mid = rgb(20,28,44), bg_light = rgb(28,38,58),
        bg_element = rgb(18,26,40), accent = rgb(60,140,240), accent_dim = rgb(35,85,150),
        border = rgb(40,55,85), text_main = rgb(210,220,235), text_dim = rgb(120,140,170),
        text_accent = rgb(100,170,255) },
    Crimson = { bg_dark = rgb(22,12,14), bg_mid = rgb(30,16,20), bg_light = rgb(40,22,26),
        bg_element = rgb(26,14,18), accent = rgb(220,50,70), accent_dim = rgb(130,30,45),
        border = rgb(60,30,38), text_main = rgb(230,210,215), text_dim = rgb(150,120,130),
        text_accent = rgb(255,90,110) },
    Emerald = { bg_dark = rgb(12,22,18), bg_mid = rgb(16,30,24), bg_light = rgb(22,40,32),
        bg_element = rgb(14,26,20), accent = rgb(50,200,120), accent_dim = rgb(30,120,70),
        border = rgb(30,60,48), text_main = rgb(210,230,220), text_dim = rgb(120,150,135),
        text_accent = rgb(80,230,150) },
    Monochrome = { bg_dark = rgb(14,14,14), bg_mid = rgb(20,20,20), bg_light = rgb(28,28,28),
        bg_element = rgb(18,18,18), accent = rgb(230,230,230), accent_dim = rgb(120,120,120),
        border = rgb(50,50,50), text_main = rgb(220,220,220), text_dim = rgb(130,130,130),
        text_accent = rgb(255,255,255) },
    Midnight = { bg_dark = rgb(8,8,14), bg_mid = rgb(12,12,20), bg_light = rgb(18,18,28),
        bg_element = rgb(10,10,16), accent = rgb(90,90,200), accent_dim = rgb(50,50,120),
        border = rgb(30,30,50), text_main = rgb(200,200,220), text_dim = rgb(110,110,140),
        text_accent = rgb(140,140,240) },
    Sunset = { bg_dark = rgb(26,16,20), bg_mid = rgb(34,20,26), bg_light = rgb(46,28,34),
        bg_element = rgb(30,18,24), accent = rgb(255,120,70), accent_dim = rgb(160,70,40),
        border = rgb(70,40,45), text_main = rgb(240,220,215), text_dim = rgb(160,130,125),
        text_accent = rgb(255,150,100) },
    Ocean = { bg_dark = rgb(10,20,28), bg_mid = rgb(14,26,36), bg_light = rgb(20,36,50),
        bg_element = rgb(12,22,32), accent = rgb(0,180,200), accent_dim = rgb(0,100,115),
        border = rgb(28,52,68), text_main = rgb(205,225,235), text_dim = rgb(115,145,165),
        text_accent = rgb(70,220,240) },
    Rose = { bg_dark = rgb(24,14,20), bg_mid = rgb(32,18,26), bg_light = rgb(44,26,36),
        bg_element = rgb(28,16,24), accent = rgb(240,90,160), accent_dim = rgb(140,50,95),
        border = rgb(64,34,48), text_main = rgb(235,215,225), text_dim = rgb(155,125,140),
        text_accent = rgb(255,130,190) },
    Forest = { bg_dark = rgb(14,20,12), bg_mid = rgb(20,28,16), bg_light = rgb(28,38,22),
        bg_element = rgb(16,24,14), accent = rgb(120,180,70), accent_dim = rgb(70,105,40),
        border = rgb(40,55,32), text_main = rgb(215,225,205), text_dim = rgb(130,145,120),
        text_accent = rgb(150,210,100) },
}

local theme_preset_names = {}
for k in next, theme_presets do insert(theme_preset_names, k) end
table.sort(theme_preset_names)

local theme_registry = {}
for k in next, theme do theme_registry[k] = {} end

local theme_change_callbacks = {}
local reposition_callbacks   = {}

local function register(obj, prop, key)
    if not theme_registry[key] then theme_registry[key] = {} end
    insert(theme_registry[key], {obj, prop})
    pcall(function() obj[prop] = theme[key] end)
end

local function set_theme_color(key, color)
    theme[key] = color
    if theme_registry[key] then
        for _, pair in ipairs(theme_registry[key]) do
            pcall(function() pair[1][pair[2]] = color end)
        end
    end
    for _, cb in ipairs(theme_change_callbacks) do pcall(cb, key, color) end
end

local current_theme = "Midnight"

local function apply_theme_preset(name)
    local preset = theme_presets[name]
    if not preset then return end
    current_theme = name
    for key, color in next, preset do set_theme_color(key, color) end
end

local nebula = {
    flags = {}, config_flags = {}, visible_flags = {}, connections = {}, notifications = {},
    directory = "nebula", current_tab = nil, current_element_open = nil,
    default_toggle_key = Enum.KeyCode.RightAlt,
    _theme = theme, _set_theme_color = set_theme_color,
    _theme_presets = theme_presets, _theme_preset_names = theme_preset_names,
    theme_change_callbacks = theme_change_callbacks, reposition_callbacks = reposition_callbacks,
    _shells = {},
    _keybind_entries = {},
    _watermark = nil,
    _keybind_list = nil,
    _keybind_list_visible = true,
    _theme_dropdown = nil,
    _current_theme = "Midnight",
}
nebula.__index = nebula

function nebula:set_theme(name)
    apply_theme_preset(name)
    nebula._current_theme = current_theme
    if nebula._theme_dropdown then
        pcall(function() nebula._theme_dropdown.set(name) end)
    end
end

function nebula:_apply_theme(name)
    nebula:set_theme(name)
end

local flags        = nebula.flags
local config_flags = nebula.config_flags

pcall(function()
    for _, p in ipairs({"", "/configs"}) do
        local full = nebula.directory .. p
        if not isfolder(full) then makefolder(full) end
    end
end)

local function conn(sig, cb)
    local c = sig:Connect(cb)
    insert(nebula.connections, c)
    return c
end

local function tw(obj, props, t)
    tween_svc:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function mk(cls, props)
    local i = Instance.new(cls)
    for k, v in next, props do i[k] = v end
    return i
end

local function parent_gui(gui)
    local ok = pcall(function()
        if get_hidden_gui or gethui then gui.Parent = (get_hidden_gui or gethui)()
        elseif syn and syn.protect_gui then syn.protect_gui(gui); gui.Parent = coregui
        else gui.Parent = coregui end
    end)
    if not ok then gui.Parent = lp:WaitForChild("PlayerGui") end
end

local function is_inside_any_shell(mx, my)
    for _, sh in ipairs(nebula._shells) do
        if sh.Parent and sh.Parent.Parent then
            local ab = sh.AbsolutePosition
            local sz = sh.AbsoluteSize
            if mx >= ab.X and mx <= ab.X + sz.X and my >= ab.Y and my <= ab.Y + sz.Y then
                return true
            end
        end
    end
    return false
end

local function draggify(frame, handle)
    handle = handle or frame
    local drag, start, spos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; spos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    conn(uis.InputChanged, function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local vx, vy = camera.ViewportSize.X, camera.ViewportSize.Y
            frame.Position = dim2(0,
                clamp(spos.X.Offset + (i.Position.X - start.X), 0, vx - frame.AbsoluteSize.X),
                0,
                clamp(spos.Y.Offset + (i.Position.Y - start.Y), 0, vy - frame.AbsoluteSize.Y)
            )
        end
    end)
end

local popup_root = mk("ScreenGui", { Name = "NebulaPopups", IgnoreGuiInset = true, DisplayOrder = 999, ResetOnSpawn = false })
parent_gui(popup_root)

local notif_gui = mk("ScreenGui", { Name = "NebulaNotifs", IgnoreGuiInset = true, DisplayOrder = 998, ResetOnSpawn = false })
parent_gui(notif_gui)

local overlay_gui = mk("ScreenGui", { Name = "NebulaOverlay", IgnoreGuiInset = true, DisplayOrder = 950, ResetOnSpawn = false })
parent_gui(overlay_gui)

conn(run_service.RenderStepped, function()
    for _, fn in ipairs(reposition_callbacks) do pcall(fn) end
end)

function nebula:notify(text, duration)
    duration = duration or 4
    local slot = #nebula.notifications + 1
    local wrap = mk("Frame", {
        Parent = notif_gui, BackgroundColor3 = theme.bg_mid, BorderSizePixel = 0,
        Position = dim2(0, 12, 0, 60 + (slot-1)*32), Size = dim2(0, 220, 0, 26), BackgroundTransparency = 1,
    })
    mk("UICorner", { Parent = wrap, CornerRadius = dim(0,4) })
    local wrap_stroke = mk("UIStroke", { Parent = wrap, Color = theme.accent_dim, Thickness = 1, Transparency = 1 })
    register(wrap, "BackgroundColor3", "bg_mid")
    register(wrap_stroke, "Color", "accent_dim")

    local bar = mk("Frame", { Parent = wrap, BackgroundColor3 = theme.accent, BorderSizePixel = 0,
        Size = dim2(0, 3, 1, 0), BackgroundTransparency = 1 })
    register(bar, "BackgroundColor3", "accent")

    local lbl = mk("TextLabel", {
        Parent = wrap, BackgroundTransparency = 1, Position = dim2(0, 10, 0, 0), Size = dim2(1, -14, 1, 0),
        Font = Enum.Font.GothamMedium, Text = text, TextColor3 = theme.text_main, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1,
    })
    register(lbl, "TextColor3", "text_main")

    nebula.notifications[slot] = wrap
    tw(wrap, { BackgroundTransparency = 0 }, 0.3)
    tw(wrap_stroke, { Transparency = 0 }, 0.3)
    tw(bar, { BackgroundTransparency = 0 }, 0.3)
    tw(lbl,  { TextTransparency = 0 }, 0.3)

    task.delay(duration, function()
        nebula.notifications[slot] = nil
        tw(wrap, { BackgroundTransparency = 1, Position = dim2(0, -12, 0, wrap.Position.Y.Offset) }, 0.25)
        tw(wrap_stroke, { Transparency = 1 }, 0.25)
        tw(bar, { BackgroundTransparency = 1 }, 0.25)
        tw(lbl, { TextTransparency = 1 }, 0.25)
        task.wait(0.3)
        wrap:Destroy()
    end)
end

function nebula:watermark(opts)
    opts = opts or {}
    if nebula._watermark then return nebula._watermark end

    local cfg = {
        brand     = opts.brand or "wtf nebula.cc",
        version   = opts.version or "Private",
        date      = opts.date or "Sep 15 2026",
        show_time = opts.show_time ~= false,
    }

    local frame = mk("Frame", {
        Parent = overlay_gui,
        BackgroundColor3 = theme.bg_mid,
        BorderSizePixel = 0,
        Position = dim2(0, 12, 0, 50),
        Size = dim2(0, 400, 0, 24),
        ClipsDescendants = false,
        ZIndex = 1000,
    })
    mk("UICorner", { Parent = frame, CornerRadius = dim(0,4) })
    local stroke = mk("UIStroke", { Parent = frame, Color = theme.accent_dim, Thickness = 1 })
    register(frame, "BackgroundColor3", "bg_mid")
    register(stroke, "Color", "accent_dim")

    local lbl = mk("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = dim2(0, 10, 0, 0),
        Size = dim2(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextSize = 12,
        TextColor3 = theme.text_accent,
        TextTransparency = 0,
        TextStrokeTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 1001,
    })
    register(lbl, "TextColor3", "text_accent")

    local function refresh()
        local parts = {}
        if cfg.brand and cfg.brand ~= "" then insert(parts, cfg.brand) end
        if cfg.version and cfg.version ~= "" then insert(parts, cfg.version) end
        if cfg.date and cfg.date ~= "" then insert(parts, cfg.date) end
        if cfg.show_time then
            local t = os.time()
            local h = floor(t / 3600) % 24
            local m = floor(t / 60) % 60
            local s = floor(t) % 60
            insert(parts, string.format("%02d:%02d:%02d", h, m, s))
        end
        lbl.Text = concat(parts, "  -  ")
        local bounds = text_service:GetTextSize(lbl.Text, lbl.TextSize, lbl.Font, Vector2.new(1000, 24))
        frame.Size = dim2(0, bounds.X + 20, 0, 24)
    end

    nebula._watermark = { frame = frame, label = lbl, cfg = cfg, refresh = refresh }

    draggify(frame)

    refresh()
    task.spawn(function()
        while lbl.Parent do
            refresh()
            task.wait(1)
        end
    end)

    return nebula._watermark
end

function nebula:watermark_set(key, value)
    local wm = nebula._watermark
    if not wm then return end
    wm.cfg[key] = value
    wm.refresh()
end

function nebula:keybind_list(opts)
    opts = opts or {}
    if nebula._keybind_list then return nebula._keybind_list end

    local C = {
        WIDTH    = 220,
        HEADER_H = 24,
        LINE_H   = 1,
        PAD_TOP  = 6,
        PAD_BOT  = 8,
        PAD_L    = 8,
        PAD_R    = 8,
        ROW_H    = 16,
        ROW_GAP  = 4,
        MARGIN   = 12,
        OFFSET_Y = 200,
    }

    local frame = mk("Frame", {
        Parent = overlay_gui,
        BackgroundColor3 = theme.bg_mid,
        BorderSizePixel = 0,
        Position = dim2(0, C.MARGIN, 0, C.OFFSET_Y),
        Size = dim2(0, C.WIDTH, 0, C.HEADER_H + C.LINE_H + C.PAD_TOP + C.ROW_H + C.PAD_BOT),
        ClipsDescendants = false,
        ZIndex = 1000,
        Visible = opts.visible ~= false,
    })
    mk("UICorner", { Parent = frame, CornerRadius = dim(0,4) })
    local stroke = mk("UIStroke", { Parent = frame, Color = theme.border, Thickness = 1 })
    register(frame, "BackgroundColor3", "bg_mid")
    register(stroke, "Color", "border")

    local header = mk("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.bg_light,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 0),
        Size = dim2(1, 0, 0, C.HEADER_H),
        ZIndex = 1001,
    })
    mk("UICorner", { Parent = header, CornerRadius = dim(0,4) })
    mk("Frame", {
        Parent = header, BackgroundColor3 = theme.bg_light, BorderSizePixel = 0,
        Position = dim2(0, 0, 0.5, 0), Size = dim2(1, 0, 0.5, 0), ZIndex = 1001,
    })
    register(header, "BackgroundColor3", "bg_light")

    draggify(frame, header)

    local header_lbl = mk("TextLabel", {
        Parent = header,
        BackgroundTransparency = 1,
        Position = dim2(0, 10, 0, 0),
        Size = dim2(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Keybinds",
        TextSize = 12,
        TextColor3 = theme.text_accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1002,
    })
    register(header_lbl, "TextColor3", "text_accent")

    local accent_line = mk("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.accent,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, C.HEADER_H),
        Size = dim2(1, 0, 0, C.LINE_H),
        ZIndex = 1001,
    })
    register(accent_line, "BackgroundColor3", "accent")

    local body = mk("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, C.HEADER_H + C.LINE_H),
        Size = dim2(1, 0, 0, C.PAD_TOP + C.ROW_H + C.PAD_BOT),
        ZIndex = 1001,
    })

    local empty_lbl = mk("TextLabel", {
        Parent = body,
        BackgroundTransparency = 1,
        Position = dim2(0, C.PAD_L, 0, C.PAD_TOP),
        Size = dim2(1, -C.PAD_L - C.PAD_R, 0, C.ROW_H),
        Font = Enum.Font.Gotham,
        Text = "no keybinds",
        TextSize = 11,
        TextColor3 = theme.text_dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1002,
    })
    register(empty_lbl, "TextColor3", "text_dim")

    nebula._keybind_list = {
        frame = frame, header = header, body = body, empty_lbl = empty_lbl,
        entries = {}, visible = opts.visible ~= false, consts = C,
    }

    nebula:_rebuild_keybind_list()
    return nebula._keybind_list
end

function nebula:keybind_list_set_visible(v)
    local kl = nebula._keybind_list
    if not kl then return end
    kl.visible = v ~= false
    kl.frame.Visible = kl.visible
end

function nebula:_rebuild_keybind_list()
    local kl = nebula._keybind_list
    if not kl then return end
    local C = kl.consts

    for _, row in ipairs(kl.entries) do
        if row and row.Parent then row:Destroy() end
    end
    kl.entries = {}

    local shown = 0
    for _, entry in ipairs(nebula._keybind_entries) do
        local y = C.PAD_TOP + shown * (C.ROW_H + C.ROW_GAP)
        local row = mk("Frame", {
            Parent = kl.body,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = dim2(0, C.PAD_L, 0, y),
            Size = dim2(1, -C.PAD_L - C.PAD_R, 0, C.ROW_H),
            ZIndex = 1002,
        })

        local name_lbl = mk("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, 0),
            Size = dim2(0.6, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = entry.name or "keybind",
            TextSize = 11,
            TextColor3 = theme.text_main,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 1003,
        })
        register(name_lbl, "TextColor3", "text_main")

        local current_key = entry.key
        local key_text
        if current_key and typeof(current_key) == "EnumItem" and current_key ~= Enum.KeyCode.Unknown then
            key_text = "[" .. string.lower(current_key.Name) .. "]"
        else
            key_text = "[none]"
        end

        local key_lbl = mk("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = dim2(0.6, 0, 0, 0),
            Size = dim2(0.4, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = key_text,
            TextSize = 11,
            TextColor3 = theme.text_accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 1003,
        })
        register(key_lbl, "TextColor3", "text_accent")

        entry._kl_key_lbl = key_lbl

        insert(kl.entries, row)
        shown = shown + 1
    end

    kl.empty_lbl.Visible = (shown == 0)

    local body_h
    if shown == 0 then
        body_h = C.PAD_TOP + C.ROW_H + C.PAD_BOT
    else
        body_h = C.PAD_TOP + shown * C.ROW_H + math.max(0, shown - 1) * C.ROW_GAP + C.PAD_BOT
    end

    kl.body.Size  = dim2(1, 0, 0, body_h)
    kl.frame.Size = dim2(0, C.WIDTH, 0, C.HEADER_H + C.LINE_H + body_h)
end

function nebula:window(opts)
    opts = opts or {}
    local win = {}
    local root_gui = mk("ScreenGui", {
        Name = "Nebula_" .. (opts.name or "UI"),
        DisplayOrder = 10,
        ResetOnSpawn = false,
    })
    parent_gui(root_gui)

    local shell = mk("Frame", {
        Parent = root_gui,
        BackgroundColor3 = theme.bg_dark,
        BorderSizePixel = 0,
        Position = dim2(0, camera.ViewportSize.X/2 - 310, 0, camera.ViewportSize.Y/2 - 270),
        Size = dim2(0, 620, 0, 540),
        ClipsDescendants = false,
    })
    mk("UICorner", { Parent = shell, CornerRadius = dim(0,6) })
    local shell_stroke = mk("UIStroke", { Parent = shell, Color = theme.border, Thickness = 1 })
    register(shell, "BackgroundColor3", "bg_dark")
    register(shell_stroke, "Color", "border")

    insert(nebula._shells, shell)

    local titlebar = mk("Frame", {
        Parent = shell,
        BackgroundColor3 = theme.bg_dark,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, 28),
    })
    mk("UICorner", { Parent = titlebar, CornerRadius = dim(0,6) })
    mk("Frame", {
        Parent = titlebar,
        BackgroundColor3 = theme.bg_dark,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0.5, 0),
        Size = dim2(1, 0, 0.5, 0),
    })
    register(titlebar, "BackgroundColor3", "bg_dark")

    local title_lbl = mk("TextLabel", {
        Parent = titlebar,
        BackgroundTransparency = 1,
        Position = dim2(0, 10, 0, 0),
        Size = dim2(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = opts.name or "nebula",
        TextColor3 = theme.text_main,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    register(title_lbl, "TextColor3", "text_main")

    if opts.version then
        mk("TextLabel", {
            Parent = titlebar,
            BackgroundTransparency = 1,
            Position = dim2(1, -90, 0, 0),
            Size = dim2(0, 80, 1, 0),
            Font = Enum.Font.Gotham,
            Text = opts.version,
            TextColor3 = theme.text_dim,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
    end

    mk("Frame", {
        Parent = shell,
        BackgroundColor3 = theme.border,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 28),
        Size = dim2(1, 0, 0, 1),
    })

    local tabbar_clip = mk("Frame", {
        Parent = shell,
        BackgroundColor3 = theme.bg_dark,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 29),
        Size = dim2(1, 0, 0, 28),
        ClipsDescendants = true,
    })
    register(tabbar_clip, "BackgroundColor3", "bg_dark")

    local tabbar = mk("ScrollingFrame", {
        Parent = tabbar_clip,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 0),
        Size = dim2(1, 0, 1, 0),
        CanvasSize = dim2(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ElasticBehavior = Enum.ElasticBehavior.Never,
    })

    mk("UIListLayout", {
        Parent = tabbar,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = dim(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    mk("UIPadding", {
        Parent = tabbar,
        PaddingLeft = dim(0, 6),
        PaddingTop = dim(0, 4),
        PaddingBottom = dim(0, 4),
    })

    local SCROLL_STEP = 80

    tabbar_clip.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then

            local canvas_w = tabbar.AbsoluteCanvasSize.X
            local frame_w  = tabbar.AbsoluteSize.X
            local max_x    = math.max(0, canvas_w - frame_w)
            local new_x    = clamp(
                tabbar.CanvasPosition.X - input.Position.Z * SCROLL_STEP,
                0, max_x
            )

            tween_svc:Create(
                tabbar,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { CanvasPosition = Vector2.new(new_x, 0) }
            ):Play()
        end
    end)

    mk("Frame", {
        Parent = shell,
        BackgroundColor3 = theme.border,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 57),
        Size = dim2(1, 0, 0, 1),
    })

    local content = mk("Frame", {
        Parent = shell,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 0, 58),
        Size = dim2(1, 0, 1, -58),
        ClipsDescendants = true,
    })

    draggify(shell, titlebar)

    win._toggle_key = opts.toggle_key or nebula.default_toggle_key
    conn(uis.InputBegan, function(input, gp)
        if input.KeyCode == win._toggle_key then
            root_gui.Enabled = not root_gui.Enabled
        end
    end)

    win._root    = root_gui
    win._shell   = shell
    win._tabbar  = tabbar
    win._content = content
    win._tabs    = {}

    function win:set_visible(bool) root_gui.Enabled = bool end
    return setmetatable(win, nebula)
end

function nebula:tab(opts)
    opts = opts or {}
    local tab = { _parent_win = self }
    local btn = mk("TextButton", {
        Parent = self._tabbar,
        AutoButtonColor = false,
        BackgroundColor3 = theme.bg_dark,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Size = dim2(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = opts.name or "Tab",
        TextColor3 = theme.text_dim,
        TextSize = 12,
    })
    mk("UIPadding", { Parent = btn, PaddingLeft = dim(0,12), PaddingRight = dim(0,12) })
    mk("UICorner",  { Parent = btn, CornerRadius = dim(0,4) })

    local indicator = mk("Frame", {
        Parent = btn,
        BackgroundColor3 = theme.accent,
        BorderSizePixel = 0,
        Position = dim2(0, 0, 1, -2),
        Size = dim2(1, 0, 0, 2),
        Visible = false,
    })
    mk("UICorner", { Parent = indicator, CornerRadius = dim(0,2) })
    register(indicator, "BackgroundColor3", "accent")

    local container = mk("Frame", {
        Parent = self._content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 1, 0),
        Visible = false,
    })
    mk("UIPadding", {
        Parent = container,
        PaddingTop = dim(0,8), PaddingBottom = dim(0,8),
        PaddingLeft = dim(0,8), PaddingRight = dim(0,8),
    })
    mk("UIListLayout", {
        Parent = container,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = dim(0,8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    tab._btn, tab._indicator, tab._container = btn, indicator, container

    local function scroll_to_btn()
        local tabbar = self._tabbar
        if not tabbar then return end
        local canvas_w = tabbar.AbsoluteCanvasSize.X
        local frame_w  = tabbar.AbsoluteSize.X
        local max_x    = math.max(0, canvas_w - frame_w)
        if max_x <= 0 then return end
        local btn_x    = btn.AbsolutePosition.X - tabbar.AbsolutePosition.X + tabbar.CanvasPosition.X
        local btn_w    = btn.AbsoluteSize.X
        local cur_pos  = tabbar.CanvasPosition.X
        local target_x = cur_pos
        if btn_x < cur_pos then
            target_x = btn_x - 6
        elseif btn_x + btn_w > cur_pos + frame_w then
            target_x = btn_x + btn_w - frame_w + 6
        end
        target_x = clamp(target_x, 0, max_x)
        tween_svc:Create(
            tabbar,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { CanvasPosition = Vector2.new(target_x, 0) }
        ):Play()
    end

    function tab:select()
        if nebula.current_tab and nebula.current_tab ~= tab then
            nebula.current_tab._btn.TextColor3        = theme.text_dim
            nebula.current_tab._btn.BackgroundColor3  = theme.bg_dark
            nebula.current_tab._indicator.Visible     = false
            nebula.current_tab._container.Visible     = false
        end
        nebula.current_tab           = tab
        btn.TextColor3               = theme.text_accent
        btn.BackgroundColor3         = theme.bg_light
        indicator.Visible            = true
        container.Visible            = true
        task.defer(scroll_to_btn)
    end

    insert(theme_change_callbacks, function()
        if nebula.current_tab == tab then
            btn.TextColor3 = theme.text_accent
            btn.BackgroundColor3 = theme.bg_light
        else
            btn.TextColor3 = theme.text_dim
            btn.BackgroundColor3 = theme.bg_dark
        end
    end)

    btn.MouseButton1Click:Connect(function() tab:select() end)
    insert(self._tabs, tab)
    if #self._tabs == 1 then tab:select() end
    return setmetatable(tab, nebula)
end

function nebula:column()
    local col = {}
    local frame = mk("Frame", { Parent = self._container, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(0.5,-4,1,0) })
    local scroll = mk("ScrollingFrame", {
        Parent = frame, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = dim2(1,0,1,0), CanvasSize = dim2(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.accent_dim,
    })
    register(scroll, "ScrollBarImageColor3", "accent_dim")
    mk("UIListLayout", { Parent = scroll, Padding = dim(0,6), SortOrder = Enum.SortOrder.LayoutOrder })
    col.holder = scroll
    return setmetatable(col, nebula)
end

function nebula:section(opts)
    opts = opts or {}
    local sec = {}
    local outer = mk("Frame", { Parent = self.holder, BackgroundColor3 = theme.bg_mid,
        BorderSizePixel = 0, Size = dim2(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y })
    mk("UICorner", { Parent = outer, CornerRadius = dim(0,4) })
    local outer_stroke = mk("UIStroke", { Parent = outer, Color = theme.border, Thickness = 1 })
    register(outer, "BackgroundColor3", "bg_mid")
    register(outer_stroke, "Color", "border")

    local header = mk("Frame", { Parent = outer, BackgroundColor3 = theme.bg_light,
        BorderSizePixel = 0, Size = dim2(1,0,0,26) })
    mk("UICorner", { Parent = header, CornerRadius = dim(0,4) })
    mk("Frame", { Parent = header, BackgroundColor3 = theme.bg_light, BorderSizePixel = 0,
        Position = dim2(0,0,0.5,0), Size = dim2(1,0,0.5,0) })
    register(header, "BackgroundColor3", "bg_light")

    local sec_title = mk("TextLabel", {
        Parent = header, BackgroundTransparency = 1, Position = dim2(0,10,0,0),
        Size = dim2(1,-10,1,0), Font = Enum.Font.GothamBold, Text = opts.name or "section",
        TextColor3 = theme.text_accent, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    })
    register(sec_title, "TextColor3", "text_accent")

    local accent_line = mk("Frame", { Parent = outer, BackgroundColor3 = theme.accent,
        BorderSizePixel = 0, Position = dim2(0,0,0,26), Size = dim2(1,0,0,1) })
    register(accent_line, "BackgroundColor3", "accent")

    local body = mk("Frame", { Parent = outer, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = dim2(0,0,0,27), Size = dim2(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y })
    mk("UIPadding", { Parent = body, PaddingTop = dim(0,6), PaddingBottom = dim(0,8),
        PaddingLeft = dim(0,8), PaddingRight = dim(0,8) })
    mk("UIListLayout", { Parent = body, Padding = dim(0,5), SortOrder = Enum.SortOrder.LayoutOrder })
    sec.holder = body
    return setmetatable(sec, nebula)
end

function nebula:toggle(opts)
    opts = opts or {}
    local cfg = { flag = opts.flag or tostring(random(1,99999)), name = opts.name or "Toggle",
        enabled = opts.default or false, callback = opts.callback or function() end,
        visible = opts.visible ~= false }
    local row = mk("Frame", { Parent = self.holder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,0,18) })
    local box = mk("Frame", { Parent = row, BackgroundColor3 = theme.bg_element,
        BorderSizePixel = 0, Position = dim2(0,0,0.5,-6), Size = dim2(0,12,0,12) })
    mk("UICorner", { Parent = box, CornerRadius = dim(0,2) })
    local box_stroke = mk("UIStroke", { Parent = box, Color = theme.border, Thickness = 1 })
    register(box_stroke, "Color", "border")

    local check = mk("Frame", { Parent = box, BackgroundColor3 = theme.accent,
        BorderSizePixel = 0, Position = dim2(0,2,0,2), Size = dim2(0,8,0,8), Visible = cfg.enabled })
    mk("UICorner", { Parent = check, CornerRadius = dim(0,1) })
    register(check, "BackgroundColor3", "accent")

    local lbl = mk("TextLabel", { Parent = row, BackgroundTransparency = 1,
        Position = dim2(0,18,0,0), Size = dim2(1,-18,1,0), Font = Enum.Font.Gotham,
        Text = cfg.name, TextColor3 = theme.text_main, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left })
    local btn = mk("TextButton", { Parent = row, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,1,0), Text = "" })

    function cfg.set(bool)
        cfg.enabled = bool; check.Visible = bool
        lbl.TextColor3 = bool and theme.text_accent or theme.text_main
        flags[cfg.flag] = bool; cfg.callback(bool)
    end
    function cfg.set_element_visible(b) row.Visible = b end
    insert(theme_change_callbacks, function()
        lbl.TextColor3 = cfg.enabled and theme.text_accent or theme.text_main
    end)
    btn.MouseButton1Click:Connect(function() cfg.set(not cfg.enabled) end)
    cfg.set(cfg.enabled); cfg.set_element_visible(cfg.visible)
    config_flags[cfg.flag] = cfg.set
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible
    return setmetatable(cfg, nebula)
end

function nebula:slider(opts)
    opts = opts or {}
    local cfg = { flag = opts.flag or tostring(random(1,99999)), name = opts.name,
        min = opts.min or 0, max = opts.max or 100, interval = opts.interval or 1,
        suffix = opts.suffix or "", default = opts.default or opts.min or 0,
        value = opts.default or opts.min or 0, callback = opts.callback or function() end,
        visible = opts.visible ~= false, dragging = false }
    local total_h = cfg.name and 30 or 16
    local wrap = mk("Frame", { Parent = self.holder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,0,total_h) })
    if cfg.name then
        mk("TextLabel", { Parent = wrap, BackgroundTransparency = 1, Position = dim2(0,0,0,0),
            Size = dim2(1,0,0,14), Font = Enum.Font.Gotham, Text = cfg.name,
            TextColor3 = theme.text_dim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
    end
    local ty = cfg.name and 16 or 2
    local track = mk("Frame", { Parent = wrap, BackgroundColor3 = theme.bg_element,
        BorderSizePixel = 0, Position = dim2(0,0,0,ty), Size = dim2(1,0,0,12) })
    mk("UICorner", { Parent = track, CornerRadius = dim(0,3) })
    local track_stroke = mk("UIStroke", { Parent = track, Color = theme.border, Thickness = 1 })
    register(track_stroke, "Color", "border")

    local fill = mk("Frame", { Parent = track, BackgroundColor3 = theme.accent,
        BorderSizePixel = 0, Size = dim2(0,0,1,0) })
    mk("UICorner", { Parent = fill, CornerRadius = dim(0,3) })
    register(fill, "BackgroundColor3", "accent")

    local val_lbl = mk("TextLabel", { Parent = track, BackgroundTransparency = 1,
        Size = dim2(1,0,1,0), Font = Enum.Font.Gotham, Text = "",
        TextColor3 = theme.text_main, TextSize = 10 })
    register(val_lbl, "TextColor3", "text_main")
    local drag_btn = mk("TextButton", { Parent = track, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,1,0), Text = "", ZIndex = 5 })

    local function ri(n)
        local m = 1/cfg.interval
        return floor(n*m+0.5)/m
    end
    function cfg.set(val)
        cfg.value = clamp(ri(val), cfg.min, cfg.max)
        fill.Size = dim2((cfg.value-cfg.min)/(cfg.max-cfg.min), 0, 1, 0)
        val_lbl.Text = tostring(cfg.value) .. cfg.suffix
        flags[cfg.flag] = cfg.value; cfg.callback(cfg.value)
    end
    function cfg.set_element_visible(b) wrap.Visible = b end
    drag_btn.MouseButton1Down:Connect(function() cfg.dragging = true end)
    conn(uis.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then cfg.dragging = false end
    end)
    conn(uis.InputChanged, function(i)
        if cfg.dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
            cfg.set(cfg.min + (cfg.max-cfg.min)*pct)
        end
    end)
    cfg.set(cfg.default); cfg.set_element_visible(cfg.visible)
    config_flags[cfg.flag] = cfg.set
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible
    return setmetatable(cfg, nebula)
end

function nebula:dropdown(opts)
    opts = opts or {}
    local cfg = { flag = opts.flag or tostring(random(1,99999)), name = opts.name,
        items = opts.items or {}, multi = opts.multi or false,
        callback = opts.callback or function() end, visible = opts.visible ~= false,
        open = false, selected = {}, option_instances = {} }
    cfg.default = opts.default or (cfg.multi and {}) or cfg.items[1] or nil

    local total_h = cfg.name and 30 or 20
    local wrap = mk("Frame", { Parent = self.holder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,0,total_h) })
    if cfg.name then
        mk("TextLabel", { Parent = wrap, BackgroundTransparency = 1, Position = dim2(0,0,0,0),
            Size = dim2(1,0,0,14), Font = Enum.Font.Gotham, Text = cfg.name,
            TextColor3 = theme.text_dim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
    end
    local by = cfg.name and 16 or 0
    local dd_btn = mk("TextButton", { Parent = wrap, BackgroundColor3 = theme.bg_element,
        BackgroundTransparency = 1, BorderSizePixel = 0, Position = dim2(0,0,0,by),
        Size = dim2(1,0,0,18), Text = "", AutoButtonColor = false })
    mk("UICorner", { Parent = dd_btn, CornerRadius = dim(0,3) })

    local lbl = mk("TextLabel", { Parent = dd_btn, BackgroundTransparency = 1,
        Position = dim2(0,4,0,0), Size = dim2(1,-22,1,0), Font = Enum.Font.Gotham,
        Text = "select", TextColor3 = theme.text_main, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    register(lbl, "TextColor3", "text_main")

    local arrow_lbl = mk("TextLabel", { Parent = dd_btn, BackgroundTransparency = 1,
        Position = dim2(1,-14,0,0), Size = dim2(0,12,1,0), Font = Enum.Font.GothamBold,
        Text = "+", TextColor3 = theme.text_dim, TextSize = 14 })

    local popup = mk("Frame", { Parent = popup_root, BackgroundColor3 = theme.bg_mid,
        BorderSizePixel = 0, Size = dim2(0,100,0,0), AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false, ZIndex = 200 })
    mk("UICorner", { Parent = popup, CornerRadius = dim(0,4) })
    local popup_stroke = mk("UIStroke", { Parent = popup, Color = theme.border, Thickness = 1 })
    register(popup, "BackgroundColor3", "bg_mid")
    register(popup_stroke, "Color", "border")
    mk("UIPadding", { Parent = popup, PaddingTop = dim(0,4), PaddingBottom = dim(0,4),
        PaddingLeft = dim(0,6), PaddingRight = dim(0,6) })
    mk("UIListLayout", { Parent = popup, Padding = dim(0,2), SortOrder = Enum.SortOrder.LayoutOrder })

    local closing_conn = nil

    local function reposition_dd()
        if not popup.Parent then return end
        local abs = dd_btn.AbsolutePosition
        local sz  = dd_btn.AbsoluteSize
        popup.Position = dim2(0, abs.X, 0, abs.Y + sz.Y + 2 + gui_offset)
        popup.Size     = dim2(0, sz.X,  0, 0)
    end
    insert(reposition_callbacks, reposition_dd)

    function cfg.set_visible(bool)
        if bool then
            if nebula.current_element_open and nebula.current_element_open ~= cfg then
                nebula.current_element_open.set_visible(false)
                nebula.current_element_open.open = false
            end
            nebula.current_element_open = cfg
            popup.Visible = true
            cfg.open = true
            reposition_dd()
            closing_conn = uis.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local m = uis:GetMouseLocation()
                local pop_abs, pop_size = popup.AbsolutePosition, popup.AbsoluteSize
                local inside_pop = m.X >= pop_abs.X and m.X <= pop_abs.X + pop_size.X
                    and m.Y >= pop_abs.Y and m.Y <= pop_abs.Y + pop_size.Y
                local btn_abs, btn_size = dd_btn.AbsolutePosition, dd_btn.AbsoluteSize
                local inside_btn = m.X >= btn_abs.X and m.X <= btn_abs.X + btn_size.X
                    and m.Y >= btn_abs.Y and m.Y <= btn_abs.Y + btn_size.Y
                if inside_pop or inside_btn then return end
                if is_inside_any_shell(m.X, m.Y) then return end
                cfg.set_visible(false)
            end)
        else
            if closing_conn then closing_conn:Disconnect(); closing_conn = nil end
            popup.Visible = false
            cfg.open = false
        end
        arrow_lbl.Text = bool and "−" or "+"
        arrow_lbl.TextColor3 = bool and theme.text_accent or theme.text_dim
    end

    function cfg.set(value)
        local is_tbl = type(value) == "table"
        cfg.selected = {}
        for _, inst in ipairs(cfg.option_instances) do
            local match = (is_tbl and find(value, inst.Text)) or inst.Text == value
            inst.TextColor3 = match and theme.text_accent or theme.text_main
            if match then insert(cfg.selected, inst.Text) end
        end
        lbl.Text = (next(cfg.selected) and concat(cfg.selected, ", ")) or "select"
        flags[cfg.flag] = cfg.multi and cfg.selected or cfg.selected[1]
        cfg.callback(flags[cfg.flag])
    end

    function cfg:refresh_options(list)
        for _, v in ipairs(cfg.option_instances) do v:Destroy() end
        cfg.option_instances = {}; cfg.items = list
        for _, item in ipairs(list) do
            local opt = mk("TextButton", { Parent = popup, BackgroundTransparency = 1,
                BorderSizePixel = 0, Font = Enum.Font.Gotham, Size = dim2(1,0,0,16),
                Text = item, TextColor3 = theme.text_main, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 201 })
            insert(cfg.option_instances, opt)
            opt.MouseButton1Click:Connect(function()
                if cfg.multi then
                    local idx = find(cfg.selected, item)
                    if idx then remove(cfg.selected, idx) else insert(cfg.selected, item) end
                    cfg.set(cfg.selected)
                else
                    cfg.set(item); cfg.set_visible(false)
                end
            end)
            opt.MouseEnter:Connect(function() opt.TextColor3 = theme.text_accent end)
            opt.MouseLeave:Connect(function()
                opt.TextColor3 = find(cfg.selected, item) and theme.text_accent or theme.text_main
            end)
        end
    end

    dd_btn.MouseButton1Click:Connect(function() cfg.set_visible(not cfg.open) end)
    function cfg.set_element_visible(b) wrap.Visible = b end
    cfg:refresh_options(cfg.items)
    if cfg.default then cfg.set(cfg.default) end
    cfg.set_element_visible(cfg.visible)
    config_flags[cfg.flag] = cfg.set
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible
    return setmetatable(cfg, nebula)
end

function nebula:textbox(opts)
    opts = opts or {}
    local cfg = { flag = opts.flag or tostring(random(1,99999)),
        placeholder = opts.placeholder or "type here...", default = opts.default,
        callback = opts.callback or function() end, visible = opts.visible ~= false }
    local wrap = mk("Frame", { Parent = self.holder, BackgroundColor3 = theme.bg_element,
        BorderSizePixel = 0, Size = dim2(1,0,0,18) })
    mk("UICorner", { Parent = wrap, CornerRadius = dim(0,3) })
    local wrap_stroke = mk("UIStroke", { Parent = wrap, Color = theme.border, Thickness = 1 })
    register(wrap, "BackgroundColor3", "bg_element")
    register(wrap_stroke, "Color", "border")

    local tb = mk("TextBox", { Parent = wrap, BackgroundTransparency = 1, BorderSizePixel = 0,
        ClearTextOnFocus = false, Font = Enum.Font.Gotham, PlaceholderColor3 = theme.text_dim,
        PlaceholderText = cfg.placeholder, Position = dim2(0,8,0,0), Size = dim2(1,-16,1,0),
        Text = "", TextColor3 = theme.text_main, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
    register(tb, "TextColor3", "text_main")
    register(tb, "PlaceholderColor3", "text_dim")
    tb:GetPropertyChangedSignal("Text"):Connect(function()
        flags[cfg.flag] = tb.Text; cfg.callback(tb.Text)
    end)
    function cfg.set(t) tb.Text = t; flags[cfg.flag] = t; cfg.callback(t) end
    function cfg.set_element_visible(b) wrap.Visible = b end
    if cfg.default then cfg.set(cfg.default) end
    cfg.set_element_visible(cfg.visible)
    config_flags[cfg.flag] = cfg.set
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible
    return setmetatable(cfg, nebula)
end

function nebula:button(opts)
    opts = opts or {}
    local cfg = { name = opts.name or opts.text or "Button",
        callback = opts.callback or function() end,
        flag = opts.flag or tostring(random(1,99999)), visible = opts.visible ~= false }
    local btn = mk("TextButton", { Parent = self.holder, BackgroundColor3 = theme.bg_element,
        BorderSizePixel = 0, Font = Enum.Font.GothamMedium, Size = dim2(1,0,0,18),
        Text = cfg.name, TextColor3 = theme.text_main, TextSize = 12, AutoButtonColor = false })
    mk("UICorner", { Parent = btn, CornerRadius = dim(0,3) })
    local btn_stroke = mk("UIStroke", { Parent = btn, Color = theme.border, Thickness = 1 })
    register(btn_stroke, "Color", "border")
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=theme.bg_light,TextColor3=theme.text_accent}) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=theme.bg_element,TextColor3=theme.text_main}) end)
    btn.MouseButton1Down:Connect(function() tw(btn,{BackgroundColor3=theme.accent_dim}) end)
    btn.MouseButton1Up:Connect(function() tw(btn,{BackgroundColor3=theme.bg_light}); cfg.callback() end)
    function cfg.set_element_visible(b) btn.Visible = b end
    cfg.set_element_visible(cfg.visible)
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible
    return setmetatable(cfg, nebula)
end

function nebula:label(opts)
    opts = opts or {}
    local cfg = {
        flag = opts.flag or tostring(random(1,99999)),
        visible = opts.visible ~= false,
        text = opts.name or opts.text or "",
        prefix = opts.prefix or "",
        suffix = opts.suffix or "",
        update = opts.update or nil,
        interval = opts.interval or 0.25,
    }
    local row = mk("Frame", { Parent = self.holder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,0,14) })
    local lbl = mk("TextLabel", { Parent = row, BackgroundTransparency = 1, Size = dim2(1,0,1,0),
        Font = Enum.Font.Gotham, Text = cfg.prefix .. cfg.text .. cfg.suffix,
        TextColor3 = theme.text_dim, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
    register(lbl, "TextColor3", "text_dim")

    function cfg.change_text(t)
        cfg.text = tostring(t)
        lbl.Text = cfg.prefix .. cfg.text .. cfg.suffix
    end
    function cfg.set(t) cfg.change_text(t) end
    function cfg.get() return cfg.text end
    function cfg.set_prefix(p) cfg.prefix = tostring(p); cfg.change_text(cfg.text) end
    function cfg.set_suffix(s) cfg.suffix = tostring(s); cfg.change_text(cfg.text) end
    function cfg.set_update(fn, iv)
        cfg.update = fn
        if iv then cfg.interval = iv end
    end
    function cfg.set_element_visible(b) row.Visible = b end
    cfg.set_element_visible(cfg.visible)
    flags[cfg.flag] = cfg.text
    config_flags[cfg.flag] = function(v) cfg.change_text(v) end
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible

    if cfg.update then
        task.spawn(function()
            while lbl.Parent do
                local ok, v = pcall(cfg.update)
                if ok and v ~= nil then cfg.change_text(v) end
                task.wait(cfg.interval)
            end
        end)
    end
    return setmetatable(cfg, nebula)
end

function nebula:keybind(opts)
    opts = opts or {}
    local cfg = { flag = opts.flag or "KB_" .. tostring(random(1,99999)),
        name = opts.name or "Keybind", key = opts.key or nil, mode = opts.mode or "toggle",
        active = opts.default or false, callback = opts.callback or function() end,
        on_bind = opts.on_bind or nil, visible = opts.visible ~= false, binding = nil,
        show_in_list = opts.show_in_list ~= false, _kl_key_lbl = nil }
    flags[cfg.flag] = { active=cfg.active, key=cfg.key, mode=cfg.mode }

    if cfg.show_in_list then
        insert(nebula._keybind_entries, cfg)
        if nebula._keybind_list then nebula:_rebuild_keybind_list() end
    end

    local row = mk("Frame", { Parent = self.holder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,0,18) })
    local kb_label = mk("TextLabel", { Parent = row, BackgroundTransparency = 1,
        Position = dim2(0,0,0,0), Size = dim2(1,-50,1,0), Font = Enum.Font.Gotham,
        Text = cfg.name, TextColor3 = theme.text_main, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left })
    register(kb_label, "TextColor3", "text_main")

    local kb_btn = mk("TextButton", { Parent = row, BackgroundColor3 = theme.bg_element,
        BorderSizePixel = 0, Position = dim2(1,-44,0.5,-8), Size = dim2(0,44,0,16),
        Font = Enum.Font.Gotham,
        Text = (cfg.key and typeof(cfg.key) == "EnumItem" and cfg.key ~= Enum.KeyCode.Unknown)
            and string.lower(cfg.key.Name) or "none",
        TextColor3 = theme.text_dim, TextSize = 10, AutoButtonColor = false })
    mk("UICorner", { Parent = kb_btn, CornerRadius = dim(0,3) })
    local kb_stroke = mk("UIStroke", { Parent = kb_btn, Color = theme.border, Thickness = 1 })
    register(kb_btn, "BackgroundColor3", "bg_element")
    register(kb_stroke, "Color", "border")

    local function sync_kl_label()
        if cfg._kl_key_lbl and cfg._kl_key_lbl.Parent then
            local k = cfg.key
            if k and typeof(k) == "EnumItem" and k ~= Enum.KeyCode.Unknown then
                cfg._kl_key_lbl.Text = "[" .. string.lower(k.Name) .. "]"
            else
                cfg._kl_key_lbl.Text = "[none]"
            end
        end
    end

    function cfg.set(input)
        if type(input) == "table" then
            cfg.active = input.active
            cfg.key    = input.key
            cfg.mode   = input.mode
            local k = cfg.key
            kb_btn.Text = (k and typeof(k) == "EnumItem" and k ~= Enum.KeyCode.Unknown)
                and string.lower(k.Name) or "none"
            if cfg.on_bind then pcall(cfg.on_bind, cfg.key) end
            sync_kl_label()
        elseif type(input) == "boolean" then
            cfg.active = input
            cfg.callback(input)
        elseif typeof(input) == "EnumItem" then
            cfg.key = input
            kb_btn.Text = string.lower(input.Name)
            kb_btn.TextColor3 = theme.text_accent
            if cfg.on_bind then pcall(cfg.on_bind, cfg.key) end
            sync_kl_label()
        end
        flags[cfg.flag] = { active=cfg.active, key=cfg.key, mode=cfg.mode }
        nebula:_rebuild_keybind_list()
    end

    kb_btn.MouseButton1Click:Connect(function()
        if cfg.binding then return end
        kb_btn.Text = "..."; kb_btn.TextColor3 = theme.accent
        cfg.binding = conn(uis.InputBegan, function(i, gp)
            if gp then return end
            if i.KeyCode == Enum.KeyCode.Escape then
                local k = cfg.key
                kb_btn.Text = (k and typeof(k) == "EnumItem" and k ~= Enum.KeyCode.Unknown)
                    and string.lower(k.Name) or "none"
                kb_btn.TextColor3 = theme.text_dim
                cfg.binding:Disconnect(); cfg.binding = nil; return
            end
            cfg.set(i.KeyCode)
            cfg.binding:Disconnect(); cfg.binding = nil
        end)
    end)
    conn(uis.InputBegan, function(i, gp)
        if gp or not cfg.key or i.KeyCode ~= cfg.key then return end
        if cfg.mode == "toggle" then cfg.set(not cfg.active)
        elseif cfg.mode == "hold" then cfg.set(true) end
    end)
    conn(uis.InputEnded, function(i)
        if cfg.key and i.KeyCode == cfg.key and cfg.mode == "hold" then cfg.set(false) end
    end)
    function cfg.set_element_visible(b) row.Visible = b end
    cfg.set_element_visible(cfg.visible)
    config_flags[cfg.flag] = cfg.set
    nebula.visible_flags[cfg.flag] = cfg.set_element_visible
    return setmetatable(cfg, nebula)
end

function nebula:colorpicker(opts)
    opts = opts or {}
    local cfg = { flag = opts.flag or tostring(random(1,99999)), name = opts.name or "Color",
        color = opts.color or Color3.new(1,1,1), alpha = opts.alpha or 1,
        callback = opts.callback or function() end, on_theme_key = opts.on_theme_key or nil,
        open = false }
    local h, s, v = cfg.color:ToHSV()
    local a = cfg.alpha
    local dsv, dhue, dal = false, false, false

    local row = mk("Frame", { Parent = self.holder, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,0,18) })
    local cp_label = mk("TextLabel", { Parent = row, BackgroundTransparency = 1,
        Position = dim2(0,0,0,0), Size = dim2(1,-32,1,0), Font = Enum.Font.Gotham,
        Text = cfg.name, TextColor3 = theme.text_main, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left })
    register(cp_label, "TextColor3", "text_main")

    local swatch = mk("TextButton", { Parent = row, BackgroundColor3 = cfg.color,
        BorderSizePixel = 0, Position = dim2(1,-26,0.5,-8), Size = dim2(0,26,0,16),
        Text = "", AutoButtonColor = false })
    mk("UICorner", { Parent = swatch, CornerRadius = dim(0,3) })
    local swatch_stroke = mk("UIStroke", { Parent = swatch, Color = theme.border, Thickness = 1 })
    register(swatch_stroke, "Color", "border")

    local picker = mk("Frame", { Parent = popup_root, BackgroundColor3 = theme.bg_mid,
        BorderSizePixel = 0, Size = dim2(0,180,0,168), Visible = false, ZIndex = 300 })
    mk("UICorner", { Parent = picker, CornerRadius = dim(0,4) })
    local picker_stroke = mk("UIStroke", { Parent = picker, Color = theme.border, Thickness = 1 })
    register(picker, "BackgroundColor3", "bg_mid")
    register(picker_stroke, "Color", "border")
    mk("UIPadding", { Parent = picker, PaddingTop = dim(0,6), PaddingBottom = dim(0,6),
        PaddingLeft = dim(0,6), PaddingRight = dim(0,6) })

    local sv_frame = mk("Frame", { Parent = picker, BorderSizePixel = 0,
        Size = dim2(1,-20,1,-32), BackgroundColor3 = Color3.fromHSV(h,1,1), ZIndex = 301 })
    mk("UICorner", { Parent = sv_frame, CornerRadius = dim(0,3) })

    local sat_layer = mk("Frame", { Parent = sv_frame, BorderSizePixel = 0,
        Size = dim2(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0, ZIndex = 302 })
    mk("UIGradient", { Parent = sat_layer,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1),
        } })

    local val_layer = mk("Frame", { Parent = sv_frame, BorderSizePixel = 0,
        Size = dim2(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0, ZIndex = 303 })
    mk("UIGradient", { Parent = val_layer, Rotation = 270,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1),
        } })

    local sv_cursor = mk("Frame", { Parent = sv_frame, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 1, Size = dim2(0,6,0,6), ZIndex = 304 })
    mk("UICorner", { Parent = sv_cursor, CornerRadius = dim(0,3) })

    local sv_btn = mk("TextButton", { Parent = sv_frame, BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = dim2(1,0,1,0), Text = "", ZIndex = 305 })

    local hue_bar = mk("TextButton", {
        Parent = picker, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0, Position = dim2(1,-14,0,0), Size = dim2(0,10,1,-32),
        Text = "", AutoButtonColor = false, ZIndex = 301,
    })
    mk("UICorner", { Parent = hue_bar, CornerRadius = dim(0,3) })
    mk("UIGradient", {
        Parent = hue_bar, Rotation = 270,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    rgb(255,0,0)),
            ColorSequenceKeypoint.new(0.17, rgb(255,255,0)),
            ColorSequenceKeypoint.new(0.33, rgb(0,255,0)),
            ColorSequenceKeypoint.new(0.5,  rgb(0,255,255)),
            ColorSequenceKeypoint.new(0.67, rgb(0,0,255)),
            ColorSequenceKeypoint.new(0.83, rgb(255,0,255)),
            ColorSequenceKeypoint.new(1,    rgb(255,0,0)),
        },
    })
    local hue_cursor = mk("Frame", { Parent = hue_bar, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 1, Size = dim2(1,0,0,3), ZIndex = 302 })

    local alpha_bar = mk("TextButton", { Parent = picker, BackgroundColor3 = rgb(255,255,255),
        BorderSizePixel = 0, Position = dim2(0,0,1,-20), Size = dim2(1,-20,0,10),
        Text = "", AutoButtonColor = false, ZIndex = 301 })
    mk("UICorner", { Parent = alpha_bar, CornerRadius = dim(0,3) })
    local alpha_fill = mk("Frame", { Parent = alpha_bar, BorderSizePixel = 0,
        Size = dim2(1,0,1,0), ZIndex = 302 })
    mk("UICorner", { Parent = alpha_fill, CornerRadius = dim(0,3) })
    mk("UIGradient", { Parent = alpha_fill,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0),
        },
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
        } })
    local alpha_cursor = mk("Frame", { Parent = alpha_bar, BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 1, Size = dim2(0,3,1,0), ZIndex = 303 })

    local closing_conn = nil

    local function reposition_cp()
        if not picker.Parent then return end
        local abs = swatch.AbsolutePosition
        picker.Position = dim2(0, abs.X - 188, 0, abs.Y + gui_offset)
    end
    insert(reposition_callbacks, reposition_cp)

    function cfg.set_visible(bool)
        if bool then
            if nebula.current_element_open and nebula.current_element_open ~= cfg then
                nebula.current_element_open.set_visible(false)
                nebula.current_element_open.open = false
            end
            nebula.current_element_open = cfg
            picker.Visible = true
            cfg.open = true
            reposition_cp()
            closing_conn = uis.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local m = uis:GetMouseLocation()
                local p_abs, p_size = picker.AbsolutePosition, picker.AbsoluteSize
                local inside_p = m.X >= p_abs.X and m.X <= p_abs.X + p_size.X
                    and m.Y >= p_abs.Y and m.Y <= p_abs.Y + p_size.Y
                local s_abs, s_size = swatch.AbsolutePosition, swatch.AbsoluteSize
                local inside_s = m.X >= s_abs.X and m.X <= s_abs.X + s_size.X
                    and m.Y >= s_abs.Y and m.Y <= s_abs.Y + s_size.Y
                if inside_p or inside_s then return end
                if is_inside_any_shell(m.X, m.Y) then return end
                cfg.set_visible(false)
            end)
        else
            if closing_conn then closing_conn:Disconnect(); closing_conn = nil end
            picker.Visible = false
            cfg.open = false
        end
    end

    function cfg.set(col, al)
        if col then h, s, v = col:ToHSV() end
        if al  then a = al end
        local c = Color3.fromHSV(h, s, v)
        sv_frame.BackgroundColor3   = Color3.fromHSV(h,1,1)
        alpha_fill.BackgroundColor3 = c
        sv_cursor.Position    = dim2(s,-3,1-v,-3)
        hue_cursor.Position   = dim2(0,0,1-h,-1)
        alpha_cursor.Position = dim2(a,-1,0,0)
        swatch.BackgroundColor3 = c
        cfg.color = c; cfg.alpha = a
        flags[cfg.flag] = { Color=c, Transparency=a }
        cfg.callback(c, a)
        if cfg.on_theme_key then set_theme_color(cfg.on_theme_key, c) end
    end

    local function upd()
        local m = uis:GetMouseLocation()
        if dsv then
            s = clamp((m.X - sv_frame.AbsolutePosition.X)/sv_frame.AbsoluteSize.X, 0, 1)
            v = 1 - clamp((m.Y - gui_offset - sv_frame.AbsolutePosition.Y)/sv_frame.AbsoluteSize.Y, 0, 1)
        elseif dhue then
            h = 1 - clamp((m.Y - gui_offset - hue_bar.AbsolutePosition.Y)/hue_bar.AbsoluteSize.Y, 0, 1)
        elseif dal then
            a = clamp((m.X - alpha_bar.AbsolutePosition.X)/alpha_bar.AbsoluteSize.X, 0, 1)
        end
        cfg.set()
    end

    sv_btn.MouseButton1Down:Connect(function()    dsv  = true end)
    hue_bar.MouseButton1Down:Connect(function()   dhue = true end)
    alpha_bar.MouseButton1Down:Connect(function()  dal  = true end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dsv, dhue, dal = false, false, false
        end
    end)
    uis.InputChanged:Connect(function(i)
        if (dsv or dhue or dal) and i.UserInputType == Enum.UserInputType.MouseMovement then upd() end
    end)
    swatch.MouseButton1Click:Connect(function() cfg.set_visible(not cfg.open) end)
    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set
    return setmetatable(cfg, nebula)
end

function nebula:get_config()
    local out = {}
    for k, v in next, flags do
        if type(v) == "table" then
            if v.Color and v.Transparency ~= nil then
                out[k] = { Color = v.Color:ToHex(), Transparency = v.Transparency }
            elseif v.key ~= nil or v.mode ~= nil then
                out[k] = { active = v.active, mode = v.mode, key = v.key and tostring(v.key) or nil }
            else out[k] = v end
        else out[k] = v end
    end
    return http_service:JSONEncode(out)
end

function nebula:load_config(json)
    local ok, data = pcall(http_service.JSONDecode, http_service, json)
    if not ok then return end
    for k, v in next, data do
        local setter = config_flags[k]
        if setter then
            if type(v) == "table" and v.Color ~= nil then
                setter(hex(v.Color), v.Transparency)
            elseif type(v) == "table" and v.mode ~= nil then
                local ke = nil
                pcall(function()
                    if v.key then
                        for _, e in ipairs(Enum.KeyCode:GetEnumItems()) do
                            if tostring(e) == v.key then ke = e; break end
                        end
                    end
                end)
                setter({ active = v.active, mode = v.mode, key = ke })
            else setter(v) end
        end
    end
end

function nebula:config_section(opts)
    opts = opts or {}
    local target = (self.holder and self) or self
    local sec = target:section({ name = opts.name or "Config" })
    local DD_FLAG = opts.dd_flag or "NEBULA_CFG_DD"
    local NM_FLAG = "NEBULA_CFG_NAME"

    local function list_cfgs()
        local out = {}
        pcall(function()
            for _, f in ipairs(listfiles(nebula.directory .. "/configs")) do
                local n = f:gsub(nebula.directory .. "[\\/]configs[\\/]", ""):gsub("%.cfg$", "")
                if n ~= "" then insert(out, n) end
            end
        end)
        return out
    end

    local dd = sec:dropdown({ flag = DD_FLAG, items = list_cfgs(),
        placeholder = "select config...", callback = function() end })
    sec:textbox({ flag = NM_FLAG, placeholder = "config name..." })

    sec:button({ name = "Save Config", callback = function()
        local n = flags[NM_FLAG]
        if not n or n == "" then nebula:notify("enter a config name first", 2); return end
        pcall(function()
            writefile(nebula.directory .. "/configs/" .. n .. ".cfg", nebula:get_config())
        end)
        dd:refresh_options(list_cfgs())
        nebula:notify("saved: " .. n)
    end })

    sec:button({ name = "Load Config", callback = function()
        local n = flags[DD_FLAG]
        if not n or n == "" then nebula:notify("select a config first", 2); return end
        local ok = false
        pcall(function()
            local p = nebula.directory .. "/configs/" .. n .. ".cfg"
            if isfile(p) then nebula:load_config(readfile(p)); ok = true end
        end)
        if ok then nebula:notify("loaded: " .. n) else nebula:notify("file not found", 2) end
    end })

    sec:button({ name = "Delete Config", callback = function()
        local n = flags[DD_FLAG]
        if not n or n == "" then nebula:notify("select a config first", 2); return end
        pcall(function()
            local p = nebula.directory .. "/configs/" .. n .. ".cfg"
            if isfile(p) then delfile(p) end
        end)
        dd:refresh_options(list_cfgs())
        nebula:notify("deleted: " .. n)
    end })
end

function nebula:theme_section()
    local sec = self:section({ name = "Theme" })
    local dd = sec:dropdown({ name = "Preset", flag = "NEBULA_THEME_PRESET",
        items = theme_preset_names, default = current_theme,
        callback = function(name) apply_theme_preset(name) end })
    nebula._theme_dropdown = dd
    return sec
end

function nebula:destroy()
    for _, c in ipairs(nebula.connections) do
        pcall(function() c:Disconnect() end)
    end
    nebula.connections = {}

    for _, sh in ipairs(nebula._shells) do
        pcall(function()
            if sh and sh.Parent then sh.Parent:Destroy() end
        end)
    end
    nebula._shells = {}

    pcall(function() popup_root:Destroy() end)
    pcall(function() notif_gui:Destroy() end)
    pcall(function() overlay_gui:Destroy() end)

    nebula._watermark        = nil
    nebula._keybind_list     = nil
    nebula._keybind_entries  = {}
    nebula.flags             = {}
    nebula.config_flags      = {}
    nebula.visible_flags     = {}

    if getgenv().Nebula == nebula then
        getgenv().Nebula = nil
    end
end

getgenv().Nebula = nebula

nebula:notify("nebula loaded.", 3)

return nebula
