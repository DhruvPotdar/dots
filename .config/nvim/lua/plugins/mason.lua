return {
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"ty",
				"clangd",
				"rust-analyzer",
				"bash-language-server",
				"marksman",
				"yaml-language-server",
				"taplo",
				"stylua",
				"shfmt",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				-- Re-trigger FileType so lsp.lua auto-starts the newly installed server
				vim.defer_fn(function()
					vim.api.nvim_exec_autocmds("FileType", { buffer = vim.api.nvim_get_current_buf() })
				end, 100)
			end)
			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end)
		end,
	},
}
