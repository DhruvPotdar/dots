return {
  "ErickKramer/nvim-ros2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- Add any custom options here
    autocmds = true,
    telescope = true,
    treesitter = true,
  },
  keys = {
    { "<leader>rte", "<cmd>Telescope ros2 topics_echo <cr>", desc = "ROS2 Topics Echo" },
    { "<leader>rti", "<cmd>Telescope ros2 topics_info<cr>", desc = "ROS2 Topics Info" },
    { "<leader>rni", "<cmd>Telescope ros2 nodes<cr>", desc = "ROS2 Nodes Info" },
  },
}
