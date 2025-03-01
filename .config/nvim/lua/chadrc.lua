---@class ChadrcConfig
local M = {}

-- M.theme = "custom"
M.base46 = {
  theme = "yorumi", -- default theme
  -- hl_add = {},
  -- hl_override = {
  --   -- Completion Menu
  --   CmpNormal = { bg = "black2" }, -- Menu background
  --   CmpBorder = { fg = "grey", bg = "black2" }, -- Menu border
  --
  --   -- Highlight selected item
  --   CmpSel = { bg = "blue", fg = "black" },
  --
  --   -- Item kinds
  --   CmpItemAbbr = { fg = "white" }, -- Normal text color
  --   CmpItemAbbrMatch = { fg = "blue", bold = true }, -- Matched text highlight hi
  --   CmpItemAbbrMatchFuzzy = { fg = "lightblue" }, -- Fuzzy match
  --
  --   -- Item kind colors
  --   CmpItemKindFunction = { fg = "yellow" },
  --   CmpItemKindVariable = { fg = "purple" },
  --   CmpItemKindKeyword = { fg = "blue" },
  -- },
  -- integrations = {},
  -- changed_themes = {},
  transparency = true,
  theme_toggle = { "custom", "yorumi" },
}

M.ui = {
  cmp = {
    lspkind_text = false,
    icons_left = false, -- only for non-atom styles!
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
    abbr_maxwidth = 60,
    format_colors = {
      tailwind = false, -- will work for css lsp too
      icon = "󱓻",
    },
  },
}

M.telescope = { style = "bordered" } -- borderless / bordered

M.statusline = {
  enabled = false,
  theme = "vscode", -- default/vscode/vscode_colored/minimal
  -- default/round/block/arrow separators work only for default statusline theme
  -- round and block will work for minimal theme only
  separator_style = "block",
  order = nil,
  modules = nil,
}

-- lazyload it when there are 1+ buffers
M.tabufline = {
  enabled = false,
  -- lazyload = false,
  -- order = { "treeOffset", "buffers", "tabs", "btns", "theme_toggle" },
  -- modules = nil,
  -- bufwidth = 21,
}

-- M.nvdash = {
--   load_on_startup = true,
--   header = {
--     "                             ::                             ",
--     "                             ++                             ",
--     "                            -%%-                            ",
--     "                            #%%#                            ",
--     "                           =%%%%=                           ",
--     "         -                .#%##%#.                -         ",
--     "          *=              .%%##%%.              =*          ",
--     "          -%#-            -%%##%%-            -#%-          ",
--     "           #%#%-          +%%##%%+          -%#%#           ",
--     "           :%%#%#:        =%%**%%=        :#%#%%:           ",
--     "            =%%*%%+:      *%%**%%*      :+%%*%%=            ",
--     "             =%%*#%%-     *%%**%%*     -%%#*%%=             ",
--     "              -%%**%%*    -%%**%%-    *%%**%%-              ",
--     "               :%%#+%%#-  :%%**%%:  -#%%+#%%:               ",
--     "                .#%%+#%#+  #%**%#  +#%#+%%#.                ",
--     "    .-+=:.        =%%**%%+ +%**%+ +%%**%%=        .:=+-.    ",
--     "       =#%%**-:    .#%#*%%=.%##%.=%%*#%#.    :-**%%#=       ",
--     "        .=%%###%#+-: -#%*#%.+##+.%#*%#- :-+#%###%%=.        ",
--     "           :*%%####%#+::*###.**.###*::+#%####%%*:           ",
--     "              :+*%%#####+=+#+--+#+=+#####%%*+:              ",
--     "                  .-+*#####======#####*+-:                  ",
--     "                     :-=+++*++++*+++=-:                     ",
--     "                 :=#%##**+=: :: :=+**##%#=:                 ",
--     "                             --                             ",
--     "                             ::                             ",
--     "					,",
--   },
--
--   buttons = {
--     { txt = "  Find File", keys = "ff", cmd = "Telescope find_files" },
--     { txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
--     { txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep" },
--     { txt = "󱥚  Themes", keys = "th", cmd = ":lua require('nvchad.themes').open()" },
--     { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },
--
--     { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
--
--     {
--       txt = function()
--         local stats = require("lazy").stats()
--         local ms = math.floor(stats.startuptime) .. " ms"
--         return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
--       end,
--       hl = "NvDashFooter",
--       no_gap = true,
--     },
--
--     { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
--   },
-- }

M.term = {
  enabled = false,
  winopts = { number = false, relativenumber = false },
  sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
  float = {
    relative = "editor",
    row = 0.3,
    col = 0.25,
    width = 0.5,
    height = 0.4,
    border = "rounded",
  },
}

M.lsp = { signature = true }

M.cheatsheet = {
  theme = "grid", -- simple/grid
  -- excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- can add group name or with mode
}

M.mason = { pkgs = {}, skip = {} }

M.colorify = {
  enabled = true,
  mode = "virtual", -- fg, bg, virtual
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

-- vim.notify(vim.inspect(M), vim.log.levels.INFO)
return M
-- return vim.tbl_deep_extend("force", M, status and chadrc or {})
