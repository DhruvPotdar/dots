return {
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- 'nvim-tree/nvim-web-devicons', -- optional, for icons
    },
    keys = {
      { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle Pin' },
      { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
      { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete Buffers to the Right' },
      { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete Buffers to the Left' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move Buffer Prev' },
      { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move Buffer Next' },
    },
    opts = {
      options = {
        close_command = function(n)
          require('snacks').bufdelete(n)
        end,
        right_mouse_command = function(n)
          require('snacks').bufdelete(n)
        end,
        diagnostics = 'nvim_lsp',
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require 'radtop.icons'
          local ret = (diag.error and icons.diagnostics.Error .. diag.error .. ' ' or '') .. (diag.warning and icons.diagnostics.Warn .. diag.warning or '')
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'Neo-tree',
            highlight = 'Directory',
            text_align = 'left',
          },
          {
            filetype = 'snacks_layout_box',
          },
        },
        get_element_icon = function(opts)
          -- Customize this depending on your icon setup
          local devicons = require 'nvim-web-devicons'
          local icon, _ = devicons.get_icon_by_filetype(opts.filetype)
          return icon
        end,
      },
      -- highlights = require('catppuccin.groups.integrations.bufferline').get(),
    },
    config = function(_, opts)
      require('bufferline').setup(opts)
      vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
          vim.schedule(function()
            pcall(require('bufferline').refresh)
          end)
        end,
      })
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',

    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      views = {
        mini = { border = { style = 'rounded' } },
        -- notify = {
        --   backend = 'mini',
        -- },
      },
      presets = {
        inc_rename = true,
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
        -- stylua: ignore
        keys = {
            { "<leader>sn",  "",                                                                            desc = "+noice" },
            { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                 mode = "c",                              desc = "Redirect Cmdline" },
            { "<leader>snl", function() require("noice").cmd("last") end,                                   desc = "Noice Last Message" },
            { "<leader>snh", function() require("noice").cmd("history") end,                                desc = "Noice History" },
            { "<leader>sna", function() require("noice").cmd("all") end,                                    desc = "Noice All" },
            { "<leader>snd", function() require("noice").cmd("dismiss") end,                                desc = "Dismiss All" },
            { "<leader>snt", function() require("noice").cmd("pick") end,                                   desc = "Noice Picker (Telescope/FzfLua)" },
            { "<c-f>",       function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,  silent = true,                           expr = true,              desc = "Scroll Forward",  mode = { "i", "n", "s" } },
            { "<c-b>",       function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true,                           expr = true,              desc = "Scroll Backward", mode = { "i", "n", "s" } },
        },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == 'lazy' then
        vim.cmd [[messages clear]]
      end
      require('noice').setup(opts)
    end,
  },
  { 'MunifTanjim/nui.nvim', lazy = true },
  { 'nvim-lua/plenary.nvim', lazy = true },
  {

    {
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v3.x',
      cmd = 'Neotree',
      dependencies = {
        'nvim-lua/plenary.nvim',
        -- 'nvim-tree/nvim-web-devicons', -- optional but recommended
        'MunifTanjim/nui.nvim',
      },
      keys = {
        {
          '<leader>fe',
          function()
            require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() }
          end,
          desc = 'Explorer NeoTree (Root Dir)',
        },
        {
          '<leader>fE',
          function()
            require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() }
          end,
          desc = 'Explorer NeoTree (cwd)',
        },
        { '<leader>e', '<leader>fe', desc = 'Explorer NeoTree (Root Dir)', remap = true },
        { '<leader>E', '<leader>fE', desc = 'Explorer NeoTree (cwd)', remap = true },
        {
          '<leader>ge',
          function()
            require('neo-tree.command').execute { source = 'git_status', toggle = true }
          end,
          desc = 'Git Explorer',
        },
        {
          '<leader>be',
          function()
            require('neo-tree.command').execute { source = 'buffers', toggle = true }
          end,
          desc = 'Buffer Explorer',
        },
      },
      deactivate = function()
        vim.cmd [[Neotree close]]
      end,
      init = function()
        -- vim.api.nvim_create_autocmd('BufEnter', {
        --     group = vim.api.nvim_create_augroup('Neotree_start_directory', { clear = true }),
        --     desc = 'Start Neo-tree with directory',
        --     once = true,
        --     callback = function()
        --         if package.loaded['neo-tree'] then
        --             return
        --         else
        --             local stats = vim.uv.fs_stat(vim.fn.argv(0))
        --             if stats and stats.type == 'directory' then
        --                 require 'neo-tree'
        --             end
        --         end
        --     end,
        -- })
      end,
      opts = {
        sources = { 'filesystem' },
        open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        window = {
          mappings = {
            ['l'] = 'open',
            ['h'] = 'close_node',
            ['<space>'] = 'none',
            ['Y'] = {
              function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                vim.fn.setreg('+', path, 'c')
              end,
              desc = 'Copy Path to Clipboard',
            },
            ['O'] = {
              function(state)
                require('lazy.util').open(state.tree:get_node().path, { system = true })
              end,
              desc = 'Open with System Application',
            },
            ['P'] = { 'toggle_preview', config = { use_float = false } },
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true,
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
          git_status = {
            symbols = {
              unstaged = '󰄱',
              staged = '󰱒',
            },
          },
        },
      },
      config = function(_, opts)
        local function on_move(data)
          Snacks.rename.on_rename_file(data.source, data.destination)
        end

        local events = require 'neo-tree.events'
        opts.event_handlers = opts.event_handlers or {}
        vim.list_extend(opts.event_handlers, {
          { event = events.FILE_MOVED, handler = on_move },
          { event = events.FILE_RENAMED, handler = on_move },
        })
        require('neo-tree').setup(opts)
        vim.api.nvim_create_autocmd('TermClose', {
          pattern = '*lazygit',
          callback = function()
            if package.loaded['neo-tree.sources.git_status'] then
              require('neo-tree.sources.git_status').refresh()
            end
          end,
        })
      end,
    },
  },

  {
    'hedyhli/outline.nvim',
    enabled = false,
    keys = {
      { '<leader>cs', '<cmd>Outline<cr>', desc = 'Toggle Outline' },
    },
    cmd = 'Outline',
    opts = function()
      local defaults = require('outline.config').defaults

      -- Define your own kind filter or leave empty
      local kind_filter = {
        -- example: exclude some kinds if you want, or leave empty to show all
        -- "Variable",
        -- "Constant",
      }

      -- Define your own icons for symbol kinds or use defaults from outline.nvim
      local icons = {
        File = ' ',
        Module = ' ',
        Namespace = ' ',
        Package = ' ',
        Class = ' ',
        Method = ' ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = '  ',
        Interface = ' ',
        Function = ' ',
        Variable = ' ',
        Constant = ' ',
        String = ' ',
        Number = ' ',
        Boolean = ' ',
        Array = '󰅨 ',
        Object = ' ',
        Key = ' ',
        Null = 'ﳠ ',
        EnumMember = ' ',
        Struct = '󱁊 ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = '󰅵 ',
      }

      local opts = {
        symbols = {
          icons = {},
          filter = kind_filter,
        },
        keymaps = {
          up_and_jump = '<up>',
          down_and_jump = '<down>',
        },
      }

      for kind, symbol in pairs(defaults.symbols.icons) do
        opts.symbols.icons[kind] = {
          icon = icons[kind] or symbol.icon,
          hl = symbol.hl,
        }
      end

      return opts
    end,
  },

  {
    'folke/edgy.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>ue',
        function()
          require('edgy').toggle()
        end,
        desc = 'Edgy Toggle',
      },
            -- stylua: ignore
            { '<leader>uE', function() require('edgy').select() end, desc = 'Edgy Select Window' },
    },
    opts = function()
      local opts = {
        bottom = {
          {
            ft = 'toggleterm',
            size = { height = 0.4 },
            filter = function(_buf, win)
              return vim.api.nvim_win_get_config(win).relative == ''
            end,
          },
          {
            ft = 'noice',
            size = { height = 0.4 },
            filter = function(_buf, win)
              return vim.api.nvim_win_get_config(win).relative == ''
            end,
          },
          'Trouble',
          { ft = 'qf', title = 'QuickFix' },
          {
            ft = 'help',
            size = { height = 20 },
            filter = function(buf)
              return vim.bo[buf].buftype == 'help'
            end,
          },
          { title = 'Spectre', ft = 'spectre_panel', size = { height = 0.4 } },
          { title = 'Neotest Output', ft = 'neotest-output-panel', size = { height = 15 } },
        },
        left = {
          { title = 'Neotest Summary', ft = 'neotest-summary' },
          -- You can add 'neo-tree' here if you want it always visible
        },
        right = {
          { title = 'Grug Far', ft = 'grug-far', size = { width = 0.4 } },
        },
        keys = {
          ['<c-Right>'] = function(win)
            win:resize('width', 2)
          end,
          ['<c-Left>'] = function(win)
            win:resize('width', -2)
          end,
          ['<c-Up>'] = function(win)
            win:resize('height', 2)
          end,
          ['<c-Down>'] = function(win)
            win:resize('height', -2)
          end,
        },
      }

      -- Define neo-tree sources manually here
      local neo_tree_sources = { 'filesystem' }

      -- Define positions for each source
      local pos = {
        filesystem = 'right',
        document_symbols = 'bottom',
        diagnostics = 'bottom',
      }

      -- Get current working directory as root
      local root_dir = vim.loop.cwd()

      -- Insert neo-tree windows into the left panel
      for i, source in ipairs(neo_tree_sources) do
        table.insert(opts.right, i, {
          title = 'Neo-Tree ' .. source:gsub('_', ' '):gsub('^%l', string.upper),
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == source
          end,
          pinned = true,
          open = function()
            vim.cmd(('Neotree show position=%s %s dir=%s'):format(pos[source] or 'bottom', source, root_dir))
          end,
        })
      end

      -- Add trouble windows to all positions
      for _, position in ipairs { 'top', 'bottom', 'left', 'right' } do
        opts[position] = opts[position] or {}
        table.insert(opts[position], {
          ft = 'trouble',
          filter = function(_buf, win)
            return vim.w[win].trouble
              and vim.w[win].trouble.position == position
              and vim.w[win].trouble.type == 'split'
              and vim.w[win].trouble.relative == 'editor'
              and not vim.w[win].trouble_preview
          end,
        })
      end

      -- Add snacks_terminal windows to all positions
      for _, position in ipairs { 'top', 'bottom', 'left', 'right' } do
        opts[position] = opts[position] or {}
        table.insert(opts[position], {
          ft = 'snacks_terminal',
          size = { height = 0.4 },
          title = '%{b:snacks_terminal.id}: %{b:term_title}',
          filter = function(_buf, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == position
              and vim.w[win].snacks_win.relative == 'editor'
              and not vim.w[win].trouble_preview
          end,
        })
      end

      return opts
    end,
  },
  {
    'sphamba/smear-cursor.nvim',
    enabled = false,
    event = 'VeryLazy',
    cond = vim.g.neovide == nil,
    opts = {
      hide_target_hack = true,
      cursor_color = 'none',
    },
  },
  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    config = function()
      local dropbar_api = require 'dropbar.api'
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in Dropbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },

  {
    'rasulomaroff/reactive.nvim',
    event = 'VeryLazy',
    enabled = true,
    config = function()
      require('reactive').setup {
        -- load = { "catpuccin-mocha-cursorline" },
        builtin = {
          cursorline = true,
          cursor = false,
          modemsg = false,
        },
      }
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = ' '
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      local lualine_require = require 'lualine_require'
      lualine_require.require = require

      local icons = require 'radtop.icons'
      local component_widths = {}

      -- check width of current component and add to maps
      local function add_width(str, name)
        if not str or str == '' then
          component_widths[name] = 0
          return str
        end
        component_widths[name] = #vim.api.nvim_eval_statusline(str, {}).str
        return str
      end

      -- fill space bweteen left-most components and middle of terminal
      local function fill_space()
        local used_space = 0
        for _, width in pairs(component_widths) do
          used_space = used_space + width
        end

        local filetype_w = component_widths['filetype'] or 0
        local filename_w = component_widths['filename'] or 0

        used_space = used_space - (filename_w + filetype_w)

        local term_width = vim.opt.columns:get()

        local fill = string.rep(' ', math.floor((term_width - filename_w - filetype_w) / 2) - used_space)
        return fill
      end

      vim.o.laststatus = vim.g.lualine_laststatus
      local colors = {
        bg = 'none', -- This makes it transparent
        fg = '#abb2bf',
        -- other colors as needed
      }

      local custom_theme = {
        normal = {
          a = { bg = colors.bg, fg = colors.fg },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
        insert = { a = { bg = colors.bg, fg = colors.fg } },
        visual = { a = { bg = colors.bg, fg = colors.fg } },
        replace = { a = { bg = colors.bg, fg = colors.fg } },
        command = { a = { bg = colors.bg, fg = colors.fg } },
        inactive = {
          a = { bg = colors.bg, fg = colors.fg },
          b = { bg = colors.bg, fg = colors.fg },
          c = { bg = colors.bg, fg = colors.fg },
        },
      }

      local opts = {
        options = {
          theme = custom_theme,
          component_separators = '',
          section_separators = '',
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' },
            winbar = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' },
          },
        },
        sections = {
          lualine_a = {
            { -- show current vim mode single character
              function()
                local mode = vim.api.nvim_get_mode()['mode']
                return '' .. string.format('%-1s', mode)
              end,
              fmt = function(str)
                return add_width(str, 'mode')
              end,
            },
          },
          lualine_b = {},
          lualine_c = {
            { -- show cwd (project dir nvim.project)
              function()
                local cwd = vim.fn.getcwd()
                return '󱉭 ' .. vim.fs.basename(cwd)
              end,
              color = { fg = Snacks.util.color 'Special' },
              fmt = function(str)
                return add_width(str, 'root')
              end,
            },
            -- { -- show cwd if it does not match prev component
            --   function()
            --     return require("radtop.utils").get_root_dir_component({icon = ">"})
            --     return LazyVim.lualine.root_dir({ icon = '>' })[1]()
            --   end,
            --   color = { fg = Snacks.util.color 'Special' }, -- Optional: Customize the appearance
            --   padding = { left = 0, right = 0 },
            --   fmt = function(str)
            --     return add_width(str, 'cwd')
            --   end,
            -- },
            { -- show profiler events if enabled
              function()
                if Snacks.profiler.core.running then
                  return Snacks.profiler.status()[1]()
                end
                return ''
              end,
              color = 'DiagnosticError',
              fmt = function(str)
                return add_width(str, 'profiler')
              end,
            },
            { -- show macro recording
              function()
                local reg = vim.fn.reg_recording()
                if reg == '' then
                  return ''
                end -- not recording
                return ' recording to @' .. reg
              end,
              padding = { left = 0, right = 0 },
              color = function()
                return { fg = '#ff00ff' }
              end,
              fmt = function(str)
                return add_width(str, 'recording')
              end,
            },
            { -- show dap info
              function()
                return '  ' .. require('dap').status()
              end,
              cond = function()
                return package.loaded['dap'] and require('dap').status() ~= ''
              end,
              color = function()
                return { fg = Snacks.util.color 'Debug' }
              end,
              fmt = function(str)
                return add_width(str, 'dap')
              end,
            },
            { -- show lazy update status
              require('lazy.status').updates,
              cond = require('lazy.status').has_updates,
              color = function()
                return { fg = Snacks.util.color 'Special' }
              end,
              fmt = function(str)
                return add_width(str, 'lazy')
              end,
            },
            { -- show diagnostic info
              'diagnostics',
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
              fmt = function(str)
                return add_width(str, 'diagnostics')
              end,
            },
            { -- fill space to center filename
              function()
                return fill_space()
              end,
              padding = { left = 0, right = 0 },
            },
            { -- filetype icon
              'filetype',
              icon_only = true,
              separator = '',
              padding = { left = 0, right = 0 },
              fmt = function(str)
                return add_width(str, 'filetype')
              end,
            },
            { -- filename centered to middle of window
              'filename',
              file_status = true,
              newfile_status = true,
              color = { fg = Snacks.util.color 'Special', gui = 'BOLD' },
              padding = { left = 0, right = 0 },
              fmt = function(str)
                return add_width(str, 'filename')
              end,
            },
          },

          lualine_x = {
            {
              'diff',
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
            { 'branch', color = { fg = Snacks.util.color 'Special' } },
          },

          lualine_y = {},
          lualine_z = {
            {
              function()
                local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
                local max_lnum = vim.api.nvim_buf_line_count(0)

                local ruler
                if lnum == 1 then
                  ruler = 'TOP'
                elseif lnum == max_lnum then
                  ruler = 'BOT'
                else
                  ruler = string.format('%2d%%%%', math.floor(100 * lnum / max_lnum))
                end

                return '' .. lnum .. '' .. ruler
              end,
              icon = '',
              padding = { left = 1, right = 1 },
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            { '%=' },
            {
              'filename',
              file_status = true,
              newfile_status = true,
              color = { fg = Snacks.util.color 'Normal', gui = 'italic' },
            },
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { 'lazy', 'fzf' },
      }

      return opts
    end,
  },
  {
    'gbprod/yanky.nvim',
    enabled = false,
    recommended = true,
    desc = 'Better Yank/Paste',
    event = 'BufReadPost',
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      {
        '<leader>p',
        function()
          -- if LazyVim.pick.picker.name == 'telescope' then
          --   require('telescope').extensions.yank_history.yank_history {}
          -- else
          --   vim.cmd [[YankyRingHistory]]
          -- end
        end,
        mode = { 'n', 'x' },
        desc = 'Open Yank History',
      },
            -- stylua: ignore
            { "y",  "<Plug>(YankyYank)",                      mode = { "n", "x" },                           desc = "Yank Text" },
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Cursor' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Cursor' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Selection' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Selection' },
      { '[y', '<Plug>(YankyCycleForward)', desc = 'Cycle Forward Through Yank History' },
      { ']y', '<Plug>(YankyCycleBackward)', desc = 'Cycle Backward Through Yank History' },
      { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[p', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[P', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { '>p', '<Plug>(YankyPutIndentAfterShiftRight)', desc = 'Put and Indent Right' },
      { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)', desc = 'Put and Indent Left' },
      { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put Before and Indent Right' },
      { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)', desc = 'Put Before and Indent Left' },
      { '=p', '<Plug>(YankyPutAfterFilter)', desc = 'Put After Applying a Filter' },
      { '=P', '<Plug>(YankyPutBeforeFilter)', desc = 'Put Before Applying a Filter' },
    },
  },
  {
    'rcarriga/nvim-notify',
    keys = {
      {
        '<leader>un',
        function()
          require('notify').dismiss { silent = true, pending = true }
        end,
        desc = 'Dismiss All Notifications',
      },
    },
    opts = {
      stages = 'fade',
      top_down = false,
      timeout = 2000,
      -- max_height = function()
      --   return math.floor(vim.o.lines * 0.75)
      -- end,
      -- max_width = function()
      --   return math.floor(vim.o.columns * 0.75)
      -- end,
      -- on_open = function(win)
      --   vim.api.nvim_win_set_config(win, { zindex = 100 })
      -- end,
    },
    config = function(opts)
      require('notify').setup { background_colour = '#000000' }
      vim.notify = require 'notify'
    end,
  },
}
