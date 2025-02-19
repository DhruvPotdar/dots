---@class Base46Table
local M = {}

M.base_30 = {
  white = "#C6DFEC",
  darker_black = "#060914",
  black = "#11121D", -- nvim bg
  black2 = "#121520",
  one_bg = "#1D202B",
  one_bg2 = "#343742",
  one_bg3 = "#343742",
  grey = "#656771",
  grey_fg = "#878996",
  grey_fg2 = "#A7A9B5",
  light_grey = "#BDBFCB",
  red = "#F05C60",
  baby_pink = "#DA72A2",
  pink = "#B4647F",
  line = "#343742",
  green = "#80AA6E",
  vibrant_green = "#9CB67D",
  nord_blue = "#788AD3",
  blue = "#597BC0",
  yellow = "#b4647f",
  sun = "#D6B476",
  purple = "#A188C3",
  dark_purple = "#8D3F5A",
  teal = "#85C7B8",
  orange = "#D29146",
  cyan = "#7AA8A7",
  statusline_bg = "#161722",
  lightbg = "#121520",
  pmenu_bg = "#a188c3",
  folder_bg = "#597BC0",
}

M.base_16 = {
  base00 = "#060914",
  base01 = "#0C0F1A",
  base02 = "#121520",
  base03 = "#1D202B",
  base04 = "#343742",
  base05 = "#A7A9B5",
  base06 = "#BDBFCB",
  base07 = "#C6DFEC",
  base08 = "#F05C60",
  base09 = "#597BC0",
  base0A = "#DA72A2",
  base0B = "#d6b476",
  base0C = "#A188C3",
  base0D = "#4FA6FF",
  base0E = "#6EC3C9",
  base0F = "#D29146",
}

M.polish_hl = {
  defaults = {
    Directory = {
      fg = "#a485dd",
      italic = true,
    },
  },

  treesitter = {
    ["@string"] = { fg = M.base_16.base0C }, -- Sets strings to blue
  },
}
M.type = "dark"
return M
