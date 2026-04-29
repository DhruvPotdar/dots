local M = {}
function M.setup()
	-- Diagnostic configuration
	vim.diagnostic.config({
		virtual_text = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = " ",
			},
		},
		underline = false,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			source = "always",
		},
	})

	-- LSP Attach behavior
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufnr = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)

			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			-- Basic LSP mappings
			map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
			map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
			map({ "n", "v" }, "<leader>ca", function()
				require("fzf-lua").lsp_code_actions()
			end, "Code Actions")
			map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
			map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

			-- Inlay hints
			if client and client:supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				map("n", "<leader>uh", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
				end, "Toggle Inlay Hints")
			end
		end,
	})

	-- Server configurations
	local capabilities = {}
	if pcall(require, "blink.cmp") then
		capabilities = require("blink.cmp").get_lsp_capabilities()
	end

	local servers = {
		python = {
			cmd = { "ty", "server" },
			root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git", "venv", ".venv" },
		},
		cpp = {
			cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
			root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
			capabilities = { offsetEncoding = { "utf-16" } },
		},
		rust = {
			cmd = { "rust-analyzer" },
			root_markers = { "Cargo.toml", ".git" },
			settings = {
				["rust-analyzer"] = {
					cargo = { allFeatures = true },
					checkOnSave = { command = "clippy" },
					inlayHints = {
						bindingModeHints = { enabled = true },
						chainingHints = { enabled = true },
						closingBraceHints = { enabled = true },
						closureReturnTypeHints = { enabled = "always" },
						lifetimeElisionHints = { enabled = "always", useParameterNames = true },
						parameterHints = { enabled = true },
						reborrowHints = { enabled = "always" },
						renderColons = { enabled = true },
						typeHints = { enabled = true },
					},
				},
			},
		},
		toml = {
			cmd = { "taplo", "lsp", "stdio" },
			root_markers = { ".git", "Cargo.toml" },
		},
		markdown = {
			cmd = { "marksman", "server" },
			root_markers = { ".marksman.toml", ".git" },
		},
		yaml = {
			cmd = { "yaml-language-server", "--stdio" },
			root_markers = { ".git" },
		},
		bash = {
			cmd = { "bash-language-server", "start" },
			root_markers = { ".git" },
		},
		fish = {
			cmd = { "fish-lsp", "start" },
			root_markers = { ".git" },
		},
		lua = {
			cmd = { "lua-language-server" },
			root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
					telemetry = { enabled = false },
					hint = { enable = true },
				},
			},
		},
	}

	-- Auto-start LSPs based on FileType
	vim.api.nvim_create_autocmd("FileType", {
		pattern = vim.tbl_keys(servers),
		callback = function(args)
			local config = servers[args.match]
			if not config then
				return
			end

			local root_dir = vim.fs.root(args.buf, config.root_markers)
			if root_dir then
				vim.lsp.start({
					name = args.match,
					cmd = config.cmd,
					root_dir = root_dir,
					capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {}),
					settings = config.settings,
				})
			end
		end,
	})

	-- User Commands
	vim.api.nvim_create_user_command("LspInfo", function()
		local clients = vim.lsp.get_clients()
		if #clients == 0 then
			vim.notify("No active LSP clients", vim.log.levels.WARN)
			return
		end
		local msg = { "Active LSP Clients:" }
		for _, client in ipairs(clients) do
			table.insert(
				msg,
				string.format("- %s (id: %d, root: %s)", client.name, client.id, client.config.root_dir or "none")
			)
		end
		vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO)
	end, { desc = "Show active LSP clients" })

	vim.api.nvim_create_user_command("LspRestart", function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients == 0 then
			vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
			return
		end
		for _, client in ipairs(clients) do
			local name = client.name
			local config = client.config
			client.stop()
			vim.defer_fn(function()
				vim.lsp.start(config)
				vim.notify("Restarted " .. name, vim.log.levels.INFO)
			end, 500)
		end
	end, { desc = "Restart LSP clients for current buffer" })

	vim.api.nvim_create_user_command("LspStop", function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		for _, client in ipairs(clients) do
			client.stop()
			vim.notify("Stopped " .. client.name, vim.log.levels.INFO)
		end
	end, { desc = "Stop LSP clients for current buffer" })

	vim.api.nvim_create_user_command("LspStart", function()
		vim.cmd("doautocmd FileType")
		vim.notify("Triggered LSP start logic", vim.log.levels.INFO)
	end, { desc = "Manually trigger LSP start logic" })

	vim.api.nvim_create_user_command("LspLog", function()
		vim.cmd("edit " .. vim.lsp.get_log_path())
	end, { desc = "Open LSP log" })
end

return M
