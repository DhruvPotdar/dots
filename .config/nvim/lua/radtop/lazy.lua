-- bootstrap lazy.nvim, and plugins
-- Copied from the default lazyvim spec
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
-- Bootstral lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { import = 'plugins' },
}

local opts = {
  ui = {
    border = 'rounded',
  },
  install = {
    colorscheme = { 'gruvbox' },
  },
}
require('lazy').setup(plugins, opts)
