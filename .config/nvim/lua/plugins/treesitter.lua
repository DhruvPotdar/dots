-- lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      if vim.fn.executable('tree-sitter') == 0 then
        vim.notify(
          "nvim-treesitter: 'tree-sitter' CLI not found. Please install it for parser updates.",
          vim.log.levels.WARN
        )
      end

      local ok, ts = pcall(require, 'nvim-treesitter')
      if not ok or not ts.install then
        -- Plugin hasn't switched to 'main' branch yet
        return
      end

      ts.setup({})

      local ensure_installed = {
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
      }
      ts.install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local ok_move, move = pcall(require, 'nvim-treesitter-textobjects.move')
      local ok_swap, swap = pcall(require, 'nvim-treesitter-textobjects.swap')
      local ok_peek, peek = pcall(require, 'nvim-treesitter-textobjects.peek')

      if not (ok_move and ok_swap and ok_peek) then
        -- Plugin hasn't switched to 'main' branch yet
        return
      end

      require('nvim-treesitter-textobjects').setup({
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
      })

      local function wrap_move(fn, query, desc)
        return function()
          if vim.wo.diff then
            local key = query:match('[%]%[][cC]') and query or nil
            if key then
              vim.cmd('normal! ' .. key)
              return
            end
          end
          fn(query, 'textobjects')
        end
      end

      local move_maps = {
        [']f'] = { fn = move.goto_next_start, q = '@function.outer' },
        [']a'] = { fn = move.goto_next_start, q = '@parameter.inner' },
        [']l'] = { fn = move.goto_next_start, q = '@loop.outer' },
        [']i'] = { fn = move.goto_next_start, q = '@conditional.outer' },
        [']s'] = { fn = move.goto_next_start, q = '@statement.outer' },
        [']c'] = { fn = move.goto_next_start, q = '@code_cell.inner', desc = 'next code cell' },
        [']F'] = { fn = move.goto_next_end, q = '@function.outer' },
        [']A'] = { fn = move.goto_next_end, q = '@parameter.inner' },
        [']L'] = { fn = move.goto_next_end, q = '@loop.outer' },
        [']I'] = { fn = move.goto_next_end, q = '@conditional.outer' },
        [']S'] = { fn = move.goto_next_end, q = '@statement.outer' },
        ['[f'] = { fn = move.goto_previous_start, q = '@function.outer' },
        ['[a'] = { fn = move.goto_previous_start, q = '@parameter.inner' },
        ['[l'] = { fn = move.goto_previous_start, q = '@loop.outer' },
        ['[i'] = { fn = move.goto_previous_start, q = '@conditional.outer' },
        ['[s'] = { fn = move.goto_previous_start, q = '@statement.outer' },
        ['[c'] = { fn = move.goto_previous_start, q = '@code_cell.inner', desc = 'previous code cell' },
        ['[F'] = { fn = move.goto_previous_end, q = '@function.outer' },
        ['[A'] = { fn = move.goto_previous_end, q = '@parameter.inner' },
        ['[L'] = { fn = move.goto_previous_end, q = '@loop.outer' },
        ['[I'] = { fn = move.goto_previous_end, q = '@conditional.outer' },
        ['[S'] = { fn = move.goto_previous_end, q = '@statement.outer' },
      }

      for key, map in pairs(move_maps) do
        vim.keymap.set({ 'n', 'x', 'o' }, key, wrap_move(map.fn, map.q, map.desc), { desc = map.desc })
      end

      vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap next parameter' })
      vim.keymap.set('n', '<leader>scl', function() swap.swap_next('@code_cell.outer') end, { desc = 'Swap next cell' })
      vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap previous parameter' })
      vim.keymap.set('n', '<leader>sch', function() swap.swap_previous('@code_cell.outer') end, { desc = 'Swap previous cell' })

      vim.keymap.set('n', '<leader>df', function() peek.Peek_definition_code('@function.outer') end, { desc = 'Peek function definition' })
      vim.keymap.set('n', '<leader>dF', function() peek.Peek_definition_code('@class.outer') end, { desc = 'Peek class definition' })
    end,
  },

  {
    'folke/ts-comments.nvim',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has('nvim-0.10.0') == 1,
  },

  {
    'HiPhish/rainbow-delimiters.nvim',
    enabled = false,
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
      local rainbow_delimiters = require('rainbow-delimiters')
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
