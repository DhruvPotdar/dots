vim.g.python3_host_prog = vim.fn.expand '/home/dhruvpotdar/.config/nvim/.venv/bin/python'
-- package.cpath = package.cpath .. ';/usr/local/lib/lua/5.1/?.so'
pcall(require, 'luarocks.loader')
require 'radtop'

require('mule_copy').setup()
