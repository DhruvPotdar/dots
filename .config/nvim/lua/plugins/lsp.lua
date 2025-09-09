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
                  -- Enforcing basic type checking without being too strict
                  typeCheckingMode = 'basic', -- Can be "off", "basic", or "strict" (adjust based on your needs)

                  -- Limit diagnostics to open files only to reduce clutter
                  diagnosticMode = 'openFilesOnly', -- Only check open files for issues

                  -- Avoid errors about missing type stubs, but you can choose to show warnings for them if needed
                  reportMissingTypeStubs = 'none', -- "none", "warning", or "error"

                  -- Avoid too many warnings about unused call results, but report them as a warning
                  reportUnusedCallResult = 'warning', -- "none", "warning", "error"

                  -- Suppress unknown type errors but allow warnings for potentially problematic code
                  reportUnknownType = 'warning', -- "none", "warning", or "error"

                  -- Suggesting a good coding practice: avoid unknown members on dynamic types
                  reportUnknownMemberType = 'none', -- Ensure we're not referencing members with unknown types

                  -- Enforcing type annotations for functions and methods for better type safety
                  reportMissingFunctionType = 'warning', -- Warn when function types are missing

                  -- Enforce variable type annotations for better clarity
                  reportMissingVariableType = 'warning', -- Ensure variables are typed
                  reportAssignmentType = 'none',

                  -- Suppress false positives for non-essential diagnostics, but show important ones
                  reportUnusedVariable = 'warning', -- Warn about unused variables, but don't be overly strict

                  -- Use stub files for packages if necessary to improve type safety
                  stubPath = { './typings', './stubs' }, -- Adjust paths to stubs if necessary

                  -- Enforce a clear, maintainable code style by checking for type mismatches
                  reportInconsistentReturnType = 'warning', -- Ensure consistent return types across functions

                  -- Optionally, set max number of diagnostics to avoid overwhelming the screen
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
              -- '--cross-file-rename',
              '--header-insertion=iwyu',
              '--header-insertion-decorators',
              '--enable-config',
              '-j=8',
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
