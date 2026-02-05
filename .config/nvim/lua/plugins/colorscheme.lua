return {
  -- { 'rebelot/kanagawa.nvim' },
  -- { 'rose-pine/neovim' },
  {
    'sainnhe/gruvbox-material',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_better_performance = 1
      -- vim.cmd.colorscheme 'gruvbox-material'
    end,
  },

  {
    'rose-pine/neovim',
    enabled = false,
    name = 'rose-pine',
    opts = {
      variant = 'main', -- auto, main, moon, or dawn
      dark_variant = 'main', -- main, moon, or dawn
      dim_inactive_windows = false,
      extend_background_behind_borders = true,

      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
      },

      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },
    },
  },
  {
    {
      'rebelot/kanagawa.nvim',
      name = 'kanagawa',
      lazy = false,
      priority = 1000,

      config = function()
        require('kanagawa').setup {
          theme = 'dragon', -- "wave" | "dragon" | "lotus"
          transparent = true, -- main transparency flag

          overrides = function(colors)
            local theme = colors.theme
            local palette = colors.palette

            -- Bluish color for blink.cmp (from previous request)
            local blue_color = palette.crystalBlue

            -- Kanagawa dim background color for duller line numbers
            local dim_bg_color = palette.bg_dim

            return {
              -- Core transparency
              Normal = { bg = 'none' },
              NormalNC = { bg = 'none' },
              NormalFloat = { bg = 'none' },
              FloatBorder = { bg = 'none' },
              SignColumn = { bg = 'none' },
              LineNr = { bg = 'none', fg = dim_bg_color },
              CursorLineNr = { bg = 'none', fg = blue_color },
              FoldColumn = { bg = 'none' },
              VertSplit = { bg = 'none' },

              -- Diagnostic Highlights (For transparent error/warning symbols)
              -- The highlight group for the symbol itself is typically called 'DiagnosticSign...'
              DiagnosticSignError = { bg = 'none' }, -- <<< NEW: Transparent Error Symbol BG
              DiagnosticSignWarn = { bg = 'none' }, -- <<< NEW: Transparent Warning Symbol BG
              DiagnosticSignInfo = { bg = 'none' },
              DiagnosticSignHint = { bg = 'none' },

              -- Popup / cmdline borders fully transparent
              Pmenu = { bg = 'none' },
              PmenuSbar = { bg = 'none' },
              PmenuThumb = { bg = 'none' },

              -- Noice / cmdline popup borders
              NoiceCmdlinePopupBorder = { bg = 'none', fg = blue_color },
              NoiceCmdlinePopup = { bg = 'none' },
              NoicePopupBorder = { bg = 'none', fg = blue_color },
              NoicePopup = { bg = 'none' },

              -- Lualine matching transparent UI
              StatusLine = { bg = 'none', fg = theme.ui.fg },
              StatusLineNC = { bg = 'none', fg = theme.ui.fg_dim },

              -- Subtle, darker indentline color
              IblIndent = { fg = '#1b1b1b' },
              IblScope = { fg = '#2a2a2a' },

              -- blink.cmp menu transparency & blue color
              BlinkCmpMenu = { bg = 'none', fg = blue_color },
              BlinkCmpMenuBorder = { bg = 'none', fg = blue_color },
              BlinkCmpMenuSelection = { bg = '#1b1b1b' },
              BlinkCmpMenuMatch = { bg = 'none', fg = colors.theme.syn.special },

              -- documentation popup
              BlinkCmpDoc = { bg = 'none' },
              BlinkCmpDocBorder = { bg = 'none', fg = colors.theme.ui.float.fg },

              -- icons / kind labels
              BlinkCmpKind = { bg = 'none' },
              BlinkCmpGhostText = { bg = 'none', fg = colors.theme.ui.fg_dim },

              -- BufferLine highlights
              BufferLineFill = { bg = 'NONE' },
              BufferLineBackground = { bg = 'NONE' },
              BufferLineTab = { bg = 'NONE' },
              BufferLineTabClose = { bg = 'NONE' },
              BufferLineCloseButton = { bg = 'NONE' },
              BufferLineBufferVisible = { bg = 'NONE' },
              BufferLineSeparator = { bg = 'NONE' },
              BufferLineSeparatorVisible = { bg = 'NONE' },
              BufferLineBufferSelected = {
                fg = colors.text,
                bg = colors.surface,
                bold = true,
              },

              GitSignsAdd = { bg = 'none' },
              GitSignsChange = { bg = 'none' },
              GitSignsDelete = { bg = 'none' },

              -- (line highlights when using inline blame or word diff)
              GitSignsAddLn = { bg = 'none' },
              GitSignsChangeLn = { bg = 'none' },
              GitSignsDeleteLn = { bg = 'none' },

              -- (line number column foreground signs)
              GitSignsAddNr = { bg = 'none' },
              GitSignsChangeNr = { bg = 'none' },
              GitSignsDeleteNr = { bg = 'none' },
            }
          end,
        }

        vim.cmd 'colorscheme kanagawa-dragon'
      end,
    },
  },

  {
    'webhooked/kanso.nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      compile = true, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { italic = true },
      statementStyle = {},
      typeStyle = { italic = true },
      disableItalics = false,
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      foreground = {
        dark = 'saturated',
      },
      overrides = function(colors) -- add/modify highlights
        return {
          -- BlinkCmpMenuBorder = { fg = '#24262d', bg = '#090e13' },
          --
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          FloatTitle = { bg = 'none' },
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

    config = function()
      -- vim.cmd 'colorscheme kanso-zen'

      vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
      -- vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none' })
    end,
  },
  {
    'vague2k/vague.nvim',
    enabled = false,
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require('vague').setup {
        -- optional configuration here
      }
      -- vim.cmd("colorscheme vague")
    end,
  },
  {
    'Shatur/neovim-ayu',
    enabled = false,
    config = function()
      -- vim.cmd 'colorscheme kanso-zen'

      vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
      -- vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none' })
    end,
  },
}
