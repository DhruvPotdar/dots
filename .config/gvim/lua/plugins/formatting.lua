return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  opts = {
    format_on_save = {
      timeout_ms = 500,
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      -- Lua
      lua = { 'stylua' },

      -- Python
      python = { 'black' },

      -- JavaScript / TypeScript
      javascript = {
        'prettierd',
        prettier = { command = 'prettier' },
        stop_after_first = true,
      },
      typescript = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      javascriptreact = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      typescriptreact = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },

      -- C / C++
      c = { 'clang-format' },
      cpp = { 'clang-format' },

      -- Rust
      rust = { 'rustfmt' },

      -- Web
      html = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      css = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      scss = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      json = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      jsonc = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      yaml = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },
      markdown = { 'prettierd', prettier = { command = 'prettier' }, stop_after_first = true },

      -- Shell
      sh = { 'shfmt' },
      bash = { 'shfmt' },

      -- XML
      xml = { 'xmlformat' },

      -- TOML
      toml = { 'taplo' },
    },
    formatters = {
      ['clang-format'] = { prepend_args = { '--style=file', '--fallback-style=LLVM' } },
      black = {
        prepend_args = { '--line-length', '88' },
      },
      prettier = { prepend_args = { '--tab-width', '4', '--single-quote' } },
      shfmt = { prepend_args = { '-i', '2', '-ci' } },
    },
  },
}
