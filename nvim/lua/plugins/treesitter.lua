-- This file sets up nvim-treesitter, textobjects,  context-aware commenting, and additional keybindings with detailed comments.
return {
    {
        -- Core Treesitter plugin for syntax parsing and highlighting
        'nvim-treesitter/nvim-treesitter',
        -- event = { 'UIEnter', 'BufReadPre', 'BufNewFile' },
        -- Automatically run :TSUpdate after install
        build = ':TSUpdate',
        -- Expose update/install commands
        cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
        -- Keybindings for incremental selection
        keys = {
            { '<C-space>', desc = 'Treesitter Incremental Selection' },
            { '<BS>',      mode = 'x',                               desc = 'Treesitter Decremental Selection' },
        },
        -- Early initialization to include custom queries
        init = function(plugin)
            -- Ensure plugin path is in runtime for query_predicates
            require('lazy.core.loader').add_to_rtp(plugin)
            require 'nvim-treesitter.query_predicates'
        end,
        -- Main plugin configuration
        config = function()
            require('nvim-treesitter.configs').setup {
                -- Enable syntax highlighting
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                -- Enable indentation based on treesitter
                indent = { enable = true },
                -- Automatically install parsers for listed languages
                ensure_installed = {
                    'bash',
                    'c',
                    'cpp',
                    'diff',
                    'html',
                    'javascript',
                    'jsdoc',
                    'json',
                    'jsonc',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'python',
                    'regex',
                    'toml',
                    'tsx',
                    'typescript',
                    'vim',
                    'vimdoc',
                    'yaml',
                    'go',
                    'rust',
                    'java',
                },
                -- Incremental selection configuration
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<C-space>', -- Start selection
                        node_incremental = '<C-space>', -- Increment to next node
                        scope_incremental = false, -- Increment to scope (function, class)
                        node_decremental = '<BS>', -- Decrement selection
                    },
                },
                -- Textobjects extension configuration
                textobjects = {
                    -- Movement between text objects
                    move = {
                        enable = true,
                        set_jumps = true, -- Add entries to jumplist
                        goto_next_start = {
                            [']f'] = '@function.outer',
                            [']c'] = '@class.outer',
                            [']p'] = '@parameter.inner',
                            [']i'] = '@conditional.outer',
                            [']l'] = '@loop.outer',
                        },
                        goto_next_end = {
                            [']F'] = '@function.outer',
                            [']C'] = '@class.outer',
                            [']P'] = '@parameter.inner',
                            [']I'] = '@conditional.outer',
                            [']L'] = '@loop.outer',
                        },
                        goto_previous_start = {
                            ['[f'] = '@function.outer',
                            ['[c'] = '@class.outer',
                            ['[p'] = '@parameter.inner',
                            ['[i'] = '@conditional.outer',
                            ['[l'] = '@loop.outer',
                        },
                        goto_previous_end = {
                            ['[F'] = '@function.outer',
                            ['[C'] = '@class.outer',
                            ['[P'] = '@parameter.inner',
                            ['[I'] = '@conditional.outer',
                            ['[L'] = '@loop.outer',
                        },
                    },
                    -- Selection of text objects (visual mode)
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner',
                            ['ap'] = '@parameter.outer',
                            ['ip'] = '@parameter.inner',
                            ['al'] = '@loop.outer',
                            ['il'] = '@loop.inner',
                            ['ai'] = '@conditional.outer',
                            ['ii'] = '@conditional.inner',
                            ['as'] = '@statement.outer',
                            ['is'] = '@statement.inner',
                        },
                    },
                    -- Swap parameters
                    swap = {
                        enable = true,
                        swap_next = {
                            ['<leader>a'] = '@parameter.inner',
                        },
                        swap_previous = {
                            ['<leader>A'] = '@parameter.inner',
                        },
                    },
                    -- LSP interop: peek definitions
                    lsp_interop = {
                        enable = true,
                        border = 'rounded',
                        peek_definition_code = {
                            ['<leader>df'] = '@function.outer',
                            ['<leader>dF'] = '@class.outer',
                        },
                    },
                },
                -- Context-aware commentstring for treesitter-based commenting
                ts_context_commentstring = {
                    enable = true,
                    enable_autocmd = true,
                },
                -- Playground for inspecting AST
                playground = {
                    enable = true,
                    persist_queries = false,
                },
            }
        end,
        dependencies = {
            -- Supplementary textobjects library
            'nvim-treesitter/nvim-treesitter-textobjects',
            -- Auto-close and auto-rename HTML tags
            { 'windwp/nvim-ts-autotag',                      event = 'BufReadPost',     opts = {} },
            -- Context-aware commentstring for commenting plugins
            { 'JoosepAlviste/nvim-ts-context-commentstring', event = 'BufReadPost' },
            -- Treesitter playground to visualize syntax trees
            { 'nvim-treesitter/playground',                  cmd = 'TSPlaygroundToggle' },
        },
    },
    {
        'folke/ts-comments.nvim',
        opts = {},
        event = 'VeryLazy',
        enabled = vim.fn.has 'nvim-0.10.0' == 1,
    },
}
