local function ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line '$'
  if ai_type == 'i' then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

return {
  {
    'nvim-mini/mini.comment',
    event = 'VeryLazy',
  },

  {
    {
      'nvim-mini/mini.surround',
      -- Load on very lazy event (adjust as you like)
      event = 'VeryLazy',
      -- These opts get passed directly to mini.surround.setup()
      opts = {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal+Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      },
      -- Dynamically generate keymaps based on the above opts, then merge
      -- into any other global keymaps you have.
      keys = function(plugin, keys)
        local opts = plugin.opts
        local mappings = {
          { opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
          { opts.mappings.delete, desc = 'Delete Surrounding' },
          { opts.mappings.find, desc = 'Find Right Surrounding' },
          { opts.mappings.find_left, desc = 'Find Left Surrounding' },
          { opts.mappings.highlight, desc = 'Highlight Surrounding' },
          { opts.mappings.replace, desc = 'Replace Surrounding' },
          { opts.mappings.update_n_lines, desc = 'Update `n_lines`' },
        }
        mappings = vim.tbl_filter(function(m)
          return m[1] and #m[1] > 0
        end, mappings)
        -- Merge with any other keydefs you supply elsewhere
        return vim.list_extend(mappings, keys)
      end,
      -- Finally, call setup with your opts
      config = function(_, opts)
        require('mini.surround').setup(opts)
      end,
    },
  },
  {
    'nvim-mini/mini.indentscope',
    enabled = true,
    event = 'BufEnter',
    opts = {
      -- symbol = "▏",
      symbol = '│',
      options = { try_as_border = false },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'Trouble',
          'alpha',
          'dashboard',
          'fzf',
          'help',
          'lazy',
          'mason',
          'neo-tree',
          'notify',
          'snacks_dashboard',
          'snacks_notif',
          'snacks_terminal',
          'snacks_win',
          'toggleterm',
          'trouble',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SnacksDashboardOpened',
        callback = function(data)
          vim.b[data.buf].miniindentscope_disable = true
        end,
      })
    end,
  },
  -- Needed for persistent highlights
  -- {
  --   'shellRaining/hlchunk.nvim',
  --   event = { 'BufReadPre', 'BufNewFile' },
  --   config = function()
  --     require('hlchunk').setup {
  --       chunk = {
  --         enable = true,
  --         duration = 100,
  --         delay = 20,
  --         style = {
  --           { fg = '#8992A7' },
  --           { fg = '#c21f30' },
  --         },
  --       },
  --       indent = {
  --         enable = false,
  --         use_treesitter = true,
  --       },
  --       line_num = {
  --         enable = false,
  --       },
  --       blank = {
  --         enable = false,
  --       },
  --     }
  --   end,
  -- },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    config = function()
      require('ibl').setup()
    end,
  },
  {
    'nvim-mini/mini.pairs',
    event = 'VeryLazy',
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { 'string' },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
    config = function(_, opts)
      require('mini.pairs').setup(opts)
    end,
  },
  {
    'nvim-mini/mini.icons',
    lazy = true,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'nvim-mini/mini.hipatterns',
    recommended = true,
    desc = 'Highlight colors in your code. Also includes Tailwind CSS support.',
    event = 'BufreadPost',
    opts = function()
      local hi = require 'mini.hipatterns'
      return {
        -- custom LazyVim option to enable the tailwind integration
        tailwind = {
          enabled = true,
          ft = {
            'astro',
            'css',
            'heex',
            'html',
            'html-eex',
            'javascript',
            'javascriptreact',
            'rust',
            'svelte',
            'typescript',
            'typescriptreact',
            'vue',
          },
          -- full: the whole css class will be highlighted
          -- compact: only the color will be highlighted
          style = 'full',
        },
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color { priority = 2000 },
          shorthand = {
            pattern = '()#%x%x%x()%f[^%x%w]',
            group = function(_, _, data)
              ---@type string
              local match = data.full_match
              local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
              local hex_color = '#' .. r .. r .. g .. g .. b .. b

              return MiniHipatterns.compute_hex_color_group(hex_color, 'bg')
            end,
            extmark_opts = { priority = 2000 },
          },
        },
      }
    end,
    config = function(_, opts)
      if type(opts.tailwind) == 'table' and opts.tailwind.enabled then
        -- reset hl groups when colorscheme changes
        vim.api.nvim_create_autocmd('ColorScheme', {
          callback = function(M)
            M.hl = {}
          end,
        })
        opts.highlighters.tailwind = {
          pattern = function()
            if not vim.tbl_contains(opts.tailwind.ft, vim.bo.filetype) then
              return
            end
            if opts.tailwind.style == 'full' then
              return '%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]'
            elseif opts.tailwind.style == 'compact' then
              return '%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]'
            end
          end,
          group = function(_, _, m)
            ---@type string
            local match = m.full_match
            ---@type string, number
            local color, shade = match:match '[%w-]+%-([a-z%-]+)%-(%d+)'
            shade = tonumber(shade)
            local bg = vim.tbl_get(_ENV['require("dial.nvim")'].colors, color, shade)
            if bg then
              local hl = 'MiniHipatternsTailwind' .. color .. shade
              if not _ENV['require("dial.nvim")'].hl[hl] then
                _ENV['require("dial.nvim")'].hl[hl] = true
                local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
                local fg = vim.tbl_get(_ENV['require("dial.nvim")'].colors, color, bg_shade)
                vim.api.nvim_set_hl(0, hl, { bg = '#' .. bg, fg = '#' .. fg })
              end
              return hl
            end
          end,
          extmark_opts = { priority = 2000 },
        }
      end
    end,
  },
  -- Better text objects
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    opts = function()
      local ai = require 'mini.ai'
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter {
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          },
          f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
          c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
          d = { '%f[%d]%d+' }, -- digits
          e = { -- Word with case
            { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
            '^().*()$',
          },
          g = function() -- Whole buffer, similar to `gg` and 'G' motion
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line '$',
              col = math.max(vim.fn.getline('$'):len(), 1),
            }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call { name_pattern = '[%w_]' }, -- without dot in function name
        },
      }
    end,
  },
}
