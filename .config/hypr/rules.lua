-- rules.lua — Window rules, workspace rules, and layer rules
-- Merged from hyprland/rules.conf and custom/rules.conf

---------------------------------------------
---- GLOBAL / CONTEXT RULES -----------------
---------------------------------------------

-- Disable blur for xwayland context menus
hl.window_rule({
	name = "xwayland-no-blur",
	match = { class = "^()$", title = "^()$" },
	no_blur = true,
})

-- Obsidian: transparent background so Hyprland blur applies (same as kitty 0.8)
hl.window_rule({
	match = { class = "^obsidian$" },
	opacity = 0.8,
})

---------------------------------------------
---- FLOATING DIALOGS -----------------------
---------------------------------------------

-- Open/Save/Upload dialogs
local dialog_titles = {
	"^(Open File)(.*)$",
	"^(Select a File)(.*)$",
	"^(Choose wallpaper)(.*)$",
	"^(Open Folder)(.*)$",
	"^(Save As)(.*)$",
	"^(Library)(.*)$",
	"^(File Upload)(.*)$",
	"^(.*)(wants to save)$",
	"^(.*)(wants to open)$",
}

for _, pattern in ipairs(dialog_titles) do
	hl.window_rule({
		match = { title = pattern },
		float = true,
		center = true,
	})
end

-- Wallpaper chooser gets a specific size
hl.window_rule({
	match = { title = "^(Choose wallpaper)(.*)$" },
	size = "60% 65%",
})

---------------------------------------------
---- FLOATING APPS --------------------------
---------------------------------------------

hl.window_rule({
	name = "float-blueberry",
	match = { class = "^(blueberry\\.py)$" },
	float = true,
})

hl.window_rule({
	name = "float-guifetch",
	match = { class = "^(guifetch)$" },
	float = true,
})

-- Pavucontrol (GTK version)
hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "^(pavucontrol)$" },
	float = true,
	size = "45% 55%",
	center = true,
})

-- Pavucontrol (PulseAudio version)
hl.window_rule({
	name = "float-pavucontrol-org",
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	float = true,
	size = "45% 55%",
	center = true,
})

-- Network Manager connection editor
hl.window_rule({
	name = "float-nm-editor",
	match = { class = "^(nm-connection-editor)$" },
	float = true,
	size = "45% 55%",
	center = true,
})

-- KDE/Plasma windows
hl.window_rule({
	name = "float-plasma",
	match = { class = ".*plasmawindowed.*" },
	float = true,
})

hl.window_rule({
	name = "float-kcm",
	match = { class = "kcm_.*" },
	float = true,
})

hl.window_rule({
	name = "float-bluedevil",
	match = { class = ".*bluedevilwizard" },
	float = true,
})

hl.window_rule({
	name = "float-welcome",
	match = { title = ".*Welcome" },
	float = true,
})

hl.window_rule({
	name = "float-ii-settings",
	match = { title = "^(illogical-impulse Settings)$" },
	float = true,
})

hl.window_rule({
	name = "float-shell-conflicts",
	match = { title = ".*Shell conflicts.*" },
	float = true,
})

-- KDE file picker portal
hl.window_rule({
	name = "float-kde-portal",
	match = { class = "org.freedesktop.impl.portal.desktop.kde" },
	float = true,
	size = "60% 65%",
})

-- Zotero
hl.window_rule({
	name = "float-zotero",
	match = { class = "^(Zotero)$" },
	float = true,
	size = "45% 60%",
})

-- Yazi wallpaper picker
hl.window_rule({
	name = "float-yazi-picker",
	match = { class = "^(yazi-picker)$" },
	float = true,
	size = "60% 60%",
	center = true,
})

---------------------------------------------
---- MOVE / SUPPRESS NUISANCE WINDOWS ------
---------------------------------------------

hl.window_rule({
	name = "suppress-changeicons",
	match = { class = "^(plasma-changeicons)$" },
	float = true,
	no_initial_focus = true,
	move = "999999 999999",
})

hl.window_rule({
	name = "move-dolphin-copy",
	match = { title = "^(Copying — Dolphin)$" },
	move = "40 80",
})

---------------------------------------------
---- FORCED TILING --------------------------
---------------------------------------------

hl.window_rule({
	name = "tile-warp",
	match = { class = "^dev\\.warp\\.Warp$" },
	tile = true,
})

---------------------------------------------
---- PICTURE-IN-PICTURE ---------------------
---------------------------------------------

hl.window_rule({
	name = "pip-float",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = "73% 72%",
	size = "25% 14%",
})

---------------------------------------------
---- TEARING / IMMEDIATE --------------------
---------------------------------------------

hl.window_rule({
	name = "tearing-exe",
	match = { title = ".*\\.exe" },
	immediate = true,
})

hl.window_rule({
	name = "tearing-minecraft",
	match = { title = ".*minecraft.*" },
	immediate = true,
})

hl.window_rule({
	name = "tearing-steam",
	match = { class = "^(steam_app).*" },
	immediate = true,
})

---------------------------------------------
---- JETBRAINS IDE FOCUS FIX ----------------
---------------------------------------------

hl.window_rule({
	name = "jetbrains-focus-fix",
	match = { class = "^jetbrains-.*$", float = true, title = "^$" },
	no_initial_focus = true,
})

---------------------------------------------
---- NO SHADOW FOR TILED WINDOWS -----------
---------------------------------------------

hl.window_rule({
	name = "tiled-no-shadow",
	match = { float = false },
	no_shadow = true,
})

---------------------------------------------
---- WORKSPACE RULES ------------------------
---------------------------------------------

-- Special workspace styling
hl.workspace_rule({
	workspace = "special:special",
	gaps_out = 30,
})

-- ROS2 and Foxglove visualization → workspace 3
hl.window_rule({
	name = "ros2-rviz-ws3",
	match = { class = "^(rviz2)$" },
	workspace = "3",
})

hl.window_rule({
	name = "foxglove-ws3",
	match = { class = "^(foxglove)$" },
	workspace = "3",
})

---------------------------------------------
---- LAYER RULES (disabled, ready to use) --
---------------------------------------------

-- Uncomment as needed:
-- hl.layer_rule({ match = { namespace = "waybar" },        blur = true })
-- hl.layer_rule({ match = { namespace = "selection" },     no_anim = true })
-- hl.layer_rule({ match = { namespace = "overview" },      no_anim = true })
-- hl.layer_rule({ match = { namespace = "anyrun" },        no_anim = true })
-- hl.layer_rule({ match = { namespace = "launcher" },      blur = true, ignore_alpha = 0.5 })
-- hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.69 })
-- hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
