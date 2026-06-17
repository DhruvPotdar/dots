-- hyprland.lua — Main entry point
-- Equivalent to hyprland.conf; sources all other config modules in order.

-- ── Core config ──────────────────────────────────────────────────────────────
require("env")
require("execs")
require("general")
require("rules")
require("colors")
require("keybinds")
require("plugins")
