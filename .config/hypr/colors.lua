-- colors.lua — Color palette derived from kitty's current theme
-- Theme: Kanagawa-inspired (matching kitty terminal colors)

---------------------------------
---- KITTY COLOR REFERENCE -----
---------------------------------
-- background   = #000000
-- foreground   = #C5C9C7
-- color0       = #0d0c0c  (black)
-- color1       = #c4746e  (red)
-- color2       = #8a9a7b  (green)
-- color3       = #c4b28a  (yellow)
-- color4       = #8ba4b0  (blue)
-- color5       = #a292a3  (magenta)
-- color6       = #8ea4a2  (cyan)
-- color7       = #C8C093  (white)
-- color8       = #A4A7A4  (bright black / gray)
-- color9       = #E46876  (bright red)
-- color10      = #87a987  (bright green)
-- color11      = #E6C384  (bright yellow)
-- color12      = #7FB4CA  (bright blue)
-- color13      = #938AA9  (bright magenta)
-- color14      = #7AA89F  (bright cyan)
-- color15      = #C5C9C7  (bright white)
-- active_border  = #4f4f68
-- inactive_border= #000000

---------------------------------
---- HYPRLAND COLOR CONFIG -----
---------------------------------

-- Border colors (from kitty active/inactive border)
hl.config({
	general = {
		col = {
			active_border = "rgba(4f4f68FF)",
			inactive_border = "rgba(00000000)",
		},
	},

	-- Background color
	misc = {
		background_color = "rgba(000000FF)",
	},
})

-- Plugin colors (hyprbars)
-- hl.config({
--     plugin = {
--         hyprbars = {
--             -- Font matching kitty
--             bar_text_font = "CaskaydiaCove Nerd Font, Rubik, Geist, AR One Sans, Inter, Roboto, sans-serif",
--             bar_height = 30,
--             bar_padding = 10,
--             bar_button_padding = 5,
--             bar_precedence_over_border = true,
--             bar_part_of_window = true,
--
--             -- Colors matched to kitty theme
--             bar_color = "rgba(000000FF)",           -- kitty background
--             col = {
--                 text = "rgba(C5C9C7FF)",            -- kitty foreground
--             },
--
--             -- Buttons using accent color (kitty active_border)
--             hyprbars_button = {
--                 { color = "rgb(82edde)", size = 13, icon = "󰖭", on_click = "hyprctl dispatch killactive" },
--                 { color = "rgb(82edde)", size = 13, icon = "󰖯", on_click = "hyprctl dispatch fullscreen 1" },
--                 { color = "rgb(82edde)", size = 13, icon = "󰖰", on_click = "hyprctl dispatch movetoworkspacesilent special" },
--             },
--         },
--     },
-- })

-- Pinned window border (using accent color)
hl.window_rule({
	name = "pinned-window-border",
	match = { pin = true },
	border_color = { colors = { "rgba(82eddeAA)", "rgba(82edde77)" } },
})
