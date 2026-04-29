return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			statuscolumn = { enabled = true },
			input = { enabled = true },
			bigfile = { enabled = true },
			quickfile = { enabled = true },
			lazygit = { enabled = true },
		},
		keys = {
			{ "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit" },
		},
	},
}
