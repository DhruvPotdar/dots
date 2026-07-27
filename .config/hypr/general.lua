-- ===========================================================================
-- general.lua — Hyprland general configuration (ported from hyprland.conf)
-- Covers: monitor, gestures, general, dwindle, decoration, animations,
--         input, misc, binds, cursor
-- Does NOT include: keybinds, window rules, exec, env, or plugins
-- ===========================================================================

-- ── Monitor ─────────────────────────────────────────────────────────────────
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1.0,
})

-- Mirror any additional display onto eDP-1 instead of extending
hl.monitor({
    output = "",
    mode   = "preferred",
    mirror = "eDP-1",
})

-- ── Gestures (three-finger / four-finger) ───────────────────────────────────
hl.gesture({ fingers = 3, direction = "pinch",      action = "float"      })
hl.gesture({ fingers = 3, direction = "horizontal",  action = "workspace"  })
hl.gesture({ fingers = 4, direction = "swipe",       action = "move"       })

-- ── Gestures section (workspace swipe tuning) ───────────────────────────────
hl.config({
    gestures = {
        workspace_swipe_distance                = 700,
        workspace_swipe_cancel_ratio            = 0.2,
        workspace_swipe_min_speed_to_force      = 5,
        workspace_swipe_direction_lock           = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new               = true,
    },
})

-- ── General ─────────────────────────────────────────────────────────────────
hl.config({
    general = {
        gaps_in            = 4,
        gaps_out           = 5,
        gaps_workspaces    = 50,
        border_size        = 1,
        col = {
            active_border   = "rgba(4f4f68FF)",    -- kitty active_border_color
            inactive_border = "rgba(00000000)",    -- fully transparent, no border
        },
        resize_on_border   = true,
        no_focus_fallback  = true,
        allow_tearing      = true,

        snap = {
            enabled      = true,
            window_gap   = 4,
            monitor_gap  = 5,
            respect_gaps = true,
        },
    },
})

-- ── Dwindle layout ──────────────────────────────────────────────────────────
hl.config({
    dwindle = {
        preserve_split  = true,
        smart_split     = false,
        smart_resizing  = false,
    },
})

-- ── Decoration (rounding, blur, shadow, dim) ────────────────────────────────
hl.config({
    decoration = {
        rounding = 10,

        blur = {
            enabled            = true,
            xray               = true,
            special            = false,
            new_optimizations  = true,
            size               = 14,
            passes             = 3,
            brightness         = 1,
            noise              = 0.04,
            contrast           = 1,
            popups             = false,
            popups_ignorealpha = 0.6,
            input_methods              = true,
            input_methods_ignorealpha  = 0.8,
        },

        shadow = {
            enabled      = false,
            range        = 30,
            offset       = { 0, 2 },       -- vec2
            render_power = 4,
            color        = "rgba(00000010)",
        },

        dim_inactive = false,
        dim_strength = 0.025,
        dim_special  = 0.07,
    },
})

-- ── Animations ──────────────────────────────────────────────────────────────

-- Enable the animation system
hl.config({
    animations = {
        enabled = true,
    },
})

-- Bezier curves -----------------------------------------------------------
hl.curve("expressiveFastSpatial",    { type = "bezier", points = {{ 0.42, 1.67 }, { 0.21, 0.90 }} })
hl.curve("expressiveSlowSpatial",    { type = "bezier", points = {{ 0.39, 1.29 }, { 0.35, 0.98 }} })
hl.curve("expressiveDefaultSpatial", { type = "bezier", points = {{ 0.38, 1.21 }, { 0.22, 1.00 }} })
hl.curve("emphasizedDecel",          { type = "bezier", points = {{ 0.05, 0.70 }, { 0.10, 1.00 }} })
hl.curve("emphasizedAccel",          { type = "bezier", points = {{ 0.30, 0.00 }, { 0.80, 0.15 }} })
hl.curve("standardDecel",            { type = "bezier", points = {{ 0.00, 0.00 }, { 0.00, 1.00 }} })
hl.curve("menu_decel",               { type = "bezier", points = {{ 0.10, 1.00 }, { 0.00, 1.00 }} })
hl.curve("menu_accel",               { type = "bezier", points = {{ 0.52, 0.03 }, { 0.72, 0.08 }} })

-- Animation rules ---------------------------------------------------------
-- windowsIn / windowsOut / windowsMove
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3,  bezier = "emphasizedDecel", style = "popin 80%"  })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,  bezier = "emphasizedDecel", style = "popin 90%"  })
hl.animation({ leaf = "windowsMove",enabled = true, speed = 3,  bezier = "emphasizedDecel", style = "slide"      })

-- border
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "emphasizedDecel" })

-- layers
hl.animation({ leaf = "layersIn",   enabled = true, speed = 2.7, bezier = "emphasizedDecel", style = "popin 93%" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 2.4, bezier = "menu_accel",      style = "popin 94%" })

-- fade layers
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.5, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.7, bezier = "menu_accel" })

-- workspaces
hl.animation({ leaf = "workspaces",          enabled = true, speed = 7,   bezier = "menu_decel",      style = "slide"     })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2.8, bezier = "emphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.2, bezier = "emphasizedAccel", style = "slidevert" })

-- ── Input ───────────────────────────────────────────────────────────────────
hl.config({
    input = {
        kb_layout              = "us",
        numlock_by_default     = true,
        sensitivity            = 0.5,
        accel_profile          = "flat",
        repeat_delay           = 250,
        repeat_rate            = 35,
        follow_mouse           = 1,
        off_window_axis_events = 2,

        touchpad = {
            natural_scroll      = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.5,
        },
    },
})

-- ── Misc ────────────────────────────────────────────────────────────────────
hl.config({
    misc = {
        disable_hyprland_logo        = false,
        disable_splash_rendering     = false,
        vrr                          = 1,
        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,
        enable_swallow               = false,
        swallow_regex                = "(foot|kitty|allacritty|Alacritty)",
        allow_session_lock_restore   = true,
        session_lock_xray            = true,
        initial_workspace_tracking   = false,
        focus_on_activate            = true,
        background_color             = "rgba(000000FF)",          -- match kitty
        font_family                  = "CaskaydiaCove Nerd Font", -- match kitty
    },
})

-- ── Binds ───────────────────────────────────────────────────────────────────
hl.config({
    binds = {
        scroll_event_delay               = 0,
        hide_special_on_workspace_change = true,
    },
})

-- ── Cursor ──────────────────────────────────────────────────────────────────
hl.config({
    cursor = {
        zoom_factor     = 1,
        zoom_rigid      = false,
        hotspot_padding = 1,
    },
})
