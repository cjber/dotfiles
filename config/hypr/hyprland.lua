-- Hyprland 0.55+ config (Lua). Hyprlang is deprecated upstream.
-- File reload is automatic on save; `hyprctl reload` forces it.

--------------------------------------------------------------------
-- Theme (Oxide)
--------------------------------------------------------------------
local C = {
    base      = "rgb(121113)",
    mantle    = "rgb(121212)",
    crust     = "rgb(0a0a0a)",
    surface0  = "rgb(222222)",
    surface1  = "rgb(333333)",
    text      = "rgb(c1c1c1)",
    primary   = "rgb(e78a53)",
    secondary = "rgb(5f8787)",
    tertiary  = "rgb(fbcb97)",
}
local border_size = 2
local gaps_in     = 5
local gaps_out    = 10
local rounding    = 10
local mod         = "SUPER"

--------------------------------------------------------------------
-- Environment
--------------------------------------------------------------------
hl.env("LIBVA_DRIVER_NAME",          "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME",  "nvidia")
hl.env("NVD_BACKEND",                "direct")
hl.env("GBM_BACKEND",                "nvidia-drm")
hl.env("__GL_VRR_ALLOWED",           "1")
hl.env("__GL_MaxFramesAllowed",      "1")
hl.env("VDPAU_DRIVER",               "nvidia")
hl.env("MOZ_ENABLE_WAYLAND",         "1")
hl.env("PROTON_ENABLE_NGX_UPDATER",  "1")
hl.env("XDG_SESSION_TYPE",           "wayland")
hl.env("QT_QPA_PLATFORMTHEME",       "qt6ct")
hl.env("HYPRCURSOR_THEME",           "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",            "24")
hl.env("XCURSOR_THEME",              "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE",               "24")
hl.env("GTK_THEME",                  "Adwaita:dark")

--------------------------------------------------------------------
-- Monitors
-- ICC profiles: drop a calibrated `.icm` from DisplayCAL and set
-- `icc = "/abs/path/to.icm"` here. Both panels would benefit.
--------------------------------------------------------------------
hl.monitor({
    output   = "DP-1",
    mode     = "3440x1440@143.92",
    position = "1440x560",
    scale    = 1,
})
hl.monitor({
    output    = "DP-2",
    mode      = "2560x1440@60",
    position  = "0x0",
    scale     = 1,
    transform = 1, -- 90° rotation
})
-- HDMI-A-1 (Hisense TV) is NOT declared statically. The tv-toggle script
-- enables/disables it on demand. A static declaration with scale=1 conflicts
-- with the toggle's scale=1.60, causing a double-reconfigure that prevents
-- the TV from locking onto the 119.88Hz signal (flicker until power-cycle).

--------------------------------------------------------------------
-- Look & feel
--------------------------------------------------------------------
hl.config({
    general = {
        border_size = border_size,
        gaps_in     = gaps_in,
        gaps_out    = gaps_out,
        col = {
            active_border   = C.secondary,
            inactive_border = C.surface0,
        },
        layout                  = "scrolling", -- default; ws4 overrides
        no_focus_fallback       = false,
        resize_on_border        = false,
        extend_border_grab_area = 15,
        hover_icon_on_border    = true,
    },

    decoration = {
        rounding           = rounding,
        active_opacity     = 1.0,
        inactive_opacity   = 0.95,
        fullscreen_opacity = 1.0,
        dim_inactive       = false,
        dim_special        = 0.2,
        dim_around         = 0.4,

        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            color        = "rgba(0a0a0a80)",
            offset       = { 0, 4 },
        },

        -- 0.55: inner glow. Subtle accent on the active window.
        glow = {
            enabled         = true,
            range           = 12,
            render_power    = 3,
            color           = "rgba(e78a5366)",
            color_inactive  = "rgba(00000000)",
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            new_optimizations = true,
            xray              = false,
            noise             = 0.02,
            contrast          = 1.0,
            brightness        = 0.9,
            vibrancy          = 0.2,
            popups            = true,
        },
    },

    animations = { enabled = true },

    --------------------------------------------------------------------
    -- Layouts
    --------------------------------------------------------------------
    -- Master (used as fallback / for any workspace we don't override).
    master = {
        allow_small_split             = false,
        mfact                         = 0.33,
        new_on_top                    = false,
        orientation                   = "center",
        slave_count_for_center_master = 0,
    },

    -- Scrolling layout. column_width is the global default; workspace 4
    -- overrides to 0.333 via a per-workspace window rule below.
    -- mod+[/] cycles widths per column at any time.
    -- fullscreen_on_one_column = false so the arrange_dp1 hook can cap
    -- solo columns at ~66% (see below).
    scrolling = {
        fullscreen_on_one_column = false,
        column_width             = 0.33,    -- DP-1 default: 3 cols visible
        focus_fit_method         = 1,
        follow_focus             = true,
        follow_min_visible       = 0.4,
        explicit_column_widths   = "0.333, 0.5, 0.667, 1.0",
        wrap_focus               = true,
        wrap_swapcol             = true,
        direction                = "right",
    },

    --------------------------------------------------------------------
    -- Input
    --------------------------------------------------------------------
    input = {
        repeat_rate                 = 75,
        repeat_delay                = 400,
        sensitivity                 = -0.8,
        force_no_accel              = false,
        left_handed                 = false,
        follow_mouse                = 1,
        mouse_refocus               = true,
        float_switch_override_focus = 1,
        touchpad = {
            disable_while_typing    = true,
            natural_scroll          = false,
            scroll_factor           = 1.0,
            middle_button_emulation = false,
            clickfinger_behavior    = false,
            tap_to_click            = true,
            drag_lock               = 0,
            tap_and_drag            = true,
        },
        touchdevice = {
            transform = 0,
        },
    },

    --------------------------------------------------------------------
    -- Gestures (legacy workspace-swipe knobs)
    --------------------------------------------------------------------
    gestures = {
        workspace_swipe_distance           = 300,
        workspace_swipe_invert             = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio       = 0.5,
        workspace_swipe_create_new         = true,
        workspace_swipe_forever            = false,
    },

    --------------------------------------------------------------------
    -- Misc
    --------------------------------------------------------------------
    misc = {
        background_color             = C.mantle,
        disable_hyprland_logo        = true,
        disable_splash_rendering     = false,
        vrr                          = 2,
        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,
        always_follow_on_dnd         = true,
        layers_hog_keyboard_focus    = true,
        animate_manual_resizes       = true,
        animate_mouse_windowdragging = true,
        disable_autoreload           = false,
        enable_swallow               = false,
        focus_on_activate            = true,
        mouse_move_focuses_monitor   = true,
        allow_session_lock_restore   = false,
    },

    --------------------------------------------------------------------
    -- Debug (vfr moved here from misc in 0.55)
    --------------------------------------------------------------------
    debug = {
        overlay         = false,
        damage_blink    = false,
        disable_logs    = false,
        disable_time    = true,
        damage_tracking = 2,
        vfr             = true,
    },

    --------------------------------------------------------------------
    -- Groups
    --------------------------------------------------------------------
    group = {
        col = {
            border_active   = C.primary,
            border_inactive = C.surface0,
        },
        groupbar = {
            enabled     = true,
            font_family = "JetBrainsMono Nerd Font Mono Bold",
            font_size   = 10,
            text_color  = C.secondary,
            height      = 20,
            col = {
                active   = C.surface0,
                inactive = C.base,
            },
        },
    },

    --------------------------------------------------------------------
    -- Binds
    --------------------------------------------------------------------
    binds = {
        pass_mouse_when_bound  = false,
        scroll_event_delay     = 300,
        workspace_back_and_forth = true,
        allow_workspace_cycles = false,
        focus_preferred_method = 0,
    },

    --------------------------------------------------------------------
    -- Cursor (NVIDIA): use_cpu_buffer=2 (auto) gives HW cursors on nvidia.
    --------------------------------------------------------------------
    cursor = {
        use_cpu_buffer    = 2,
        enable_hyprcursor = true,
        inactive_timeout  = 3,  -- hide cursor after 3s of inactivity
    },

    --------------------------------------------------------------------
    -- XWayland: report native (unscaled) resolutions to X11 apps.
    -- Without this, the TV at scale 1.60 reports 2400x1350 to XWayland
    -- instead of 3840x2160, so Proton games cap at 1920x1080.
    -- Cursor is unscaled too, so bump XCURSOR_SIZE to compensate.
    --------------------------------------------------------------------
    xwayland = {
        force_zero_scaling = true,
    },
})

--------------------------------------------------------------------
-- Animations (snappy / smooth feel)
--------------------------------------------------------------------
hl.curve("snappy", { type = "bezier", points = { { 0.2, 1.0 }, { 0.3, 1.0 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.4, 0.0 }, { 0.2, 1.0 } } })
hl.curve("fade",   { type = "bezier", points = { { 0.0, 0.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4, bezier = "snappy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 4, bezier = "snappy", style = "popin 80%" })
hl.animation({ leaf = "windows",          enabled = true, speed = 4, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 3, bezier = "fade" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 3, bezier = "fade" })
hl.animation({ leaf = "fadeGlow",         enabled = true, speed = 2, bezier = "fade" })
hl.animation({ leaf = "fadeDim",          enabled = true, speed = 3, bezier = "fade" })
hl.animation({ leaf = "border",           enabled = true, speed = 2, bezier = "smooth" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "snappy", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "snappy", style = "slidefadevert 20%" })

--------------------------------------------------------------------
-- Workspace rules
-- DP-1 ultrawide: scrolling rightward (global default).
-- DP-2 rotated:   scrolling downward (per-workspace direction).
--------------------------------------------------------------------
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({
    workspace   = "4",
    monitor     = "DP-2",
    default     = true,
    layout_opts = { direction = "down" },
})
-- TV (HDMI-A-1, normally disabled). tv-toggle enables the output then sends
-- the focused window here; ws5 binds to it once the monitor exists.
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", default = true })

--------------------------------------------------------------------
-- Layer rules
--------------------------------------------------------------------
hl.layer_rule({ match = { namespace = "waybar" },        blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.3, animation = "slide" })
hl.layer_rule({ match = { namespace = "hyprlauncher" },  blur = true, animation = "fade" })
hl.layer_rule({ match = { namespace = "selection" },     animation = "none" })

--------------------------------------------------------------------
-- Window rules
-- confine_pointer: pin the cursor to a window. Add for games as needed.
-- e.g.: hl.window_rule({ match = { class = "steam_app_.*" }, confine_pointer = true })
--------------------------------------------------------------------
-- Vertical monitor (workspace 4): static fallback width; the arrange_ws4
-- hook below takes over once >1 window exists.
hl.window_rule({ match = { workspace = "4" }, scrolling_width = 0.333 })

-- Scratchpad command-center on special:scratch. Three floating kittys laid
-- out for DP-1 (3440x1440). window_rule.move is *monitor-relative*; the
-- snap_scratch() hook below re-snaps in *absolute* coords on every summon
-- so a stray mod+drag doesn't persist.
--   scratch-cmd    1300x1200  center-left, focused shell  (mon-rel  705,120)
--   scratch-btm     700x 585  top-right system monitor    (mon-rel 2035,120)
--   scratch-nvtop   700x 585  bottom-right GPU monitor    (mon-rel 2035,735)
hl.window_rule({ match = { class = "scratch-cmd"   }, workspace = "special:scratch", float = true, size = { 1300, 1200 }, move = {  705, 120 } })
-- Monitor panes: no_focus so clicks don't pull focus off scratch-cmd.
hl.window_rule({ match = { class = "scratch-btm"   }, workspace = "special:scratch", float = true, size = {  700,  585 }, move = { 2035, 120 }, no_focus = true })
hl.window_rule({ match = { class = "scratch-nvtop" }, workspace = "special:scratch", float = true, size = {  700,  585 }, move = { 2035, 735 }, no_focus = true })

-- Game windows (Steam-launched: steam_app_<id>): pin the cursor to the
-- window, inhibit idle while fullscreen, skip blur/transparency, and
-- request direct scanout (tearing) for input latency.
hl.window_rule({
    match           = { class = "^steam_app_" },
    workspace       = 5,
    confine_pointer = true,
    idle_inhibit    = "fullscreen",
    immediate       = true,
    opaque          = true,
    no_blur         = true,
    opacity         = 1.0,
})

-- WoW (Lutris) runs inside a nested gamescope (class "gamescope"). Force it
-- fullscreen on open so Hyprland never tiles it — tiling misaligns the cursor.
-- Pin the pointer to it and skip blur/transparency, same as Steam games.
hl.window_rule({
    match           = { class = "^gamescope$" },
    fullscreen      = true,
    confine_pointer = true,
    idle_inhibit    = "fullscreen",
    immediate       = true,
    opaque          = true,
    no_blur         = true,
    opacity         = 1.0,
})

--------------------------------------------------------------------
-- ws4 auto-arrange (vertical monitor):
--   1 win  → fullscreen (via scrolling.fullscreen_on_one_column)
--   2 wins → top column 1/3 (small), bottom column 2/3 (large)
--   3+     → equal thirds
--------------------------------------------------------------------
local function arrange_ws4()
    local wins = hl.get_workspace_windows(4) or {}
    local n = #wins
    if n <= 1 then return end
    if n == 2 then
        -- Bottom window is always the tall one, regardless of stack order.
        local top, bottom = wins[1], wins[2]
        if top.at and bottom.at and top.at.y > bottom.at.y then
            top, bottom = bottom, top
        end
        hl.dispatch(hl.dsp.focus({ window = top }))
        hl.dispatch(hl.dsp.layout("colresize 0.333"))
        hl.dispatch(hl.dsp.focus({ window = bottom }))
        hl.dispatch(hl.dsp.layout("colresize 0.667"))
    else
        hl.dispatch(hl.dsp.layout("colresize all 0.333"))
    end
    hl.dispatch(hl.dsp.focus({ window = wins[n] }))
end

-- Scope these to ws4 only. A blanket hook would run on every window event
-- system-wide (e.g. Steam popups on DP-1) and the focus dispatches inside
-- would yank the active monitor over to DP-2.
local function on_ws4(w) return w and w.workspace and w.workspace.id == 4 end
hl.on("window.open",  function(w) if on_ws4(w) then arrange_ws4() end end)
hl.on("window.close", function(w) if on_ws4(w) then arrange_ws4() end end)
hl.on("window.move_to_workspace", function(_, ws)
    if ws and ws.id == 4 then arrange_ws4() end
end)

--------------------------------------------------------------------
-- DP-1 solo-column cap: when only one window exists on the active
-- DP-1 workspace, resize the column to ~66% instead of full width.
-- Pairs with scrolling.fullscreen_on_one_column = false above.
--------------------------------------------------------------------
local function arrange_dp1()
    local ws = hl.get_active_workspace()
    if not ws or ws.id < 1 or ws.id > 3 then return end
    local wins = hl.get_workspace_windows(ws.id) or {}
    if #wins == 1 then
        hl.dispatch(hl.dsp.layout("colresize 0.667"))
    end
end

local function on_dp1(w) return w and w.workspace and w.workspace.id >= 1 and w.workspace.id <= 3 end
hl.on("window.open",      function(w) if on_dp1(w) then arrange_dp1() end end)
hl.on("window.close",     function(w) if on_dp1(w) then arrange_dp1() end end)
hl.on("workspace.active", function(ws) if ws and ws.id >= 1 and ws.id <= 3 then arrange_dp1() end end)

--------------------------------------------------------------------
-- Scratchpad: re-snap each scratch-* kitty to its target position on
-- every summon, since Hyprland has no "immovable" window prop. Ends
-- by focusing the central shell so typing lands there.
--------------------------------------------------------------------
-- Absolute coords = DP-1 origin (1440, 560) + the monitor-relative move above.
local SCRATCH_POS = {
    ["scratch-cmd"]   = { x = 2145, y =  680 },
    ["scratch-btm"]   = { x = 3475, y =  680 },
    ["scratch-nvtop"] = { x = 3475, y = 1295 },
}
local function snap_scratch()
    local ws = hl.get_workspace("special:scratch")
    if not ws then return end
    local wins = ws:get_windows() or {}
    local cmd_win
    -- Move each window via window= selector so focus doesn't bounce around.
    for _, w in ipairs(wins) do
        local pos = SCRATCH_POS[w.class]
        if pos then
            hl.dispatch(hl.dsp.window.move({ window = w, x = pos.x, y = pos.y }))
            if w.class == "scratch-cmd" then cmd_win = w end
        end
    end
    -- Always land focus on the central shell, regardless of prior state.
    if cmd_win then hl.dispatch(hl.dsp.focus({ window = cmd_win })) end
end
hl.on("workspace.active", function(ws)
    if ws and ws.name == "special:scratch" then snap_scratch() end
end)

--------------------------------------------------------------------
-- Binds: apps
--------------------------------------------------------------------
hl.bind(mod .. " + Return",         hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + semicolon",      hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mod .. " + M",              hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. " + V",              hl.dsp.exec_cmd("hyprpwcenter"))
hl.bind(mod .. " + SHIFT + t", hl.dsp.exec_cmd("/home/cjber/scripts/tv-toggle"))
-- rofi kept for power menu; hyprlauncher has no equivalent dmenu plugin yet
hl.bind(mod .. " + SHIFT + O",      hl.dsp.exec_cmd('rofi -show p -modi p:"rofi-power-menu"'))
-- hyprsunset: toggle 4000K ↔ 6000K (sunset.service runs at 6000K = neutral)
hl.bind(mod .. " + B", hl.dsp.exec_cmd(
    [[bash -c 'if [ "$(hyprctl hyprsunset temperature)" -lt 5000 ]; then hyprctl hyprsunset temperature 6000; else hyprctl hyprsunset temperature 4000; fi']]
))

--------------------------------------------------------------------
-- Binds: function keys
--------------------------------------------------------------------
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("$backlight --inc"),                       { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("$backlight --dec"),                       { repeating = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { repeating = true, locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })

--------------------------------------------------------------------
-- Binds: Hyprland
--------------------------------------------------------------------
hl.bind(mod .. " + Q",            hl.dsp.window.close())
hl.bind(mod .. " + slash",        hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.window.float({ action = "toggle" }))
-- Screenshots via hyprshot. -z freezes the screen during selection.
hl.bind(mod .. " + SHIFT + P",    hl.dsp.exec_cmd("hyprshot -m region --clipboard-only -z"))
hl.bind(mod .. " + P",            hl.dsp.exec_cmd("hyprshot -m window -m active --clipboard-only"))
hl.bind(mod .. " + CTRL + P",     hl.dsp.exec_cmd("hyprshot -m output -m active --clipboard-only"))
hl.bind(mod .. " + C",            hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mod .. " + SHIFT + R",    hl.dsp.exec_cmd("pkill wl-screenrec || wl-screenrec -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4"))

--------------------------------------------------------------------
-- Binds: focus (vim-style)
--------------------------------------------------------------------
hl.bind(mod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Window move: swap columns within the workspace; if the active column is
-- the edge of its workspace, cross to the neighbouring monitor instead.
-- Plain `movewindow l/r` in scrolling layout would consume the neighbour
-- column (stack into it), so we detect the edge ourselves by comparing
-- column x positions.
local function move_h(swap_dir, cross_ws)
    return function()
        local ws = hl.get_active_workspace()
        if not ws then return end
        -- On DP-2 (ws 4, vertical), h/l are perpendicular to the scroll axis.
        -- SHIFT+l crosses back to DP-1; SHIFT+h has nowhere further left.
        if ws.id == 4 then
            if swap_dir == "r" then
                hl.dispatch(hl.dsp.window.move({ workspace = "previous" }))
            end
            return
        end
        local active = hl.get_active_window()
        if not active or not active.at then return end
        local ax = active.at.x
        local at_edge = true
        for _, w in ipairs(hl.get_workspace_windows(ws.id) or {}) do
            if w ~= active and w.at then
                if swap_dir == "l" and w.at.x < ax then at_edge = false; break end
                if swap_dir == "r" and w.at.x > ax then at_edge = false; break end
            end
        end
        if at_edge then
            if cross_ws then
                hl.dispatch(hl.dsp.window.move({ workspace = cross_ws }))
            end
        else
            hl.dispatch(hl.dsp.layout("swapcol " .. swap_dir))
        end
    end
end
hl.bind(mod .. " + SHIFT + h", move_h("l", 4))
hl.bind(mod .. " + SHIFT + l", move_h("r", nil))
-- Vertical column swap on DP-2 (ws 4, scrolling direction = down). The
-- scrolling layout indexes columns l/r along its scroll axis regardless of
-- visual direction, so u/d error with "no target (invalid direction?)".
-- With direction=down, next column (r) is below, previous column (l) is above.
-- swapcol carries the column width with it, so re-run arrange_ws4 afterwards
-- to keep the bottom window tall, then return focus to the window we moved.
-- Scoped to ws4: on DP-1 the horizontal swap lives on SHIFT+h/l (move_h).
local function swap_v(dir)
    return function()
        local ws = hl.get_active_workspace()
        if not ws or ws.id ~= 4 then return end
        hl.dispatch(hl.dsp.layout("swapcol " .. dir))
        local active = hl.get_active_window()
        arrange_ws4()
        if active then hl.dispatch(hl.dsp.focus({ window = active })) end
    end
end
hl.bind(mod .. " + SHIFT + j", swap_v("r"))
hl.bind(mod .. " + SHIFT + k", swap_v("l"))

--------------------------------------------------------------------
-- Binds: groups (0.55 unified into_or_create_group dispatcher)
--------------------------------------------------------------------
hl.bind(mod .. " + g",           hl.dsp.group.toggle())
hl.bind(mod .. " + n",           hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + i",   hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mod .. " + SHIFT + o",   hl.dsp.window.move({ out_of_group = "d" }))

--------------------------------------------------------------------
-- Binds: scrolling layout (DP-1)
-- i = consume (collapse into previous column),
-- o = expel (kick out into own column).
--------------------------------------------------------------------
hl.bind(mod .. " + i",           hl.dsp.layout("consume"))
hl.bind(mod .. " + o",           hl.dsp.layout("expel"))
hl.bind(mod .. " + period",      hl.dsp.layout("move +col"))      -- scroll layout right
hl.bind(mod .. " + comma",       hl.dsp.layout("move -col"))      -- scroll layout left
hl.bind(mod .. " + f",           hl.dsp.layout("fit active"))
hl.bind(mod .. " + SHIFT + f",   hl.dsp.layout("fit visible"))
hl.bind(mod .. " + bracketleft", hl.dsp.layout("colresize -conf")) -- cycle widths down
hl.bind(mod .. " + bracketright",hl.dsp.layout("colresize +conf")) -- cycle widths up
hl.bind(mod .. " + u",           hl.dsp.layout("promote"))

--------------------------------------------------------------------
-- Workspace overview: hyprview. Load the real checkout directly instead
-- of relying on package.path to resolve ~/.config/hypr/hyprview.
--------------------------------------------------------------------
dofile("/home/cjber/src/hyprview/init.lua").setup({
    bind                     = mod .. " + Tab",
    center_on_exit           = true,
    restore_focus_fit_method = 1, -- matches scrolling.focus_fit_method above
})

--------------------------------------------------------------------
-- Binds: workspaces (a/s/d for 1/2/3 on DP-1; ws4 lives on DP-2)
--------------------------------------------------------------------
hl.bind(mod .. " + a", hl.dsp.focus({ workspace = 1 }))
hl.bind(mod .. " + s", hl.dsp.focus({ workspace = 2 }))
hl.bind(mod .. " + d", hl.dsp.focus({ workspace = 3 }))

hl.bind(mod .. " + SHIFT + a", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mod .. " + SHIFT + s", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mod .. " + SHIFT + d", hl.dsp.window.move({ workspace = 3 }))

-- Back-and-forth to previous workspace (paired with workspace_back_and_forth=true).
hl.bind(mod .. " + w", hl.dsp.focus({ workspace = "previous" }))

-- Scratchpad: floating kitty on a special workspace. Spawned at hyprland.start
-- (below), routed here by the class-matched window rule, summoned with mod+t.
hl.bind(mod .. " + t", hl.dsp.workspace.toggle_special("scratch"))

--------------------------------------------------------------------
-- Binds: lid switch
--------------------------------------------------------------------
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("$lockscreen"), { locked = true })

--------------------------------------------------------------------
-- Resize submap
--------------------------------------------------------------------
hl.bind(mod .. " + y", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("l",      hl.dsp.layout("colresize +conf"), { repeating = true })
    hl.bind("h",      hl.dsp.layout("colresize -conf"), { repeating = true })
    hl.bind("r",      hl.dsp.layout("colresize 0.333"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Visual indicator: thick orange active border while in the resize submap.
hl.on("keybinds.submap", function(name)
    if name == "resize" then
        hl.config({ general = { border_size = 5, col = { active_border = C.primary } } })
    else
        hl.config({ general = { border_size = border_size, col = { active_border = C.secondary } } })
    end
end)

--------------------------------------------------------------------
-- Mouse binds
--------------------------------------------------------------------
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------
-- Autostart
--------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar --config /home/cjber/.config/waybar/main.jsonc")
    hl.exec_cmd("waybar --config /home/cjber/.config/waybar/side.jsonc")
    hl.exec_cmd("mako")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("udiskie &")
    -- hypridle, hyprpolkitagent, hyprsunset now started via systemd --user services
    -- Scratchpad command-center: 3 kittys routed to special:scratch by class.
    hl.exec_cmd("kitty --class scratch-cmd")
    hl.exec_cmd("kitty --class scratch-btm btm")
    hl.exec_cmd("kitty --class scratch-nvtop nvtop -P -i")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
end)
