-- init.lua or plugins/lsp.lua

local utils = require 'radtop.utils'
local icons = require 'radtop.icons'

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'nvim-lua/plenary.nvim',
      'nvimtools/none-ls.nvim',
    },
    opts = function()
      return {
        diagnostics = {
          underline = false,
          update_in_insert = false,
          virtual_text = { current_line = true },
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
        inlay_hints = { enabled = true },
        codelens = { enabled = true },
        capabilities = {
          workspace = { fileOperations = { didRename = true, willRename = true } },
        },
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                codeLens = { enable = true },
                completion = { callSnippet = 'Replace' },
                doc = { privateName = { '^_' } },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = 'Disable',
                  semicolon = 'Disable',
                  arrayIndex = 'Disable',
                },
              },
            },
          },
          basedpyright = {
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = 'standard', -- Can be "off", "basic", or "strict" (adjust based on your needs)
                  reportMissingTypeStubs = 'none', -- "none", "warning", or "error"
                  reportUnusedCallResult = 'warning', -- "none", "warning", "error"
                  reportUnknownType = 'warning', -- "none", "warning", or "error"
                  reportUnknownMemberType = 'none', -- Ensure we're not referencing members with unknown types
                  reportMissingFunctionType = 'warning', -- Warn when function types are missing
                  reportMissingVariableType = 'warning', -- Ensure variables are typed
                  reportUnusedVariable = 'warning', -- Warn about unused variables, but don't be overly strict
                  stubPath = { './typings', './stubs' }, -- Adjust paths to stubs if necessary
                  reportInconsistentReturnType = 'warning', -- Ensure consistent return types across functions
                  maxNumberOfProblems = 100, -- Limit the number of diagnostics shown (can adjust based on your preference)
                  inlay_hints = {
                    generic_tfalseyped = true,
                  },
                },
              },
            },
          },
          clangd = {
            cmd = {
              'clangd',
              '--background-index',
              '--function-arg-placeholders=1',
              '--background-index',
              '--background-index-priority=normal',
              '--clang-tidy',
              '--completion-style=detailed',
              '--cross-file-rename',
              '--header-insertion=iwyu',
              '--header-insertion-decorators',
              '--enable-config',
              '--j 8',
              '--malloc-trim',
              '--pch-storage=memory',
            },
          },
        },
      }
    end,

    config = function(_, opts)
      if vim.fn.has 'nvim-0.10.0' == 0 then
        for sev, icon in pairs(opts.diagnostics.signs.text) do
          local name = 'DiagnosticSign' .. vim.diagnostic.severity[sev]:lower():gsub('^%l', string.upper)
          vim.fn.sign_define(name, { text = icon, texthl = name })
        end
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      require('mason').setup { ui = { border = 'rounded' } }
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(opts.servers),
        handlers = {
          function(server)
            local cfg = vim.tbl_deep_extend('force', { capabilities = vim.lsp.protocol.make_client_capabilities() }, opts.servers[server] or {})
            require('lspconfig')[server].setup(cfg)
          end,
        },
      }

      local caps = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        (pcall(require, 'cmp_nvim_lsp') and require('cmp_nvim_lsp').default_capabilities() or {}),
        (pcall(require, 'blink.cmp') and require('blink.cmp').get_lsp_capabilities() or {}),
        opts.capabilities or {}
      )

      local function on_attach(client, bufnr)
        if client.name == 'clangd' or client.name == 'basedpyright' then
          client.server_capabilities.documentFormattingProvider = true
        end
      end

      for srv, srv_opts in pairs(opts.servers) do
        local cfg = vim.tbl_deep_extend('force', { capabilities = caps, on_attach = on_attach }, srv_opts or {})
        require('lspconfig')[srv].setup(cfg)
      end

      local null_ls = require 'null-ls'
      null_ls.setup {
        debug = false,
        sources = {
          null_ls.builtins.formatting.black.with { extra_args = { '--fast' } },
          null_ls.builtins.formatting.isort.with { extra_args = { '--profile', 'black' } },
          -- null_ls.builtins.diagnostics.ruff,
          null_ls.builtins.formatting.clang_format.with { extra_args = { '--style=file' } },
        },
        on_attach = function(client, bufnr)
          -- vim.api.nvim_clear_autocmds { group = 'LspFormatting', buffer = bufnr }
          vim.api.nvim_create_augroup('LspFormatting', {})
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = 'LspFormatting',
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { bufnr = bufnr }
            end,
          })
        end,
      }
    end,
  },
}
