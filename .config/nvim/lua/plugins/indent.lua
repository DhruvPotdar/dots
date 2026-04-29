return {
	{
		"nvim-mini/mini.indentscope",
		enabled = false,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = {
				char = "▏",
				highlight = "IblIndentGray",
			},
			scope = {
				enabled = false,
				show_start = false,
				show_end = false,
			},
		},
		config = function(_, opts)
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "IblIndentGray", { fg = "#3f4247", nocombine = true })
			end)
			require("ibl").setup(opts)
		end,
	},
}
