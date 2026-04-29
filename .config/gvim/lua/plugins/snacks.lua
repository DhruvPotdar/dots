-- In your lua/plugins/snacks.lua file

-- Helper function for terminal navigation
local function term_nav(dir)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(dir)
    if win == vim.api.nvim_get_current_win() then
      if dir == 'h' then
        vim.cmd.wincmd 'l'
      elseif dir == 'j' then
        vim.cmd.wincmd 'k'
      elseif dir == 'k' then
        vim.cmd.wincmd 'j'
      elseif dir == 'l' then
        vim.cmd.wincmd 'h'
      end
    end
  end
end

-- Safe keymap setter (similar to LazyVim's function)
local function safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require('lazy.core.handler').handlers.keys
  -- Do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return {
  {
    'folke/snacks.nvim',
    enabled = true,
    -- event = 'UIEnter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      input = { enabled = true },
      -- notifier = { enabled = true },
      animate = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      toggle = { map = safe_keymap_set },
      words = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      terminal = {
        win = {
          keys = {
            nav_h = { '<C-h>', term_nav 'h', desc = 'Go to Left Window', expr = true, mode = 't' },
            nav_j = { '<C-j>', term_nav 'j', desc = 'Go to Lower Window', expr = true, mode = 't' },
            nav_k = { '<C-k>', term_nav 'k', desc = 'Go to Upper Window', expr = true, mode = 't' },
            nav_l = { '<C-l>', term_nav 'l', desc = 'Go to Right Window', expr = true, mode = 't' },
          },
        },
      },
      dashboard = {
        preset = {
          header = [[
██████╗  █████╗ ██████╗ ████████╗ ██████╗ ██████╗ 
██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
██████╔╝███████║██║  ██║   ██║   ██║   ██║██████╔╝
██╔══██╗██╔══██║██║  ██║   ██║   ██║   ██║██╔═══╝ 
██║  ██║██║  ██║██████╔╝   ██║   ╚██████╔╝██║     
╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ]],
        },
        sections = {
          { section = 'header' },
          { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          { section = 'startup' },
        },
      },
    },
    keys = {
      -- Using Nvim-notify now
      -- {
      --   '<leader>un',
      --   function()
      --     Snacks.notifier.hide()
      --   end,
      --   desc = 'Dismiss All Notifications',
      -- },
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      {
        '<leader>dps',
        function()
          Snacks.profiler.scratch()
        end,
        desc = 'Profiler Scratch Buffer',
      },
    },
  },
}
