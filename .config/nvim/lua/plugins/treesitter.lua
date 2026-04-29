-- nvim-treesitter main-branch API (incompatible with old master).
-- LspInfo
-- Highlight/indent/folds are neovim built-ins; this plugin only manages
-- parser installation and provides query files.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- plugin explicitly does not support lazy-loading
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			-- "nvim-treesitter/nvim-treesitter-context",
		},
		config = function()
			-- ── Parser installation ──────────────────────────────────────────────
			-- No-op for already-installed parsers; runs async.
			require("nvim-treesitter").install({
				"bash",
				"c",
				"cpp",
				"css",
				"diff",
				"dockerfile",
				"fish",
				"go",
				"gomod",
				"gosum",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"make",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"rust",
				"scss",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			})

			-- ── Per-filetype features ────────────────────────────────────────────
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf

					-- Highlight (built into neovim, queries from this plugin)
					pcall(vim.treesitter.start, buf)

					-- Indent (experimental — skip for filetypes that already have good indent)
					local no_ts_indent = { python = true }
					if not no_ts_indent[args.match] then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end

					-- Folds — use treesitter expr; start fully open
					local wo = vim.wo[0][0]
					wo.foldmethod = "expr"
					wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					wo.foldlevel = 99
				end,
			})

			-- ── Incremental node selection ───────────────────────────────────────
			-- <C-space> in normal: start visual selection at current node.
			-- <C-space> in visual: expand selection to parent node.
			-- <bs>      in visual: shrink back to previous selection.
			do
				local sel_stack = {} -- { {sr,sc,er,ec} } per buffer

				local function node_to_range(node)
					local sr, sc, er, ec = node:range()
					-- treesitter end col is exclusive; convert for vim cursor (0-indexed col)
					if ec == 0 then
						er = er - 1
						ec = #vim.api.nvim_buf_get_lines(0, er, er + 1, true)[1]
					else
						ec = ec - 1
					end
					return sr, sc, er, ec
				end

				local function apply_range(sr, sc, er, ec)
					vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
					vim.cmd("normal! v")
					vim.api.nvim_win_set_cursor(0, { er + 1, ec })
				end

				local function expand()
					local mode = vim.fn.mode()
					if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
						-- Normal mode: init at the smallest node under cursor
						sel_stack = {}
						local node = vim.treesitter.get_node()
						if not node then
							return
						end
						local sr, sc, er, ec = node_to_range(node)
						table.insert(sel_stack, { sr, sc, er, ec })
						apply_range(sr, sc, er, ec)
					else
						-- Visual mode: find node that fully contains selection, go to parent
						local vpos = vim.fn.getpos("v")
						local cpos = vim.fn.getpos(".")
						local v_row, v_col = vpos[2] - 1, vpos[3] - 1
						local c_row, c_col = cpos[2] - 1, cpos[3] - 1
						-- ensure start <= end
						local sr0, sc0, er0, ec0
						if v_row < c_row or (v_row == c_row and v_col <= c_col) then
							sr0, sc0, er0, ec0 = v_row, v_col, c_row, c_col
						else
							sr0, sc0, er0, ec0 = c_row, c_col, v_row, v_col
						end

						local node = vim.treesitter.get_node({ pos = { sr0, sc0 } })
						-- walk up until node covers full selection
						while node do
							local nsr, nsc, ner, nec = node:range()
							nec = nec == 0 and #vim.api.nvim_buf_get_lines(0, ner - 1, ner, true)[1] or (nec - 1)
							if
								(nsr < sr0 or (nsr == sr0 and nsc <= sc0))
								and (ner > er0 or (ner == er0 and nec >= ec0))
							then
								local p = node:parent()
								if p then
									node = p
								else
									break
								end
								break
							end
							node = node:parent()
						end
						if not node then
							return
						end
						local sr, sc, er, ec = node_to_range(node)
						table.insert(sel_stack, { sr, sc, er, ec })
						apply_range(sr, sc, er, ec)
					end
				end

				local function shrink()
					if #sel_stack > 1 then
						table.remove(sel_stack)
						local prev = sel_stack[#sel_stack]
						apply_range(prev[1], prev[2], prev[3], prev[4])
					else
						sel_stack = {}
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
					end
				end

				vim.keymap.set({ "n", "x" }, "<C-space>", expand, { desc = "Expand TS selection" })
				vim.keymap.set("x", "<bs>", shrink, { desc = "Shrink TS selection" })
			end

			-- ── Textobject move keymaps ──────────────────────────────────────────
			require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })

			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			local function mv(keys, fn, query, desc)
				vim.keymap.set({ "n", "x", "o" }, keys, function()
					fn(query)
				end, { desc = desc })
			end

			-- functions
			mv("]m", move.goto_next_start, "@function.outer", "Next function start")
			mv("]M", move.goto_next_end, "@function.outer", "Next function end")
			mv("[m", move.goto_previous_start, "@function.outer", "Prev function start")
			mv("[M", move.goto_previous_end, "@function.outer", "Prev function end")
			-- classes
			mv("]C", move.goto_next_start, "@class.outer", "Next class start")
			mv("]K", move.goto_next_end, "@class.outer", "Next class end")
			mv("[C", move.goto_previous_start, "@class.outer", "Prev class start")
			mv("[K", move.goto_previous_end, "@class.outer", "Prev class end")
			-- conditionals / loops / returns / parameters
			mv("]i", move.goto_next_start, "@conditional.outer", "Next conditional")
			mv("[i", move.goto_previous_start, "@conditional.outer", "Prev conditional")
			mv("]l", move.goto_next_start, "@loop.outer", "Next loop")
			mv("[l", move.goto_previous_start, "@loop.outer", "Prev loop")
			mv("]r", move.goto_next_start, "@return.outer", "Next return")
			mv("[r", move.goto_previous_start, "@return.outer", "Prev return")
			mv("]a", move.goto_next_start, "@parameter.inner", "Next parameter")
			mv("[a", move.goto_previous_start, "@parameter.inner", "Prev parameter")

			-- swap arguments
			vim.keymap.set("n", "<leader>ca", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap next argument" })
			vim.keymap.set("n", "<leader>cA", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap prev argument" })
		end,
	},
}
