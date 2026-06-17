-- env.lua — Environment variables
-- Merged from hyprland/env.conf and custom/env.conf

--------------------------------------
---- INPUT METHODS (Wayland) ---------
--------------------------------------
-- Uncomment if you need input method support (e.g., for CJK input)
-- hl.env("QT_IM_MODULE", "fcitx")
-- hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("SDL_IM_MODULE", "fcitx")
-- hl.env("GLFW_IM_MODULE", "ibus")
-- hl.env("INPUT_METHOD", "fcitx")

--------------------------------------
---- WAYLAND / ELECTRON --------------
--------------------------------------
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

--------------------------------------
---- THEMES / QT / PLASMA -----------
--------------------------------------
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

--------------------------------------
---- WAYLAND TWEAKS (optional) ------
--------------------------------------
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")

--------------------------------------
---- TERMINAL ------------------------
--------------------------------------
hl.env("TERMINAL", "/home/dhruvpotdar/.local/kitty.app/bin/kitty -1")
