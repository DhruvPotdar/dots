-- lua/plugins/fzf-lua.lua
return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- Optional for icon support
    },
    opts = function()
      -- Utility functions ported from your utils file
      local utils = {}

      utils.has = function(plugin)
        local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
        return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
      end

      utils.get_clients = function(opts)
        local ret = {}
        if vim.lsp.get_clients then
          ret = vim.lsp.get_clients(opts)
        else
          ret = vim.lsp.get_active_clients(opts)
          if opts and opts.method then
            ret = vim.tbl_filter(function(client)
              return client.supports_method(opts.method, { bufnr = opts.bufnr })
            end, ret)
          end
        end
        return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
      end

      utils.pick = function(action, opts)
        opts = opts or {}
        return function()
          -- Get root directory using git or fallback to cwd
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end

          local cwd = opts.cwd or (opts.root and get_root()) or vim.fn.getcwd()
          require('fzf-lua')[action](vim.tbl_extend('force', opts, { cwd = cwd }))
        end
      end

      -- Get icons (you may need to adjust based on your icons module)
      local icons = require 'radtop.icons'

      -- Configure fzf-lua
      local config = require 'fzf-lua.config'
      local actions = require 'fzf-lua.actions'

      -- Enhanced keymaps for fzf interface
      config.defaults.keymap.fzf['ctrl-q'] = 'select-all+accept'
      config.defaults.keymap.fzf['ctrl-u'] = 'half-page-up'
      config.defaults.keymap.fzf['ctrl-d'] = 'half-page-down'
      config.defaults.keymap.fzf['ctrl-x'] = 'jump'
      config.defaults.keymap.fzf['ctrl-f'] = 'preview-page-down'
      config.defaults.keymap.fzf['ctrl-b'] = 'preview-page-up'
      config.defaults.keymap.builtin['<c-f>'] = 'preview-page-down'
      config.defaults.keymap.builtin['<c-b>'] = 'preview-page-up'

      -- Trouble integration if available
      if utils.has 'trouble.nvim' then
        config.defaults.actions.files['ctrl-t'] = function(...)
          return require('trouble.sources.fzf').actions.open(...)
        end
      end

      -- Toggle root dir / cwd functionality
      config.defaults.actions.files['ctrl-r'] = function(_, ctx)
        local opt = vim.deepcopy(ctx.__call_opts)
        opt.root = not opt.root
        if opt.root then
          local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
          if vim.v.shell_error == 0 and git_root and git_root ~= '' then
            opt.cwd = git_root
          else
            opt.cwd = vim.fn.getcwd()
          end
        else
          opt.cwd = vim.fn.getcwd()
        end
        require('fzf-lua').files(opt)
      end
      config.set_action_helpstr(config.defaults.actions.files['ctrl-r'], 'toggle-root-dir')

      -- Image previewer detection
      local img_previewer
      for _, v in ipairs {
        { cmd = 'chafa', args = { '{file}', '--format=symbols' } },
        { cmd = 'ueberzug', args = {} },
        { cmd = 'viu', args = { '-b' } },
      } do
        if vim.fn.executable(v.cmd) == 1 then
          img_previewer = vim.list_extend({ v.cmd }, v.args)
          break
        end
      end

      return {
        'default-title',
        fzf_colors = true,
        fzf_opts = {
          ['--no-scrollbar'] = true,
          ['--layout=reverse'] = true,
        },
        defaults = {
          formatter = 'path.dirname_first',
          file_ignore_patterns = {
            '%.git/',
            'node_modules/',
            '%.pyc',
            '__pycache__/',
            '%.class',
            '%.o',
            '%.a',
            '%.out',
            '%.pdf',
            '%.mkv',
            '%.mp4',
            '%.zip',
          },
        },
        previewers = {
          builtin = {
            syntax_limit_l = 0,
            syntax_limit_b = 1024 * 1024, -- 1MB
            limit_b = 1024 * 1024 * 10, -- 10MB
            extensions = img_previewer and {
              ['png'] = img_previewer,
              ['jpg'] = img_previewer,
              ['jpeg'] = img_previewer,
              ['gif'] = img_previewer,
              ['webp'] = img_previewer,
            } or {},
            ueberzug_scaler = 'fit_contain',
          },
        },
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.55,
          border = 'rounded',
          fullscreen = false,
          preview = {
            scrollbar = 'border',
            scrollchars = { '┃', '' },
            delay = 10,
            winopts = {
              number = true,
              relativenumber = false,
              cursorline = true,
              cursorlineopt = 'both',
              cursorcolumn = false,
              signcolumn = 'no',
              list = false,
              foldenable = false,
              wrap = false,
            },
          },
        },
        keymap = {
          builtin = {
            ['<F1>'] = 'toggle-help',
            ['<F2>'] = 'toggle-fullscreen',
            ['<F3>'] = 'toggle-preview-wrap',
            ['<F4>'] = 'toggle-preview',
            ['<F5>'] = 'toggle-preview-ccw',
            ['<F6>'] = 'toggle-preview-cw',
            ['<c-f>'] = 'preview-page-down',
            ['<c-b>'] = 'preview-page-up',
          },
        },
        files = {
          prompt = 'Files ❯ ',
          multiprocess = true,
          git_icons = true,
          file_icons = true,
          color_icons = true,
          cwd_prompt = false,
          actions = {
            ['ctrl-i'] = { actions.toggle_ignore },
            ['ctrl-h'] = { actions.toggle_hidden },
          },
        },
        grep = {
          prompt = 'Grep ❯ ',
          input_prompt = 'Grep For ❯ ',
          multiprocess = true,
          git_icons = true,
          file_icons = true,
          color_icons = true,
          actions = {
            ['ctrl-i'] = { actions.toggle_ignore },
            ['ctrl-h'] = { actions.toggle_hidden },
          },
        },
        buffers = {
          prompt = 'Buffers ❯ ',
          file_icons = true,
          color_icons = true,
          sort_lastused = true,
          sort_mru = true,
          actions = {
            ['ctrl-x'] = { fn = actions.buf_del, reload = true },
          },
        },
        oldfiles = {
          prompt = 'History ❯ ',
          cwd_only = false,
          stat_file = true,
          include_current_session = true,
        },
        quickfix = {
          file_icons = true,
          git_icons = false,
        },
        lsp = {
          prompt_postfix = ' ❯ ',
          cwd_only = false,
          async_or_timeout = 5000,
          file_icons = true,
          git_icons = false,
          symbols = {
            async_or_timeout = true,
            symbol_style = 1,
            symbol_hl = function(s)
              return 'TroubleIcon' .. s
            end,
            symbol_fmt = function(s)
              return s:lower() .. '\t'
            end,
            child_prefix = false,
          },
          code_actions = {
            prompt = 'Code Actions ❯ ',
            async_or_timeout = 5000,
            previewer = vim.fn.executable 'delta' == 1 and 'codeaction_native' or nil,
          },
        },
        diagnostics = {
          prompt = 'Diagnostics ❯ ',
          cwd_only = false,
          file_icons = true,
          git_icons = false,
          diag_icons = true,
          icon_padding = '',
          multiline = true,
          signs = {
            ['Error'] = { text = icons.diagnostics.Error, texthl = 'DiagnosticError' },
            ['Warn'] = { text = icons.diagnostics.Warn, texthl = 'DiagnosticWarn' },
            ['Info'] = { text = icons.diagnostics.Info, texthl = 'DiagnosticInfo' },
            ['Hint'] = { text = icons.diagnostics.Hint, texthl = 'DiagnosticHint' },
          },
        },
        git = {
          files = {
            prompt = 'GitFiles ❯ ',
            cmd = 'git ls-files --exclude-standard',
            multiprocess = true,
            git_icons = true,
            file_icons = true,
            color_icons = true,
          },
          status = {
            prompt = 'GitStatus ❯ ',
            cmd = 'git -c color.status=false status --porcelain=v1 -u',
            file_icons = true,
            git_icons = true,
            color_icons = true,
            previewer = 'git_diff',
          },
          commits = {
            prompt = 'Commits ❯ ',
            cmd = "git log --color --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) | %C(white)%s%C(reset) %C(green)[%an]%C(reset)%C(red)%d%C(reset)' --date=short",
            preview = 'git show --color {1}',
            actions = {
              ['default'] = actions.git_checkout,
            },
          },
        },
        -- Enhanced ui_select integration
        ui_select = function(fzf_opts, items)
          return vim.tbl_deep_extend('force', fzf_opts, {
            prompt = ' ',
            winopts = {
              title = ' ' .. vim.trim((fzf_opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
              title_pos = 'center',
              width = 0.60,
              height = math.floor(math.min(vim.o.lines * 0.8, #items + 4) + 0.5),
            },
          }, fzf_opts.kind == 'codeaction' and {
            winopts = {
              layout = 'vertical',
              height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
              width = 0.5,
              preview = {
                layout = 'vertical',
                vertical = 'down:15,border-top',
                hidden = 'hidden',
              },
            },
          } or {})
        end,
      }
    end,
    config = function(_, opts)
      -- Handle default-title profile
      if opts[1] == 'default-title' then
        local function fix(t)
          t.prompt = t.prompt ~= nil and ' ' or nil
          for _, v in pairs(t) do
            if type(v) == 'table' then
              fix(v)
            end
          end
          return t
        end
        opts = vim.tbl_deep_extend('force', fix(require 'fzf-lua.profiles.default-title'), opts)
        opts[1] = nil
      end

      require('fzf-lua').setup(opts)
    end,
    init = function()
      -- Lazy load ui.select replacement
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          vim.ui.select = function(...)
            require('lazy').load { plugins = { 'fzf-lua' } }
            local opts = {}
            -- Try to get plugin opts
            local ok, lazy_config = pcall(require, 'lazy.core.config')
            if ok then
              local plugin = lazy_config.spec.plugins['fzf-lua']
              if plugin then
                local Plugin = require 'lazy.core.plugin'
                opts = Plugin.values(plugin, 'opts', false) or {}
              end
            end
            require('fzf-lua').register_ui_select(opts.ui_select or nil)
            return vim.ui.select(...)
          end
        end,
      })
    end,
    keys = {
      -- Terminal mode navigation
      { '<c-j>', '<c-j>', ft = 'fzf', mode = 't', nowait = true },
      { '<c-k>', '<c-k>', ft = 'fzf', mode = 't', nowait = true },

      -- Your existing keybindings preserved
      {
        '<leader>,',
        '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>',
        desc = 'Switch Buffer',
      },
      {
        '<leader>/',
        function()
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end
          require('fzf-lua').live_grep { cwd = get_root() }
        end,
        desc = 'Grep (Root Dir)',
      },
      { '<leader>:', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      {
        '<leader><space>',
        function()
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end
          require('fzf-lua').files { cwd = get_root() }
        end,
        desc = 'Find Files (Root Dir)',
      },

      -- Find files
      { '<leader>fb', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', desc = 'Buffers' },
      {
        '<leader>ff',
        function()
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end
          require('fzf-lua').files { cwd = get_root() }
        end,
        desc = 'Find Files (Root Dir)',
      },
      {
        '<leader>fF',
        function()
          require('fzf-lua').files { cwd = vim.fn.getcwd() }
        end,
        desc = 'Find Files (cwd)',
      },
      { '<leader>fg', '<cmd>FzfLua git_files<cr>', desc = 'Find Files (git-files)' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent' },
      {
        '<leader>fR',
        function()
          require('fzf-lua').oldfiles { cwd = vim.fn.getcwd() }
        end,
        desc = 'Recent (cwd)',
      },

      -- Git
      { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
      { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },

      -- Search
      { '<leader>s"', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
      { '<leader>fa', '<cmd>FzfLua autocmds<cr>', desc = 'Auto Commands' },
      { '<leader>fb', '<cmd>FzfLua grep_curbuf<cr>', desc = 'Buffer' },
      { '<leader>fc', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      { '<leader>fC', '<cmd>FzfLua commands<cr>', desc = 'Commands' },
      { '<leader>fd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document Diagnostics' },
      { '<leader>fD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace Diagnostics' },
      {
        '<leader>fg',
        function()
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end
          require('fzf-lua').live_grep { cwd = get_root() }
        end,
        desc = 'Grep (Root Dir)',
      },
      {
        '<leader>fG',
        function()
          require('fzf-lua').live_grep { cwd = vim.fn.getcwd() }
        end,
        desc = 'Grep (cwd)',
      },
      { '<leader>fh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Pages' },
      { '<leader>fH', '<cmd>FzfLua highlights<cr>', desc = 'Search Highlight Groups' },
      { '<leader>fj', '<cmd>FzfLua jumps<cr>', desc = 'Jumplist' },
      { '<leader>fk', '<cmd>FzfLua keymaps<cr>', desc = 'Key Maps' },
      { '<leader>fl', '<cmd>FzfLua loclist<cr>', desc = 'Location List' },
      { '<leader>fM', '<cmd>FzfLua man_pages<cr>', desc = 'Man Pages' },
      { '<leader>fm', '<cmd>FzfLua marks<cr>', desc = 'Jump to Mark' },
      { '<leader>fR', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
      { '<leader>fq', '<cmd>FzfLua quickfix<cr>', desc = 'Quickfix List' },
      {
        '<leader>fw',
        function()
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end
          require('fzf-lua').grep_cword { cwd = get_root() }
        end,
        desc = 'Word (Root Dir)',
      },
      {
        '<leader>fW',
        function()
          require('fzf-lua').grep_cword { cwd = vim.fn.getcwd() }
        end,
        desc = 'Word (cwd)',
      },
      {
        '<leader>fw',
        function()
          local function get_root()
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= '' then
              return git_root
            end
            return vim.fn.getcwd()
          end
          require('fzf-lua').grep_visual { cwd = get_root() }
        end,
        mode = 'v',
        desc = 'Selection (Root Dir)',
      },
      {
        '<leader>sW',
        function()
          require('fzf-lua').grep_visual { cwd = vim.fn.getcwd() }
        end,
        mode = 'v',
        desc = 'Selection (cwd)',
      },
      { '<leader>cC', '<cmd>FzfLua colorschemes<cr>', desc = 'Colorscheme with Preview' },

      -- LSP
      {
        '<leader>ss',
        function()
          require('fzf-lua').lsp_document_symbols()
        end,
        desc = 'Goto Symbol',
      },
      {
        '<leader>sS',
        function()
          require('fzf-lua').lsp_live_workspace_symbols()
        end,
        desc = 'Goto Symbol (Workspace)',
      },
    },
  },
}
