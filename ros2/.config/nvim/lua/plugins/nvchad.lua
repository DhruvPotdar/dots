return {
  "nvim-lua/plenary.nvim",
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvchad/ui",
    -- enabled = false,
    config = function()
      require("nvchad")
      vim.opt.statusline = ""
    end,
  },

  {
    "nvchad/base46",
    -- enabled = false,
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
      -- require("base46").load_theme("yorumi")
    end,
  },
  {
    "nvchad/volt", -- optional, needed for theme switcher
    -- enabled = false,
  },
  -- or just use Telescope themes
}
