-- execs.lua — Autostart commands (exec-once equivalents)
-- Merged from hyprland/execs.conf and custom/execs.conf

--------------------------------------
---- STARTUP (run once) -------------
--------------------------------------
hl.on("hyprland.start", function()
    -- Core components (authentication, lock screen)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/libexec/hyprpolkitagent &")

    -- Wallpaper managers
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("swww-daemon &")

    -- Status bar
    hl.exec_cmd("waybar &")

    -- System tray applets
    hl.exec_cmd("nm-applet --indicator &")
    hl.exec_cmd("blueman-applet &")

    -- Idle daemon
    hl.exec_cmd("hypridle")

    -- DBus activation environment variables
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Hyprland plugin manager
    hl.exec_cmd("hyprpm reload")

    -- Audio effects
    hl.exec_cmd("easyeffects --hide-window --service-mode")

    -- Clipboard history
    hl.exec_cmd("wl-paste --watch cliphist store &")

    -- Cursor theme
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

    -- Input method (uncomment if needed)
    -- hl.exec_cmd("fcitx5")

    -- Geoclue agent (uncomment if needed)
    -- hl.exec_cmd("~/.config/hypr-lua/scripts/start_geoclue_agent.sh")

    -- Video wallpaper restore (uncomment if needed)
    -- hl.exec_cmd("~/.config/hypr-lua/scripts/__restore_video_wallpaper.sh")
end)
