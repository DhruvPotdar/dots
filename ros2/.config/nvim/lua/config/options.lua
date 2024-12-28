-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_statuscolumn = {
  folds_open = "▸",
}

-- Use Tabs instead of spaces
vim.opt.expandtab = false

-- Enable Mouse Support
vim.opt.mouse = "a"

-- Enable word wrap
vim.opt.wrap = true

-- Change lualine height
vim.o.cmdheight = 0

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone,noselect"
vim.opt.swapfile = false
vim.opt.foldmethod = "expr"
