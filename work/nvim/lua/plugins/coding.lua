return {
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'rafamadriz/friendly-snippets',
    event = 'VeryLazy',
    -- add blink.compat to dependencies
  },
  {
    'L3MON4D3/LuaSnip',
    lazy = true,
    -- build = (not LazyVim.is_win()) and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp" or nil,
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        event = 'VeryLazy',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
  },
  -- { 'saadparwaiz1/cmp_luasnip' },
  {
    'jiaoshijie/undotree',
    event = 'BufEnter',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { '<leader>ut', "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },
  {
    'danymat/neogen',
    config = true,
  },
  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
  },
}
