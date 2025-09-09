return {
  -- { 'rebelot/kanagawa.nvim' },
  -- { 'rose-pine/neovim' },

  -- {
  --     'yorumicolors/yorumi.nvim',
  --     enabled = false,
  --     config = function()
  --         options = {
  --             undercurl = true,
  --             commentStyle = { italic = true },
  --             functionStyle = {},
  --             keywordStyle = {},
  --             statementStyle = {},
  --             typeStyle = {},
  --             dimInactive = false,
  --             terminalColors = false,
  --             ---@type { dark: string, light: string}
  --             background = { dark = 'abyss', light = 'mist' }, --- light, mist theme coming soon
  --             theme = 'abyss',
  --         }
  --     end,
  -- },
  {
    'webhooked/kanso.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      compile = true, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { italic = true },
      statementStyle = {},
      typeStyle = { italic = true },
      disableItalics = false,
      transparent = false, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      overrides = function(colors) -- add/modify highlights
        local theme = colors.theme
        return {
          BlinkCmpMenuBorder = { fg = '#24262d', bg = '#090e13' },
          -- Normal = { bg = theme.ui.bg, fg = theme.ui.fg },
          --
          -- NormalFloat = { bg = 'none' },
          -- FloatBorder = { bg = 'none' },
          -- FloatTitle = { bg = 'none' },
          -- -- Popular plugins that open floats will link to NormalFloat by default;
          -- -- set their background accordingly if you wish to keep them dark and borderless
          -- LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          -- MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          -- Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
          -- PmenuSel = { fg = 'NONE', bg = theme.ui.bg_p2 },
          -- PmenuSbar = { bg = theme.ui.bg_m1 },
          -- PmenuThumb = { bg = theme.ui.bg_p2 },
        }
      end,
      theme = 'zen', -- Load "zen" theme
    },
    config = function(opts)
      -- require('kanso').setup(opts)
      vim.api.nvim_command 'colorscheme kanso-zen'
    end,
  },
}
