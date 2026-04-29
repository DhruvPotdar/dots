-- Make Mason-installed binaries available to vim.lsp.start (not in shell PATH by default)
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Options organized by usage for readability and maintenance
-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

local opt = vim.opt
-- ======= Clipboard =======
-- Only enable system clipboard when not in SSH to preserve OSC52 behavior.
-- Requires Neovim >= 0.10.0 for reliable OSC52.
vim.schedule(function()
	opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
end)

-- ======= Files / Persistence =======
opt.autowrite = true -- Automatically save changes when switching buffers
opt.undofile = true -- Enable persistent undo
opt.undolevels = 10000
opt.hidden = true -- Allow switching away from modified buffers without saving
opt.swapfile = false -- Don't create swap files
opt.hidden = true -- Remove unnamed buffer
opt.backup = false -- Disable backup files
opt.writebackup = false -- Disable write backup
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- ======= UI / Display =======
opt.termguicolors = true -- True color support
opt.laststatus = 3 -- Global statusline across windows
opt.showmode = false -- Mode shown in statusline, no need for builtin
opt.signcolumn = "yes" -- Enable signcolumn for gitsigns
opt.number = true
opt.relativenumber = true
opt.cursorline = true -- Highlight the current line
opt.cmdheight = 0
-- opt.cursorcolumn = true -- Uncomment if column highlight is desired
opt.ruler = false -- Disable classic ruler; statusline handles this
opt.linebreak = true -- Wrap at convenient points (no mid-word wraps)
opt.wrap = true -- Enable wrapping for long lines
opt.list = false -- Show some invisible characters (tabs, trailing spaces)
opt.pumheight = 10 -- Completion popup max entries
opt.pumblend = 0 -- Popup blend (transparency)
opt.winminwidth = 5 -- Minimal window width
opt.winborder = "rounded" -- Window border style for floating windows
opt.conceallevel = 2 -- Conceal formatting markers (markdown, etc.)
vim.o.breakindentopt = "list:-1" -- Add padding for lists (if 'wrap' is set)

-- opt.formatoptions = 'jcroqlnt' -- tcqj
-- Fill characters (visual polish)
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

-- Cursor shape and blinking in different modes
opt.guicursor =
	"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
-- ======= Editing / Indentation =======
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 4 -- Indent size for >, < commands
opt.tabstop = 4 -- Number of spaces a <Tab> in file counts for
opt.shiftround = true -- Round indentation to shiftwidth
opt.smartindent = true -- Smart autoindenting for new lines
opt.smartcase = true -- Smart case for searches (combined with ignorecase)
opt.spelllang = { "en" }

-- ======= Folding (Treesitter-based) =======
-- Use expression-based folding driven by treesitter; start unfolded
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- ======= Searching =======
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Case-insensitive by default
opt.smartcase = true -- ...but respect uppercase in query
opt.inccommand = "split" -- Live preview for substitutions
opt.jumpoptions = "view"
opt.wildmenu = false -- disabled in favour of blink.cmp cmdline completion
opt.completeopt = "menu,menuone,noselect" -- Comfortable completion UI

-- ======= Window management / Splits =======
opt.splitright = true -- New window to the right
opt.splitbelow = false -- Keep new windows above by default (false)
opt.splitkeep = "screen"
opt.sidescrolloff = 8 -- Horizontal context columns
opt.scrolloff = 15 -- Vertical context lines

-- ======= Mouse / Input =======
opt.mouse = "a" -- Enable mouse support in all modes
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Short timeout for mapped sequences

-- ======= Performance / UX tweaks =======
opt.updatetime = 300 -- Faster CursorHold and swap writing
opt.virtualedit = "block" -- Allow visual block cursor beyond EOL in block mode

-- ======= Misc / Language specific tweaks =======
-- Fix markdown indentation settings recommended by some plugins
vim.g.markdown_recommended_style = 0

-- Optional/placeholder settings (commented out for clarity)
-- opt.formatexpr = "v:lua.require'radtop.utils'.formatexpr()"
-- opt.formatoptions = 'jcroqlnt' -- tcqj
-- opt.smoothscroll = true

-- Diagnostic config lives in lua/radtop/lsp.lua (consolidated there)
