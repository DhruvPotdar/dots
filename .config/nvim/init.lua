-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("yorumi").setup({
  overrides = {
    --   Normal = { bg = "None" },
    --   ColorColumn = { bg = "None" },
    --   SignColumn = { bg = "None" },
    --   Folded = { bg = "None" },
    --   FoldColumn = { bg = "None" },
    --   CursorLine = { bg = "None" },
    --   CursorColumn = { bg = "None" },
    --   WhichKeyFloat = { bg = "None" },
    --   VertSplit = { bg = "None" },
  },
})

vim.o.guifont = "Fira Code Nerd Font Mono:h14" -- text below applies for VimScript
