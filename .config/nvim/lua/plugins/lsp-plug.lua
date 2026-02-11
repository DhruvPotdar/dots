local icons = require 'radtop.icons'
return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'mason-org/mason.nvim',
      { 'mason-org/mason-lspconfig.nvim', config = function() end },
    },
    opts = {
      diagnostics = {
        underline = false,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = 'if_many',
          prefix = '●',
          current_line = true,
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
          },
        },
      },
      inlay_hints = {
        enabled = true,
        exclude = { 'vue' },
      },
      codelens = {
        enabled = true,
      },
      folds = {
        enabled = true,
      },
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      -- format = {
      --   formatting_options = nil,
      --   timeout_ms = nil,
      -- },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = 'Replace',
              },
              doc = {
                privateName = { '^_' },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = 'Disable',
                semicolon = 'Disable',
                arrayIndex = 'Disable',
              },
              telemetry = { enable = false },
            },
          },
        },

        clangd = {
          cmd = { 'clangd', '--background-index', '--clang-tidy' },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
          root_dir = function()
            local util = require('lspconfig').util
            return util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git')
          end,
          init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
          },
        },

        -- basedpyright = {
        --   settings = {
        --     basedpyright = {
        --       analysis = {
        --         -- Enforcing basic type checking without being too strict
        --         typeCheckingMode = 'standard', -- Can be "off", "basic", or "strict" (adjust based on your needs)
        --
        --         -- Limit diagnostics to open files only to reduce clutter
        --         diagnosticMode = 'openFilesOnly', -- Only check open files for issues
        --
        --         -- Avoid errors about missing type stubs, but you can choose to show warnings for them if needed
        --         reportMissingTypeStubs = 'none', -- "none", "warning", or "error"
        --
        --         -- Avoid too many warnings about unused call results, but report them as a warning
        --         reportUnusedCallResult = 'warning', -- "none", "warning", "error"
        --
        --         -- Suppress unknown type errors but allow warnings for potentially problematic code
        --         reportUnknownType = 'warning', -- "none", "warning", or "error"
        --
        --         -- Suggesting a good coding practice: avoid unknown members on dynamic types
        --         reportUnknownMemberType = 'none', -- Ensure we're not referencing members with unknown types
        --
        --         -- Enforcing type annotations for functions and methods for better type safety
        --         reportMissingFunctionType = 'warning', -- Warn when function types are missing
        --
        --         -- Enforce variable type annotations for better clarity
        --         reportMissingVariableType = 'warning', -- Ensure variables are typed
        --
        --         -- Suppress false positives for non-essential diagnostics, but show important ones
        --         reportUnusedVariable = 'warning', -- Warn about unused variables, but don't be overly strict
        --
        --         -- Use stub files for packages if necessary to improve type safety
        --         stubPath = { './typings', './stubs' }, -- Adjust paths to stubs if necessary
        --
        --         -- Enforce a clear, maintainable code style by checking for type mismatches
        --         reportInconsistentReturnType = 'warning', -- Ensure consistent return types across functions
        --
        --         -- Optionally, set max number of diagnostics to avoid overwhelming the screen
        --         maxNumberOfProblems = 100, -- Limit the number of diagnostics shown (can adjust based on your preference)
        --
        --         inlay_hints = {
        --           generic_tfalseyped = true,
        --         },
        --       },
        --     },
        --   },
        -- },

        ty = {},
      },
      setup = {},
    },
    config = vim.schedule_wrap(function(_, opts)
      -- Setup diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Setup inlay hints, codelens, folds via autocmd
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if opts.inlay_hints.enabled and client.supports_method 'textDocument/inlayHint' then
            if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ''
              and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
            then
              vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            end
          end
          if opts.folds.enabled and client.supports_method 'textDocument/foldingRange' then
            -- vim.bo[buffer].foldmethod = 'expr'
            -- vim.bo[buffer].foldexpr = 'v:lua.vim.lsp.foldexpr()'
          end
          if opts.codelens.enabled and vim.lsp.codelens and client.supports_method 'textDocument/codeLens' then
            vim.lsp.codelens.refresh { bufnr = buffer }
            vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
              buffer = buffer,
              callback = function()
                vim.lsp.codelens.refresh { bufnr = buffer }
              end,
            })
          end
        end,
      })

      -- Get all servers available through mason-lspconfig
      local have_mason, mlsp = pcall(require, 'mason-lspconfig')
      local have_mason, mlsp = pcall(require, 'mason-lspconfig')
      local mason_all = {}
      if have_mason then
        mason_all = mlsp.get_available_servers()
      end

      local ensure_installed = {}
      local exclude_automatic_enable = {}

      local function configure(server)
        local server_opts = vim.tbl_deep_extend('force', {
          capabilities = vim.deepcopy(opts.capabilities),
          on_attach = lsp_keymaps.on_attach,
        }, opts.servers[server] or {})
        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return true
          end
        elseif opts.setup['*'] then
          if opts.setup['*'](server, server_opts) then
            return true
          end
        end
        require('lspconfig')[server].setup(server_opts)
        return false -- Let mason-lspconfig handle enabling if applicable
      end

      for server, server_opts in pairs(opts.servers) do
        server_opts = server_opts == true and {} or server_opts
        if server_opts.enabled ~= false then
          if server_opts.mason == false or not vim.tbl_contains(mason_all, server) then
            configure(server)
            exclude_automatic_enable[#exclude_automatic_enable + 1] = server
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        else
          exclude_automatic_enable[#exclude_automatic_enable + 1] = server
        end
      end

      if have_mason then
        mlsp.setup {
          ensure_installed = ensure_installed,
          handlers = { configure },
          automatic_installation = {
            exclude = exclude_automatic_enable,
          },
        }
      end
    end),
  },

  -- mason
  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    build = ':MasonUpdate',
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
      },
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          vim.api.nvim_exec_autocmds('FileType', { buffer = vim.api.nvim_get_current_buf() })
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
