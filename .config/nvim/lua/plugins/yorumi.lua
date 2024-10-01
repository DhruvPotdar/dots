return {
  -- add yorumi
  {
    "yorumicolors/yorumi.nvim",
    config = function()
      require("yorumi")
      vim.cmd([[
      colorscheme yorumi
    ]])
    end,
  },
}
