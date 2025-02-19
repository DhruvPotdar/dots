-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("lspconfig.ui.windows").default_options.border = "rounded"
--
-- -- (method 1, For heavy lazyloaders)
-- dofile(vim.g.base46_cache .. "defaults")
-- dofile(vim.g.base46_cache .. "statusline")
