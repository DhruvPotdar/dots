# Hyprland Config Features To-Do List

A comprehensive checklist of all features, behaviors, and configurations present in the Hyprland setup, including all missing scripts and custom configs.

**Currently working on: Full Lua port with kitty color/font matching**

## Environment & System
- [x] Wayland/Electron ozone hints (`ELECTRON_OZONE_PLATFORM_HINT`)
- [x] Qt / KDE Plasma theme integration (`QT_QPA_PLATFORM`, `QT_QPA_PLATFORMTHEME`, `XDG_MENU_PREFIX`)
- [x] Default Terminal variable (`kitty`)

## Autostart / Execs
- [x] Secrets/Keyring daemon (`gnome-keyring-daemon`)
- [x] Wallpaper manager (`hyprpaper` & `swww-daemon`)
- [x] Status bar (`waybar`)
- [x] System tray applets (`nm-applet`, `blueman-applet`)
- [x] Idle daemon (`hypridle`)
- [x] DBus activation environment variables update
- [x] Hyprland plugin manager reload (`hyprpm reload`)
- [x] Audio effects daemon (`easyeffects`)
- [x] Clipboard history watcher (`wl-paste` & `cliphist`)
- [x] Cursor theme setup (`Bibata-Modern-Classic`)

## General Layout & Aesthetics
- [x] Monitor configuration (eDP-1, resolution, refresh rate)
- [x] Gaps (in/out/workspaces) and Borders (size, colors, resize on border)
- [x] Tearing support (`allow_tearing`)
- [x] Window snapping functionality (window gap, monitor gap)
- [x] Dwindle layout config (`preserve_split`, `smart_split`)
- [x] Window rounding
- [x] Blur effects (xray, passes, sizes, disabled on xwayland menus)
- [x] Shadows & Dimming
- [x] Custom Bezier curves and Animations (`windowsIn`, `windowsOut`, `workspaces`, etc.)
- [x] Hyprbars plugin configuration (font, colors, buttons)
- [x] Hyprexpo plugin configuration (columns, gap, bg)

## Input & Gestures
- [x] Keyboard layout (`us`), repeat rate/delay
- [x] Mouse sensitivity, acceleration, and VRR
- [x] Touchpad settings (natural scroll, clickfinger, disable while typing)
- [x] Workspace swipe gestures (distance, fingers, swipe to move, create new)

## Window Rules & Workspaces
- [x] Context menus styling fix (disable blur on xwayland menus)
- [x] Floating dialogs rules (File pickers, Save As, portals, extensions)
- [x] Specific floating apps (`blueberry.py`, `pavucontrol`, `nm-connection-editor`, Zotero, KDE portals)
- [x] Forced tiling apps (`dev.warp.Warp`)
- [x] Picture-in-Picture mode (Float, pin, keep aspect ratio, specific sizing/positioning)
- [x] Tearing/Immediate mode for games (`.exe`, `minecraft`, `steam_app`)
- [x] JetBrains IDE focus fix (`no_initial_focus`)
- [x] Tiled windows shadow disabled (`no_shadow`)
- [x] Special workspace styling (`gapsout:30`)
- [x] Custom ROS2 / Foxglove workspace rules (`workspace 3`)

## Keybinds
- [x] **Shell**: App Launcher (`fuzzel`), Waybar toggle, Session menu (`wlogout`), Volume/Brightness keys
- [x] **Utilities**: Clipboard picker, Emoji picker, Screen snip (`hyprshot`/`swappy`), Color picker (`hyprpicker`), Google Lens script, OCR script
- [x] **Window Management**: Move/resize with mouse, Focus movement, Window movement, Close/Zap window, Toggle floating, Maximize/Fullscreen, Pin
- [x] **Workspaces**: Move window to workspace, Switch workspace, Toggle scratchpad
- [x] **Session**: Lock session (`hyprlock`), Power off
- [x] **Media Controls**: Playerctl next/prev/play-pause
- [x] **App Launchers**: Kitty, File manager, Browser, Code editor, System monitor, Volume mixer
- [x] **Custom Overrides**: Edit shell config, Edit extra keybinds

## Scripts & Extras
- [x] `fuzzel-emoji.sh`: Emoji picker integration
- [x] `snip_to_search.sh`: Screen snip to Google Lens search
- [x] `record-screen.sh`: Screen recording functionality
- [x] `wallpaper_picker.sh`: GUI Wallpaper selector
- [x] `zoom.sh`: Desktop Zoom in/out via `hyprctl misc:cursor:zoom_factor`
- [x] `__restore_video_wallpaper.sh`: Restore video wallpaper (commented out)
- [x] `start_geoclue_agent.sh`: Geolocation agent (commented out)
- [x] `workspace_action.sh`: Advanced workspace management
- [x] `launch_first_available.sh`: Fallback app launcher
- [x] `check-capslock.sh`: Caps lock warning for lock screen
- [x] `status.sh`: System status query for lock screen
- [x] **AI Scripts**: `show-loaded-ollama-models.sh` and `primary-buffer-query.sh`

## Supporting Services
- [x] `hypridle`: Suspend, DPMS off, and Lock triggers
- [x] `hyprlock`: Custom lock screen design, widgets, and dynamic lock labels
- [x] `nwg-displays`: Workspaces and Monitors auto-configuration (`workspaces.conf`, `monitors.conf`)

---

## Additional Changes (Lua Port)
- [x] Ported entire configuration from `hyprlang` (.conf) to Lua (.lua)
- [x] Removed `custom/` folder — all configs merged into respective Lua files
- [x] Changed font to `CaskaydiaCove Nerd Font` (matching kitty config)
- [x] Updated all colors to match kitty's Kanagawa-inspired theme
- [x] Updated hyprlock colors and font to match kitty
- [x] Updated hyprlock background to match kitty (#000000)
- [x] All scripts copied to new `~/.config/hypr-lua/scripts/` directory
- [x] All script paths updated in keybinds
