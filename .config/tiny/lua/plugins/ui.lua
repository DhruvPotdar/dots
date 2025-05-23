return {
	{
		"rose-pine/neovim",
    enabled = false,
		lazy = false,
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				variant = "moon",
				styles = {
					transparency = true,
				},
			})
			vim.cmd([[colorscheme rose-pine]])
		end,
	},
	{
		"yorumicolors/yorumi.nvim",
		config = function()
			vim.cmd([[colorscheme yorumi]])
		end,
	},
	{
		"stevearc/dressing.nvim",
		config = true,
		lazy = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},
}
