-- lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false, -- last release is way too old and doesn't work on Windows
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    dependencies = {
      -- Make textobjects a dependency so it loads with treesitter and receives the config naturally
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
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
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']a'] = '@parameter.inner',
            [']l'] = '@loop.outer',
            [']i'] = '@conditional.outer',
            [']s'] = '@statement.outer',
            [']c'] = { query = '@code_cell.inner', desc = 'next code cell' },
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']A'] = '@parameter.inner',
            [']L'] = '@loop.outer',
            [']I'] = '@conditional.outer',
            [']S'] = '@statement.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[a'] = '@parameter.inner',
            ['[l'] = '@loop.outer',
            ['[i'] = '@conditional.outer',
            ['[s'] = '@statement.outer',
            ['[c'] = { query = '@code_cell.inner', desc = 'previous code cell' },
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[A'] = '@parameter.inner',
            ['[L'] = '@loop.outer',
            ['[I'] = '@conditional.outer',
            ['[S'] = '@statement.outer',
          },
        },
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
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

            ['ic'] = { query = '@code_cell.inner', desc = 'in cell' },
            ['ac'] = { query = '@code_cell.outer', desc = 'around cell' },
          },
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
          },
          include_surrounding_whitespace = true,
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
            ['<leader>scl'] = '@code_cell.outer',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
            ['<leader>sch'] = '@code_cell.outer',
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

      -- Diff mode fallback for textobjects move (migrated here for cleaner lifecycle)
      local move = require 'nvim-treesitter.textobjects.move'
      local configs = require 'nvim-treesitter.configs'
      for name, fn in pairs(move) do
        if name:find 'goto' == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module('textobjects.move')[name]
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

  -- Rainbow delimiters for better bracket visibility
  {
    'HiPhish/rainbow-delimiters.nvim',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    -- Moved configuration to `init` since it relies on a global variable
    init = function()
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
