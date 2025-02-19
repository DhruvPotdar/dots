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

-- Remove the empty buffer that opens when you open nvim in a directory
vim.o.hidden = false

local o, opt = vim.o, vim.opt

-- Appearance
o.breakindent = true -- Indent wrapped lines to match line start
o.cursorline = true -- Highlight current line
o.linebreak = true -- Wrap long lines at 'breakat' (if 'wrap' is set)
o.number = true -- Show line numbers
o.relativenumber = true -- Show line numbers
o.splitbelow = true -- Horizontal splits will be below
o.splitright = true -- Vertical splits will be to the right

o.ruler = false -- Don't show cursor position in command line
o.showmode = false -- Don't show mode in command line
o.wrap = false -- Display long lines as just one line

o.signcolumn = "yes" -- Always show sign column (otherwise it will shift text)
o.fillchars = "eob: " -- Don't show `~` outside of buffer

o.scrolloff = 15
o.tabstop = 2
o.shiftwidth = 2
o.conceallevel = 3
o.expandtab = true

o.relativenumber = true
o.number = true

-- Editing
o.ignorecase = true -- Ignore case when searching (use `\C` to force not doing that)
o.incsearch = true -- Show search results while typing
o.infercase = true -- Infer letter cases for a richer built-in keyword completion
o.smartcase = true -- Don't ignore case when searching if pattern has upper case
o.smartindent = true -- Make indenting smart
o.inccommand = "split" -- Preview substitutions live, as you type!

-- Folds
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldlevelstart = 99

-- Extra UI options
o.pumblend = 0 -- Make builtin completion menus slightly transparent
o.pumheight = 10 -- Make popup menu smaller
o.winblend = 0 -- Make floating windows slightly transparent
