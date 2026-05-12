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
hl.env("__GL_VRR_ALLOWED",           "0")
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
hl.monitor({ output = "HDMI-A-1", disabled = true })

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
    scrolling = {
        fullscreen_on_one_column = true,
        column_width             = 0.5,     -- DP-1 default: 2 cols visible
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
        vrr                          = 0,
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
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 3, bezier = "fade" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 3, bezier = "fade" })
hl.animation({ leaf = "border",           enabled = true, speed = 2, bezier = "smooth" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "snappy", style = "fade" })

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

--------------------------------------------------------------------
-- Layer rules
--------------------------------------------------------------------
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.5 })

--------------------------------------------------------------------
-- Window rules
-- confine_pointer: pin the cursor to a window. Add for games as needed.
-- e.g.: hl.window_rule({ match = { class = "steam_app_.*" }, confine_pointer = true })
--------------------------------------------------------------------
-- Vertical monitor (workspace 4): new windows default to 1/3 height.
hl.window_rule({ match = { workspace = "4" }, scrolling_width = 0.333 })

--------------------------------------------------------------------
-- Binds: apps
--------------------------------------------------------------------
hl.bind(mod .. " + Return",         hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + semicolon",      hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mod .. " + M",              hl.dsp.exec_cmd("hyprlauncher --toggle"))
hl.bind(mod .. " + V",              hl.dsp.exec_cmd("hyprpwcenter"))
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

-- Move window
hl.bind(mod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

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
hl.bind(mod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mod .. " + SHIFT + comma",  hl.dsp.layout("swapcol l"))
hl.bind(mod .. " + f",           hl.dsp.layout("fit active"))
hl.bind(mod .. " + SHIFT + f",   hl.dsp.layout("fit visible"))
hl.bind(mod .. " + bracketleft", hl.dsp.layout("colresize -conf")) -- cycle widths down
hl.bind(mod .. " + bracketright",hl.dsp.layout("colresize +conf")) -- cycle widths up
hl.bind(mod .. " + u",           hl.dsp.layout("promote"))

--------------------------------------------------------------------
-- Binds: window switcher
--------------------------------------------------------------------
hl.bind(mod .. " + Tab",         hl.dsp.exec_cmd("hyprswitch simple --sort-recent true"))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.exec_cmd("hyprswitch simple --sort-recent true --reverse"))

--------------------------------------------------------------------
-- Binds: workspaces (a/s/d for 1/2/3 on DP-1; ws4 lives on DP-2)
--------------------------------------------------------------------
hl.bind(mod .. " + a", hl.dsp.focus({ workspace = 1 }))
hl.bind(mod .. " + s", hl.dsp.focus({ workspace = 2 }))
hl.bind(mod .. " + d", hl.dsp.focus({ workspace = 3 }))

hl.bind(mod .. " + SHIFT + a", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mod .. " + SHIFT + s", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mod .. " + SHIFT + d", hl.dsp.window.move({ workspace = 3 }))

--------------------------------------------------------------------
-- Binds: lid switch
--------------------------------------------------------------------
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("$lockscreen"), { locked = true })

--------------------------------------------------------------------
-- Resize submap
--------------------------------------------------------------------
hl.bind(mod .. " + y", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("l",      hl.dsp.window.resize({ x = 200,  y = 0,   relative = true }), { repeating = true })
    hl.bind("h",      hl.dsp.window.resize({ x = -200, y = 0,   relative = true }), { repeating = true })
    hl.bind("k",      hl.dsp.window.resize({ x = 0,    y = -50, relative = true }), { repeating = true })
    hl.bind("j",      hl.dsp.window.resize({ x = 0,    y = 50,  relative = true }), { repeating = true })
    hl.bind("r",      hl.dsp.layout("colresize 0.5"))
    hl.bind("escape", hl.dsp.submap("reset"))
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
    hl.exec_cmd("hyprlauncher --daemon")  -- preload for instant launcher open
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
end)
