return {
	-- UI Elements (Noice, Dropbar, Edgy, Outline)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			views = {
				mini = { border = { style = "rounded" } },
				cmdline_popup = {
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					filter_options = { win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:NoiceCmdlinePopupBorder" } },
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = 8,
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "NormalFloat", FloatBorder = "NoiceCmdlinePopupBorder" },
					},
				},
			},
			presets = {
				inc_rename = true,
				bottom_search = false,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
	{
		"Bekaboo/dropbar.nvim",
		event = "VeryLazy",
		config = function()
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in Dropbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
		end,
	},
	-- Utilities & Fixes
	{
		"mikesmithgh/kitty-scrollback.nvim",
		lazy = true,
		cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth", "KittyScrollbackGenerateCommandLineEditing" },
		event = { "User KittyScrollbackLaunch" },
		config = function()
			require("kitty-scrollback").setup()
		end,
	},
	{
		"kevinhwang91/nvim-bqf",
		event = "FileType qf",
		opts = {},
	},
	{
		"stevearc/quicker.nvim",
		event = "FileType qf",
		opts = {},
	},
	{
		"rasulomaroff/reactive.nvim",
		event = "VeryLazy",
		opts = {
			builtin = {
				cursorline = true,
				cursor = false,
				modemsg = false,
			},
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "Avante" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
		opts = {
			code = {
				style = "language",
				sign = false,
				width = "block",
				language_border = " ",
				language_left = "",
				language_right = "",
			},
			heading = {
				sign = true,
				position = "overlay",
				width = "block",
			},
			completions = {
				blink = { enabled = true },
				lsp = { enabled = true },
			},
		},
	},
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gdiffsplit" },
	},
	{
		"fei6409/log-highlight.nvim",
		ft = { "log" },
		opts = {
			keyword = {
				warning = { "obstacle", "trip_status" },
				pass = { "final route:" },
			},
		},
	},
	{
		"3rd/image.nvim",
		build = false,
		ft = { "markdown", "Avante" },
		opts = {
			processor = "magick_cli",
			backend = "kitty",
			integrations = {},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			menu = {
				width = vim.api.nvim_win_get_width(0) - 4,
			},
			settings = {
				save_on_toggle = true,
			},
		},
		keys = function()
			local keys = {
				{
					"<leader>H",
					function()
						require("harpoon"):list():add()
					end,
					desc = "Harpoon File",
				},
				{
					"<leader>h",
					function()
						local harpoon = require("harpoon")
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "Harpoon Quick Menu",
				},
			}
			for i = 1, 5 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						require("harpoon"):list():select(i)
					end,
					desc = "Harpoon to File " .. i,
				})
			end
			return keys
		end,
		config = function()
			require("harpoon"):setup()
		end,
	},
	{
		"chrisgrieser/nvim-spider",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "w", "<cmd>lua require('spider').motion('w')<cr>", mode = { "n", "o", "x" } },
			{ "e", "<cmd>lua require('spider').motion('e')<cr>", mode = { "n", "o", "x" } },
			{ "b", "<cmd>lua require('spider').motion('b')<cr>", mode = { "n", "o", "x" } },
		},
	},
}
