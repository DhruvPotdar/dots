-- lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require 'nvim-treesitter.query_predicates'
    end,
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    keys = {
      { '<c-space>', desc = 'Increment Selection' },
      { '<bs>', desc = 'Decrement Selection', mode = 'x' },
    },
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        -- Disable for large files
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = { enable = true },
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'css',
        'diff',
        'dockerfile',
        'go',
        'html',
        'java',
        'javascript',
        'jsdoc',
        'json',
        'jsonc',
        'lua',
        'luadoc',
        'luap',
        'markdown',
        'markdown_inline',
        'printf',
        'python',
        'query',
        'regex',
        'rust',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']f'] = '@function.outer',
            -- [']c'] = '@class.outer',
            [']a'] = '@parameter.inner',
            [']l'] = '@loop.outer',
            [']i'] = '@conditional.outer',
            [']s'] = '@statement.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            -- [']C'] = '@class.outer',
            [']A'] = '@parameter.inner',
            [']L'] = '@loop.outer',
            [']I'] = '@conditional.outer',
            [']S'] = '@statement.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            -- ['[c'] = '@class.outer',
            ['[a'] = '@parameter.inner',
            ['[l'] = '@loop.outer',
            ['[i'] = '@conditional.outer',
            ['[s'] = '@statement.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            -- ['[C'] = '@class.outer',
            ['[A'] = '@parameter.inner',
            ['[L'] = '@loop.outer',
            ['[I'] = '@conditional.outer',
            ['[S'] = '@statement.outer',
          },
        },
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            -- ['ac'] = '@class.outer',
            -- ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['al'] = '@loop.outer',
            ['il'] = '@loop.inner',
            ['ai'] = '@conditional.outer',
            ['ii'] = '@conditional.inner',
            ['as'] = '@statement.outer',
            ['is'] = '@statement.inner',
            ['ab'] = '@block.outer',
            ['ib'] = '@block.inner',
            ['av'] = '@assignment.outer',
            ['iv'] = '@assignment.inner',
            ['ak'] = '@comment.outer',
            ['ik'] = '@comment.inner',
          },
          -- You can choose the select mode (default is charwise 'v')
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap` and `ip` mappings.
          include_surrounding_whitespace = true,
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
        lsp_interop = {
          enable = true,
          border = 'rounded',
          floating_preview_opts = {},
          peek_definition_code = {
            ['<leader>df'] = '@function.outer',
            ['<leader>dF'] = '@class.outer',
          },
        },
      },
    },
    config = function(_, opts)
      -- Remove duplicates from ensure_installed
      if type(opts.ensure_installed) == 'table' then
        local seen = {}
        local unique = {}
        for _, lang in ipairs(opts.ensure_installed) do
          if not seen[lang] then
            seen[lang] = true
            table.insert(unique, lang)
          end
        end
        opts.ensure_installed = unique
      end

      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- Enhanced treesitter textobjects (already configured above, but separate plugin)
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      local function is_loaded(name)
        local Config = require 'lazy.core.config'
        return Config.plugins[name] and Config.plugins[name]._.loaded
      end

      if is_loaded 'nvim-treesitter' then
        local function get_opts(name)
          local plugin = require('lazy.core.config').spec.plugins[name]
          if not plugin then
            return {}
          end
          local Plugin = require 'lazy.core.plugin'
          return Plugin.values(plugin, 'opts', false)
        end

        local opts = get_opts 'nvim-treesitter'
        require('nvim-treesitter.configs').setup { textobjects = opts.textobjects }
      end

      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require 'nvim-treesitter.textobjects.move' ---@type table<string,fun(...)>
      local configs = require 'nvim-treesitter.configs'
      for name, fn in pairs(move) do
        if name:find 'goto' == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find '[%]%[][cC]' then
                  vim.cmd('normal! ' .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },

  -- Enhanced commenting with treesitter context
  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      {
        'luukvbaal/statuscol.nvim',
        config = function()
          local builtin = require 'statuscol.builtin'
          require('statuscol').setup {
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
              { text = { '%s' }, click = 'v:lua.ScSa' },
              { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            },
          }
        end,
      },
    },
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        return { 'treesitter', 'indent' }
      end,
      open_fold_hl_timeout = 150,
      close_fold_kinds_for_ft = {
        default = { 'imports', 'comment' },
        json = { 'array' },
        c = { 'comment', 'region' },
      },
      preview = {
        win_config = {
          border = { '', '─', '', '', '', '─', '', '' },
          winhighlight = 'Normal:Folded',
          winblend = 0,
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']',
        },
      },
    },
    init = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- Using ufo provider need remap `zR` and `zM`
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
    end,
    keys = {
      {
        'zR',
        function()
          require('ufo').openAllFolds()
        end,
        desc = 'Open all folds',
      },
      {
        'zM',
        function()
          require('ufo').closeAllFolds()
        end,
        desc = 'Close all folds',
      },
      {
        'zr',
        function()
          require('ufo').openFoldsExceptKinds()
        end,
        desc = 'Fold less',
      },
      {
        'zm',
        function()
          require('ufo').closeFoldsWith()
        end,
        desc = 'Fold more',
      },
      {
        'zp',
        function()
          require('ufo').peekFoldedLinesUnderCursor()
        end,
        desc = 'Peek fold',
      },
    },
  },

  -- Rainbow delimiters for better bracket visibility
  {
    'HiPhish/rainbow-delimiters.nvim',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local rainbow_delimiters = require 'rainbow-delimiters'
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        priority = {
          [''] = 110,
          lua = 210,
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end,
  },
}
