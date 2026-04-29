return {
	{
		"echasnovski/mini.nvim",
		version = false,
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		config = function()
			-- ── Startup ─────────────────────────────────────────────────────────────
			-- Modules that should be available immediately

			-- Basics
			require("mini.basics").setup({
				options = { basic = false },
				mappings = {
					windows = true,
					move_with_alt = false,
				},
			})

			-- Icons
			local ext3_blocklist = { scm = true, txt = true, yml = true }
			local ext4_blocklist = { json = true, yaml = true }
			require("mini.icons").setup({
				use_file_extension = function(ext, _)
					return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
				end,
			})
			vim.schedule(function()
				if _G.MiniIcons then
					MiniIcons.mock_nvim_web_devicons()
					MiniIcons.tweak_lsp_kind()
				end
			end)

			-- Others
			require("mini.notify").setup()
			require("mini.sessions").setup()
			require("mini.starter").setup()
			-- ── Statusline highlights ────────────────────────────────────────────
			local function hi(name, opts)
				vim.api.nvim_set_hl(0, name, opts)
			end

			local function setup_sl_hl()
				local c = {
					normal = "#658594",
					insert = "#87A987",
					visual = "#B6927B",
					replace = "#C4746E",
					command = "#C4B28A",
					other = "#737C73",
					mode_fg = "#1D1C19",
					loc_bg = "#363646",
					loc_fg = "#9CABCA",
					folder = "#957FB8",
					filename = "#DCD7BA",
					gitbranch = "#7E9CD8",
					gitstatus = "#87A987",
					filetype = "#6A9589",
				}
				for _, m in ipairs({
					{ "MiniStatuslineModeNormal", c.normal },
					{ "MiniStatuslineModeInsert", c.insert },
					{ "MiniStatuslineModeVisual", c.visual },
					{ "MiniStatuslineModeReplace", c.replace },
					{ "MiniStatuslineModeCommand", c.command },
					{ "MiniStatuslineModeOther", c.other },
				}) do
					hi(m[1], { fg = m[2], bg = "none", bold = true })
					hi(m[1] .. "Sep", { fg = m[2], bg = "none" })
				end
				hi("MiniStatuslineLocation", { fg = c.loc_fg, bg = "none", bold = true })
				hi("MiniStatuslineLocationSep", { fg = c.loc_bg, bg = "none" })
				hi("MiniStatuslineFolder", { fg = c.folder, bg = "none" })
				hi("MiniStatuslineFilename", { fg = c.filename, bg = "none", bold = true })
				hi("MiniStatuslineGitBranch", { fg = c.gitbranch, bg = "none" })
				hi("MiniStatuslineGitAdd", { fg = "#87A987", bg = "none" })
				hi("MiniStatuslineGitChange", { fg = "#C4B28A", bg = "none" })
				hi("MiniStatuslineGitDelete", { fg = "#C4746E", bg = "none" })
				hi("MiniStatuslineFiletype", { fg = c.filetype, bg = "none" })
				hi("MiniStatuslineInactive", { fg = c.other, bg = "none" })
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("MiniStatuslineHl", { clear = true }),
				callback = setup_sl_hl,
			})
			setup_sl_hl()

			require("mini.statusline").setup({
				content = {
					active = function()
						local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })

						local function h(g)
							return "%#" .. g .. "#"
						end
						local po = "" -- U+E0B6: rounded pill open  (left edge)
						local pc = "" -- U+E0B4: rounded pill close (right edge)

						-- Folder / repo name with icon
						local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						local dir_icon = ""
						if _G.MiniIcons then
							local ok, icon = pcall(MiniIcons.get, "directory", cwd)
							if ok then
								dir_icon = icon .. " "
							end
						end

						-- Diagnostics with MiniIcons
						local diag_parts = {}
						if vim.bo.buftype == "" then
							for _, d in ipairs({
								{ vim.diagnostic.severity.ERROR, " ", "DiagnosticError" },
								{ vim.diagnostic.severity.WARN, " ", "DiagnosticWarn" },
								{ vim.diagnostic.severity.HINT, " ", "DiagnosticHint" },
								{ vim.diagnostic.severity.INFO, "󰋽 ", "DiagnosticInfo" },
							}) do
								local n = #vim.diagnostic.get(0, { severity = d[1] })
								if n > 0 then
									table.insert(diag_parts, h(d[3]) .. d[2] .. n)
								end
							end
						end

						-- Git branch from mini.git
						local branch = (vim.b.minigit_summary or {}).head_name or ""

						-- Git diff stats from gitsigns
						local gs = vim.b.gitsigns_status_dict or {}
						local diff_parts = {}
						if (gs.added or 0) > 0 then
							table.insert(diff_parts, h("MiniStatuslineGitAdd") .. "󰐖 " .. gs.added)
						end
						if (gs.changed or 0) > 0 then
							table.insert(diff_parts, h("MiniStatuslineGitChange") .. " " .. gs.changed)
						end
						if (gs.removed or 0) > 0 then
							table.insert(diff_parts, h("MiniStatuslineGitDelete") .. " " .. gs.removed)
						end

						-- Filetype icon for the filename
						local ft = vim.bo.filetype
						local ft_icon = ""
						if _G.MiniIcons and ft ~= "" then
							local ok, icon = pcall(MiniIcons.get, "filetype", ft)
							if ok then
								ft_icon = icon .. " "
							end
						end

						-- Mode (no background)
						local s_mode = h(mode_hl) .. " " .. mode .. " "

						-- Left sections (no bg)
						local s_folder = h("MiniStatuslineFolder") .. " " .. dir_icon .. cwd
						local s_diag = #diag_parts > 0 and ("  " .. table.concat(diag_parts, " ")) or ""

						-- Center: filetype icon + filename, with modified flag
						local fname = vim.fn.expand("%:t")
						local modified = vim.bo.modified and " [+]" or ""
						local readonly = (vim.bo.readonly or not vim.bo.modifiable) and " [-]" or ""
						local s_file = h("MiniStatuslineFilename")
							.. ft_icon
							.. (fname ~= "" and fname or "[No Name]")
							.. modified
							.. readonly

						-- Right sections (no bg)
						local s_gitstatus = #diff_parts > 0 and table.concat(diff_parts, " ") or ""
						local s_gitbranch = branch ~= "" and (h("MiniStatuslineGitBranch") .. "  " .. branch) or ""

						-- Location with TOP/BOT indicator and icon
						local line = vim.fn.line(".")
						local total_lines = vim.fn.line("$")
						local percentage = math.floor(100 * line / total_lines)
						local ruler
						if line == 1 then
							ruler = "TOP"
						elseif line == total_lines then
							ruler = "BOT"
						else
							ruler = string.format("%d%%%%", percentage)
						end
						local location_text = string.format("%d  %s", line, ruler)
						local location_icon = " "

						-- Location (no background)
						local s_loc = h("MiniStatuslineLocation") .. "  " .. location_icon .. location_text

						local function pad(s)
							return s ~= "" and ("  " .. s) or ""
						end

						return table.concat({
							s_mode,
							pad(s_folder),
							s_diag,
							"%=",
							s_file,
							"%=",
							pad(s_gitstatus),
							pad(s_gitbranch),
							"  ",
							s_loc,
						}, "")
					end,

					inactive = function()
						local fname = vim.fn.expand("%:t")
						return "%#MiniStatuslineInactive# " .. (fname ~= "" and fname or "[No Name]")
					end,
				},
				use_icons = true,
			})
			require("mini.tabline").setup({
				show_icons = true,
				section = "left",
			})
			-- require("mini.git").setup()
			require("mini.indentscope").setup({ symbol = "▎" })

			-- ── BufReadPre ──────────────────────────────────────────────────────────
			-- Modules that load when a buffer is read
			vim.api.nvim_create_autocmd("BufReadPre", {
				once = true,
				callback = function()
					-- Files
					require("mini.files").setup({ windows = { preview = true } })
					vim.api.nvim_create_autocmd("User", {
						pattern = "MiniFilesExplorerOpen",
						callback = function()
							MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
							MiniFiles.set_bookmark("p", vim.fn.stdpath("data") .. "/lazy", { desc = "Plugins" })
							MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
						end,
					})

					-- Misc
					require("mini.misc").setup()
					MiniMisc.setup_auto_root()
					MiniMisc.setup_restore_cursor()
					MiniMisc.setup_termbg_sync()
				end,
			})

			-- ── VeryLazy ────────────────────────────────────────────────────────────
			-- Modules that can wait until the editor is fully settled
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Extra (dependency for ai and hipatterns)
					require("mini.extra").setup()

					-- Extend and create a/i textobjects (`:h a(`, `:h a'`, etc.)
					-- Also provides "next" (`an`/`in`) and "last" (`al`/`il`) variants that
					-- explicitly search after or before cursor rather than guessing.
					--
					-- Example usage:
					-- - `ci)`  - change inside parenthesis
					-- - `di(`  - delete inside padded parenthesis
					-- - `yaq`  - yank around any quote ("", '', ``)
					-- - `vif`  - visually select inside function call
					-- - `cina` - change inside next argument
					-- - `daF`  - delete around function definition (treesitter)
					-- - `yiB`  - yank inside whole buffer
					-- - `valaala` - select around last argument, then again around next last
					--
					local ai = require("mini.ai")
					ai.setup({
						custom_textobjects = {
							-- `aB`/`iB` - whole buffer
							B = MiniExtra.gen_ai_spec.buffer(),
							-- treesitter-based textobjects (require nvim-treesitter-textobjects)
							-- `aF`/`iF` - function *definition* (not call — use `af`/`if` for calls)
							F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
							-- `aC`/`iC` - class / struct / impl
							C = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
							-- `aL`/`iL` - loop (for / while / etc.)
							L = ai.gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
							-- `aI`/`iI` - conditional (if / switch / ternary)
							I = ai.gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
							-- `ac`/`ic` - comment block
							c = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
							-- `ak`/`ik` - generic code block (do/begin/end etc.)
							k = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
							-- `ar`/`ir` - return statement
							r = ai.gen_spec.treesitter({ a = "@return.outer", i = "@return.inner" }),
							-- `aA`/`iA` - argument via treesitter (more accurate than mini.ai's built-in `a`)
							A = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
						},
						-- 'cover_or_next': try to cover first, then search forward.
						-- Use `an`/`in`/`al`/`il` to explicitly search next/last.
						n_lines = 500,
					})

					-- Generate clues for all mini.ai textobjects so they appear in mini.clue
					-- when typing an operator + `a`/`i` (e.g. `d` then `a` shows this menu).
					local function gen_ai_clues()
						local clues = {}
						local textobjs = {
							{ "(", "balanced ()" },
							{ ")", "balanced () padded" },
							{ "[", "balanced []" },
							{ "]", "balanced [] padded" },
							{ "{", "balanced {}" },
							{ "}", "balanced {} padded" },
							{ "<", "balanced <>" },
							{ ">", "balanced <> padded" },
							{ '"', "double quotes" },
							{ "'", "single quotes" },
							{ "`", "backtick quotes" },
							{ "b", "bracket (any of ()[]{})" },
							{ "q", "quote (any of \"'`)" },
							{ "t", "HTML/XML tag" },
							{ "a", "argument" },
							{ "f", "function call" },
							{ "B", "whole buffer" },
							-- treesitter-powered
							{ "F", "function definition (TS)" },
							{ "C", "class / struct (TS)" },
							{ "L", "loop (TS)" },
							{ "I", "conditional / if (TS)" },
							{ "c", "comment (TS)" },
							{ "k", "code block (TS)" },
							{ "r", "return statement (TS)" },
							{ "A", "argument precise (TS)" },
						}
						for _, to in ipairs(textobjs) do
							for _, mode in ipairs({ "o", "x" }) do
								table.insert(clues, { mode = mode, keys = "a" .. to[1], desc = "Around " .. to[2] })
								table.insert(clues, { mode = mode, keys = "i" .. to[1], desc = "Inside " .. to[2] })
								table.insert(
									clues,
									{ mode = mode, keys = "an" .. to[1], desc = "Around next " .. to[2] }
								)
								table.insert(
									clues,
									{ mode = mode, keys = "in" .. to[1], desc = "Inside next " .. to[2] }
								)
								table.insert(
									clues,
									{ mode = mode, keys = "al" .. to[1], desc = "Around last " .. to[2] }
								)
								table.insert(
									clues,
									{ mode = mode, keys = "il" .. to[1], desc = "Inside last " .. to[2] }
								)
							end
						end
						return clues
					end

					-- Align, Animate, Bracketed, Bufremove
					require("mini.align").setup()
					require("mini.animate").setup()
					require("mini.bracketed").setup()
					require("mini.bufremove").setup()

					-- Clue: show next-key hints in a bottom-right window.
					-- Press a trigger key and wait — a window lists available continuations.
					-- Press <BS> to go back one level in the sequence.
					local miniclue = require("mini.clue")
					miniclue.setup({
						window = {
							delay = 0,
							config = { width = 45 },
						},
						clues = {
							-- Leader group labels
							{
								{ mode = "n", keys = "<Leader>b", desc = "+Buffer" },
								{ mode = "n", keys = "<Leader>e", desc = "+Explore/Edit" },
								{ mode = "n", keys = "<Leader>f", desc = "+Find" },
								{ mode = "n", keys = "<Leader>g", desc = "+Git" },
								{ mode = "n", keys = "<Leader>l", desc = "+Language" },
								{ mode = "n", keys = "<Leader>m", desc = "+Map" },
								{ mode = "n", keys = "<Leader>o", desc = "+Other" },
								{ mode = "n", keys = "<Leader>s", desc = "+Session" },
								{ mode = "n", keys = "<Leader>t", desc = "+Terminal" },
								{ mode = "n", keys = "<Leader>v", desc = "+Visits" },
								{ mode = "x", keys = "<Leader>g", desc = "+Git" },
								{ mode = "x", keys = "<Leader>l", desc = "+Language" },
							},
							-- mini.ai textobjects: shown when typing an operator then `a`/`i`
							-- e.g. `d` → `a` opens this clue window listing all textobjects
							gen_ai_clues(),
							miniclue.gen_clues.builtin_completion(),
							miniclue.gen_clues.g(),
							miniclue.gen_clues.marks(),
							miniclue.gen_clues.registers(),
							miniclue.gen_clues.square_brackets(),
							-- Creates a resize submode: after `<C-w>+`, keep pressing `+`/`-`
							miniclue.gen_clues.windows({ submode_resize = true }),
							miniclue.gen_clues.z(),
						},
						triggers = {
							{ mode = { "n", "x" }, keys = "<Leader>" },
							{ mode = "n", keys = "\\" }, -- mini.basics toggles
							{ mode = { "n", "x" }, keys = "[" }, -- mini.bracketed
							{ mode = { "n", "x" }, keys = "]" },
							{ mode = "i", keys = "<C-x>" }, -- built-in completion
							{ mode = { "n", "x" }, keys = "g" },
							{ mode = { "n", "x" }, keys = "'" }, -- marks
							{ mode = { "n", "x" }, keys = "`" },
							{ mode = { "n", "x" }, keys = '"' }, -- registers
							{ mode = { "i", "c" }, keys = "<C-r>" },
							{ mode = "n", keys = "<C-w>" }, -- window commands
							{ mode = { "n", "x" }, keys = "s" }, -- mini.surround
							{ mode = { "n", "x" }, keys = "z" },
							-- mini.ai: show textobject menu after operator + a/i
							{ mode = { "o", "x" }, keys = "a" },
							{ mode = { "o", "x" }, keys = "i" },
						},
					})

					-- Comment, Diff
					require("mini.comment").setup()
					-- mini.diff disabled: using gitsigns instead
					-- require("mini.diff").setup()

					-- Hipatterns
					local hipatterns = require("mini.hipatterns")
					local hi_words = MiniExtra.gen_highlighter.words
					hipatterns.setup({
						highlighters = {
							fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
							hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
							todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
							note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
							hex_color = hipatterns.gen_highlighter.hex_color(),
						},
					})

					-- Jump utilities
					require("mini.jump").setup()
					require("mini.jump2d").setup()

					-- Pairs (dependency for Keymap)
					require("mini.pairs").setup({ modes = { command = true } })

					-- Keymap
					require("mini.keymap").setup()
					MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
					MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
					MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
					MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })

					-- Map
					local map = require("mini.map")
					map.setup({
						symbols = { encode = map.gen_encode_symbols.dot("4x2") },
						integrations = {
							map.gen_integration.builtin_search(),
							map.gen_integration.diff(),
							map.gen_integration.diagnostic(),
						},
					})
					for _, key in ipairs({ "n", "N", "*", "#" }) do
						vim.keymap.set(
							"n",
							key,
							key .. "zv<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
						)
					end

					-- Move, Operators
					require("mini.move").setup()
					require("mini.operators").setup()
					vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
					vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })

					-- Snippets, Splitjoin, Surround, Trailspace, Visits

					local latex_patterns = { "latex/**/*.json", "**/latex.json" }
					local snippets = require("mini.snippets")
					snippets.setup({
						snippets = {
							snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),
							snippets.gen_loader.from_lang({
								lang_patterns = {
									tex = latex_patterns,
									plaintex = latex_patterns,
									markdown_inline = { "markdown.json" },
								},
							}),
						},
					})

					require("mini.splitjoin").setup()
					require("mini.surround").setup()
					require("mini.trailspace").setup()
					require("mini.visits").setup()
				end,
			})
			-- ── Tabline highlights ────────────────────────────────────────────
			local function setup_tabline_hl()
				hi("MiniTablineBorder", { fg = "#363646", bg = "none" })
				hi("MiniTablineActive", { fg = "#4f4f68", bg = "#363646", bold = true })
				hi("MiniTablineInactive", { fg = "#737C73", bg = "#24273A" })
				hi("MiniTablineVisible", { fg = "#4f4f68", bg = "none" })
				hi("TabLineFill", { fg = "#4f4f68", bg = "none" })
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("MiniTablineHl", { clear = true }),
				callback = setup_tabline_hl,
			})
			setup_tabline_hl()
		end,
	},
}
