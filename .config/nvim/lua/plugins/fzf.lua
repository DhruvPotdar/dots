return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    dependencies = {
      'echasnovski/mini.icons',
    },
    opts = function()
      local actions = require('fzf-lua.actions')
      local config = require('fzf-lua.config')

      -- Utility for root directory
      local function get_root()
        local git_root = vim.fn.systemlist('git rev-parse --show-toplevel 2>/dev/null')[1]
        if vim.v.shell_error == 0 and git_root and git_root ~= '' then
          return git_root
        end
        return vim.fn.getcwd()
      end

      -- Enhanced keymaps for fzf interface
      config.defaults.keymap.fzf['ctrl-q'] = 'select-all+accept'
      config.defaults.keymap.fzf['ctrl-u'] = 'half-page-up'
      config.defaults.keymap.fzf['ctrl-d'] = 'half-page-down'
      config.defaults.keymap.fzf['ctrl-x'] = 'jump'
      config.defaults.keymap.fzf['ctrl-f'] = 'preview-page-down'
      config.defaults.keymap.fzf['ctrl-b'] = 'preview-page-up'

      -- Toggle root dir / cwd functionality
      config.defaults.actions.files['ctrl-r'] = function(_, ctx)
        local opt = vim.deepcopy(ctx.__call_opts)
        opt.root = not opt.root
        opt.cwd = opt.root and get_root() or vim.fn.getcwd()
        require('fzf-lua').files(opt)
      end
      config.set_action_helpstr(config.defaults.actions.files['ctrl-r'], 'toggle-root-dir')

      return {
        'default-title',
        fzf_colors = true,
        fzf_opts = {
          ['--layout=reverse'] = true,
        },
        defaults = {
          formatter = 'path.dirname_first',
          file_ignore_patterns = {
            '%.git/', 'node_modules/', '%.pyc', '__pycache__/',
            '%.class', '%.o', '%.a', '%.out', '%.pdf', '%.mkv',
            '%.mp4', '%.zip',
          },
        },
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.55,
          border = 'rounded',
          preview = {
            scrollbar = 'border',
            scrollchars = { '┃', '' },
            delay = 10,
            winopts = {
              number = true,
              relativenumber = false,
              cursorline = true,
              signcolumn = 'no',
            },
          },
        },
        keymap = {
          builtin = {
            ['<F1>'] = 'toggle-help',
            ['<F2>'] = 'toggle-fullscreen',
            ['<F3>'] = 'toggle-preview-wrap',
            ['<F4>'] = 'toggle-preview',
            ['<c-f>'] = 'preview-page-down',
            ['<c-b>'] = 'preview-page-up',
          },
        },
        files = {
          prompt = 'Files ❯ ',
          git_icons = true,
          file_icons = true,
          color_icons = true,
          fzf_opts = {
            ['--header'] = ':: <C-h> hidden, <C-i> ignore, <C-r> root',
          },
          actions = {
            ['ctrl-i'] = { actions.toggle_ignore },
            ['ctrl-h'] = { actions.toggle_hidden },
          },
        },
        grep = {
          prompt = 'Grep ❯ ',
          input_prompt = 'Grep For ❯ ',
          git_icons = true,
          file_icons = true,
          color_icons = true,
          fzf_opts = {
            ['--header'] = ':: <C-h> hidden, <C-i> ignore, <C-r> root',
          },
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
        lsp = {
          prompt_postfix = ' ❯ ',
          cwd_only = false,
          symbols = {
            symbol_style = 1,
            child_prefix = false,
          },
          code_actions = {
            prompt = 'Code Actions ❯ ',
            previewer = vim.fn.executable('delta') == 1 and 'codeaction_native' or nil,
            async_or_timeout = 5000,
            winopts = {
              height = 0.3,
              width = 0.6,
              row = 0.4,
              preview = {
                hidden = 'hidden',
              },
            },
          },
        },
        git = {
          files = {
            prompt = 'GitFiles ❯ ',
            cmd = 'git ls-files --exclude-standard',
          },
          status = {
            prompt = 'GitStatus ❯ ',
            previewer = 'git_diff',
          },
          commits = {
            prompt = 'Commits ❯ ',
            actions = {
              ['default'] = actions.git_checkout,
            },
          },
          bcommits = {
            prompt = 'BCommits ❯ ',
          },
          branches = {
            prompt = 'Branches ❯ ',
          },
        },
        -- Profiles and suggested pickers
        profiles = {
          ['telescope'] = {
            winopts = {
              height = 0.40,
              width = 0.95,
              row = 0.95,
              col = 0.5,
              preview = {
                layout = 'vertical',
                vertical = 'up:60%',
              },
            },
          },
          ['max-perf'] = {
            previewers = {
              builtin = {
                syntax_limit_b = 1024 * 100, -- 100KB
              },
            },
          },
          ['borderless'] = {
            winopts = {
              border = 'none',
            },
          },
        },
      }
    end,
    config = function(_, opts)
      require('fzf-lua').setup(opts)
    end,
    keys = {
      -- Ported from your config
      { '<leader>,', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', desc = 'Switch Buffer' },
      { '<leader>:', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      { '<leader><space>', function() require('fzf-lua').files({ cwd = require('mini.misc').find_root() }) end, desc = 'Find Files (Root Dir)' },
      { '<leader>/', function() require('fzf-lua').live_grep({ cwd = require('mini.misc').find_root() }) end, desc = 'Grep (Root Dir)' },
      { '<leader>ff', function() require('fzf-lua').files({ cwd = require('mini.misc').find_root() }) end, desc = 'Find Files (Root Dir)' },
      { '<leader>fF', '<cmd>FzfLua files<cr>', desc = 'Find Files (cwd)' },
      { '<leader>fg', '<cmd>FzfLua git_files<cr>', desc = 'Find Files (git-files)' },
      { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Recent' },
      { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
      { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
      { '<leader>s"', '<cmd>FzfLua registers<cr>', desc = 'Registers' },
      { '<leader>fa', '<cmd>FzfLua autocmds<cr>', desc = 'Auto Commands' },
      { '<leader>fc', '<cmd>FzfLua command_history<cr>', desc = 'Command History' },
      { '<leader>fC', '<cmd>FzfLua commands<cr>', desc = 'Commands' },
      { '<leader>fd', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Document Diagnostics' },
      { '<leader>fD', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Workspace Diagnostics' },
      { '<leader>fh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Pages' },
      { '<leader>fk', '<cmd>FzfLua keymaps<cr>', desc = 'Key Maps' },
      { '<leader>fm', '<cmd>FzfLua marks<cr>', desc = 'Jump to Mark' },
      { '<leader>fR', '<cmd>FzfLua resume<cr>', desc = 'Resume' },
      { '<leader>fq', '<cmd>FzfLua quickfix<cr>', desc = 'Quickfix List' },
      { '<leader>cC', '<cmd>FzfLua colorschemes<cr>', desc = 'Colorscheme with Preview' },

      -- LSP Ported from autocmds
      { 'gr', '<cmd>FzfLua lsp_references<cr>', desc = 'Goto References' },
      { 'gi', '<cmd>FzfLua lsp_implementations<cr>', desc = 'Goto Implementation' },
      { 'gd', '<cmd>FzfLua lsp_definitions<cr>', desc = 'Goto Definition' },
      { 'gO', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Document Symbols' },
      { 'gW', '<cmd>FzfLua lsp_live_workspace_symbols<cr>', desc = 'Workspace Symbols' },

      -- Suggested additional pickers (10+)
      { '<leader>f/', '<cmd>FzfLua blines<cr>', desc = 'Grep Current Buffer' },
      { '<leader>fL', '<cmd>FzfLua lines<cr>', desc = 'Grep All Open Buffers' },
      { '<leader>fv', '<cmd>FzfLua variables<cr>', desc = 'Vim Variables' },
      { '<leader>ft', '<cmd>FzfLua tags<cr>', desc = 'Tags' },
      { '<leader>fT', '<cmd>FzfLua btags<cr>', desc = 'Buffer Tags' },
      { '<leader>fgb', '<cmd>FzfLua git_branches<cr>', desc = 'Git Branches' },
      { '<leader>fgs', '<cmd>FzfLua git_stash<cr>', desc = 'Git Stash' },
      { '<leader>fp', '<cmd>FzfLua profiles<cr>', desc = 'FzfLua Profiles' },
      { '<leader>fs', '<cmd>FzfLua spell_suggest<cr>', desc = 'Spell Suggest' },
      { '<leader>fH', '<cmd>FzfLua highlights<cr>', desc = 'Highlights' },
      { '<leader>fi', '<cmd>FzfLua lsp_incoming_calls<cr>', desc = 'LSP Incoming Calls' },
      { '<leader>fo', '<cmd>FzfLua lsp_outgoing_calls<cr>', desc = 'LSP Outgoing Calls' },
      { '<leader>fe', '<cmd>FzfLua files cwd=~/.config/gvim<cr>', desc = 'Edit Config' },
      { '<leader>f.', '<cmd>FzfLua files cwd=~<cr>', desc = 'Find in Home' },
    },
  },
}
