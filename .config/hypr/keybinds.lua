-- keybinds.lua
-- Hyprland keybinds configuration (ported to Lua API)
-- Ported from hyprland/keybinds.conf and custom/keybinds.conf

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local home = os.getenv("HOME")
local scriptDir = home .. "/.config/hypr/scripts"
local kitty = "/home/dhruvpotdar/.local/kitty.app/bin/kitty"
local launchScript = scriptDir .. "/launch_first_available.sh"
local workspaceScript = scriptDir .. "/workspace_action.sh"
local screenshots = require("screenshots")

-- Reusable command fragments
local playerctlNext =
	[[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]

-- Keycode tables for workspace loops
-- Number row: code:10 = 1, code:11 = 2, ..., code:18 = 9, code:19 = 0 (workspace 10)
-- Keypad:     code:87 = KP_1, code:88 = KP_2, ..., code:95 = KP_9, code:96 = KP_0 (workspace 10)
local numberKeycodes = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
local keypadKeycodes = { 87, 88, 89, 90, 91, 92, 93, 94, 95, 96 }

--------------------------------------------------------------------------------
--! Shell
--------------------------------------------------------------------------------

-- App launcher (fuzzel)
hl.bind("SUPER + A", hl.dsp.exec_cmd("pkill fuzzel || fuzzel"))

-- Toggle waybar
hl.bind("SUPER + J", hl.dsp.exec_cmd("pkill -USR1 waybar"), { description = "Toggle bar" })

-- Logout menu
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("pkill wlogout || wlogout -p layer-shell"))

-- Brightness controls
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Volume controls
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
	{ locked = true, repeating = true }
)

-- Audio mute (sink)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind(
	"SUPER + SHIFT + M",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"),
	{ locked = true, description = "Toggle mute" }
)

-- Mic mute (source)
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind(
	"SUPER + ALT + M",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"),
	{ locked = true, description = "Toggle mic" }
)

-- Wallpaper picker
hl.bind(
	"CTRL + SUPER + T",
	hl.dsp.exec_cmd(scriptDir .. "/wallpaper_picker.sh"),
	{ description = "Toggle wallpaper selector" }
)

--------------------------------------------------------------------------------
--! Utilities
--------------------------------------------------------------------------------

-- Clipboard history (via cliphist + fuzzel)
hl.bind(
	"SUPER + V",
	hl.dsp.exec_cmd("pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"),
	{ description = "Copy clipboard history entry" }
)

-- Emoji picker
hl.bind(
	"SUPER + Period",
	hl.dsp.exec_cmd("pkill fuzzel || " .. scriptDir .. "/fuzzel-emoji.sh copy"),
	{ description = "Copy an emoji" }
)

-- Screenshots (grim/slurp via screenshots.lua)
screenshots.bind()

-- Color picker
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color picker" })

-- Screen recording (region moved off Super+Shift+S to avoid screenshot conflict)
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(scriptDir .. "/record-screen.sh full"))
hl.bind(
	"SUPER + SHIFT + ALT + R",
	hl.dsp.exec_cmd(scriptDir .. "/record-screen.sh region"),
	{ description = "Record screen region" }
)
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd(scriptDir .. "/record-screen.sh stop"))

--------------------------------------------------------------------------------
--! Window Management
--------------------------------------------------------------------------------

-- Mouse: drag/move window
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })

-- Mouse: resize window
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move focus: arrow keys
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "down" }))

-- Move focus: bracket keys
hl.bind("SUPER + BracketLeft", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + BracketRight", hl.dsp.focus({ direction = "right" }))

-- Move window in direction (via hyprctl fallback)
hl.bind("SUPER + ALT + Left", hl.dsp.exec_cmd("hyprctl dispatch movewindow l"))
hl.bind("SUPER + ALT + Right", hl.dsp.exec_cmd("hyprctl dispatch movewindow r"))
hl.bind("SUPER + ALT + Up", hl.dsp.exec_cmd("hyprctl dispatch movewindow u"))
hl.bind("SUPER + ALT + Down", hl.dsp.exec_cmd("hyprctl dispatch movewindow d"))

-- Close active window
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Force kill window (xkill-style)
hl.bind("SUPER + SHIFT + ALT + Q", hl.dsp.window.kill())

-- Resize active window (via hyprctl fallback, repeating)
hl.bind("SUPER + Semicolon", hl.dsp.exec_cmd("hyprctl dispatch resizeactive -80 0"), { repeating = true })
hl.bind("SUPER + Apostrophe", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 80 0"), { repeating = true })

-- Toggle floating
hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" }))

-- Fullscreen: maximize (keeps bar visible)
hl.bind("SUPER + D", hl.dsp.window.fullscreen(1))

-- Fullscreen: true fullscreen
hl.bind("SUPER + F", hl.dsp.window.fullscreen(0))

-- Fullscreen state: internal=0, client=3
-- hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen_state(0, 3))

-- Pin window (stays on all workspaces)
hl.bind("SUPER + P", hl.dsp.window.pin())

--------------------------------------------------------------------------------
--! Move Window to Workspace
--------------------------------------------------------------------------------

-- Number row and keypad: move active window to workspace 1-10 (silent)
for i = 1, 10 do
	local ws = tostring(i)

	-- Number row (code:10 through code:19)
	hl.bind("SUPER + SHIFT + code:" .. numberKeycodes[i], hl.dsp.window.move({ workspace = ws, silent = true }))

	-- Keypad (code:87 through code:96)
	hl.bind("SUPER + SHIFT + code:" .. keypadKeycodes[i], hl.dsp.window.move({ workspace = ws, silent = true }))
end

-- Move window to relative workspace: mouse scroll
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))

-- Move window to adjacent workspace: page keys
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("SUPER + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "r-1" }))

-- Move window to relative workspace: Ctrl+Super+Shift + arrows
hl.bind("CTRL + SUPER + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("CTRL + SUPER + SHIFT + Left", hl.dsp.window.move({ workspace = "r-1" }))

-- Move window to special workspace (silent — doesn't follow)
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special", silent = true }))

-- Toggle special workspace visibility (from move section in original conf)
hl.bind("CTRL + SUPER + S", hl.dsp.workspace.toggle_special())

--------------------------------------------------------------------------------
--! Workspace Navigation
--------------------------------------------------------------------------------

-- Number row and keypad: switch to workspace 1-10
for i = 1, 10 do
	local ws = tostring(i)

	-- Number row (code:10 through code:19)
	hl.bind("SUPER + code:" .. numberKeycodes[i], hl.dsp.focus({ workspace = ws }))

	-- Keypad (code:87 through code:96) — non-consuming so numpad still works
	hl.bind("SUPER + code:" .. keypadKeycodes[i], hl.dsp.focus({ workspace = ws }), { non_consuming = true })
end

-- Relative workspace: Ctrl+Super + arrows
hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + SUPER + Left", hl.dsp.focus({ workspace = "r-1" }))

-- Monitor-relative workspace: Ctrl+Super+Alt + arrows
hl.bind("CTRL + SUPER + ALT + Right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("CTRL + SUPER + ALT + Left", hl.dsp.focus({ workspace = "m-1" }))

-- Adjacent workspace: page keys
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + SUPER + Page_Down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + SUPER + Page_Up", hl.dsp.focus({ workspace = "r-1" }))

-- Workspace navigation: mouse scroll
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "r-1" }))

-- Toggle special workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special())
hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special())

-- Bracket keys workspace navigation
hl.bind("CTRL + SUPER + BracketLeft", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + SUPER + BracketRight", hl.dsp.focus({ workspace = "+1" }))

-- Jump 5 workspaces
hl.bind("CTRL + SUPER + Up", hl.dsp.focus({ workspace = "r-5" }))
hl.bind("CTRL + SUPER + Down", hl.dsp.focus({ workspace = "r+5" }))

--------------------------------------------------------------------------------
--! Session
--------------------------------------------------------------------------------

-- Lock screen
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock" })

-- Shutdown
hl.bind(
	"CTRL + SHIFT + ALT + SUPER + Delete",
	hl.dsp.exec_cmd("systemctl poweroff || loginctl poweroff"),
	{ description = "Shutdown" }
)

--------------------------------------------------------------------------------
--! Screen (Zoom)
--------------------------------------------------------------------------------

hl.bind("SUPER + Minus", hl.dsp.exec_cmd(scriptDir .. "/zoom.sh decrease 0.1"), { repeating = true })
hl.bind("SUPER + Equal", hl.dsp.exec_cmd(scriptDir .. "/zoom.sh increase 0.1"), { repeating = true })

--------------------------------------------------------------------------------
--! Media
--------------------------------------------------------------------------------

-- Next track
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(playerctlNext), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(playerctlNext), { locked = true })

-- Previous track
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + ALT + mouse:275", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Next track: mouse extra button
hl.bind("SUPER + SHIFT + ALT + mouse:276", hl.dsp.exec_cmd(playerctlNext))

-- Play / Pause
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

--------------------------------------------------------------------------------
--! Apps
--------------------------------------------------------------------------------

-- Terminal (kitty)
hl.bind("SUPER + Return", hl.dsp.exec_cmd(kitty))

-- File manager
hl.bind(
	"SUPER + E",
	hl.dsp.exec_cmd(launchScript .. [[ "nautilus" "nemo" "thunar" "${TERMINAL}" "kitty -1 fish -c yazi"]])
)

-- Web browser
hl.bind(
	"SUPER + W",
	hl.dsp.exec_cmd(
		launchScript
			.. [[ "zen-browser" "google-chrome-stable" "firefox" "brave" "chromium" "microsoft-edge-stable" "opera" "librewolf"]]
	)
)

-- Code editor
hl.bind(
	"SUPER + C",
	hl.dsp.exec_cmd(
		launchScript
			.. [[ "code" "codium" "cursor" "zed" "zedit" "zeditor" "kate" "gnome-text-editor" "emacs" "command -v nvim && kitty -1 nvim" "command -v micro && kitty -1 micro"]]
	)
)

-- Secondary terminal (kitty single-instance)
hl.bind("SUPER + X", hl.dsp.exec_cmd(kitty .. " -1"))

-- Audio settings (pavucontrol)
hl.bind("CTRL + SUPER + V", hl.dsp.exec_cmd(launchScript .. [[ "pavucontrol-qt" "pavucontrol"]]))

-- System settings
hl.bind(
	"SUPER + I",
	hl.dsp.exec_cmd(
		"XDG_CURRENT_DESKTOP=gnome " .. launchScript .. [[ "systemsettings" "gnome-control-center" "better-control"]]
	)
)

-- System monitor
hl.bind(
	"CTRL + SHIFT + Escape",
	hl.dsp.exec_cmd(
		launchScript
			.. [[ "gnome-system-monitor" "plasma-systemmonitor --page-name Processes" "command -v btop && kitty -1 fish -c btop"]]
	)
)

-- Resize window to exact 640x480 (via hyprctl fallback)
hl.bind("CTRL + SUPER + Backslash", hl.dsp.exec_cmd("hyprctl dispatch resizeactive exact 640 480"))

--------------------------------------------------------------------------------
--! Custom Keybinds (ported from custom/keybinds.conf)
--------------------------------------------------------------------------------

-- Open illogical-impulse config
hl.bind("CTRL + SUPER + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/illogical-impulse/config.json"))

-- Open this keybinds file (updated path from old hypr/custom/keybinds.conf)
hl.bind("CTRL + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/hypr-lua/keybinds.lua"))
