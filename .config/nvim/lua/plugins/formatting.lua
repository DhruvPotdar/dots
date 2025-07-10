return {
    {
        'stevearc/conform.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        lazy = true,
        cmd = 'ConformInfo',
        event = { 'VeryLazy' },
        keys = {
            {
                '<leader>cF',
                function()
                    require('conform').format { formatters = { 'injected' }, timeout_ms = 3000 }
                end,
                mode = { 'n', 'v' },
                desc = 'Format Injected Langs',
            },
            {
                '<leader>cf',
                function()
                    require('conform').format()
                end,
                mode = { 'n', 'v' },
                desc = 'Format',
            },
        },
        opts = {
            -- The format_on_save function you provided is correct.
            format_on_save = {
                -- These options will be passed to conform.format()
                timeout_ms = 500,
                lsp_format = 'prefer',
            },
            -- Ensure these formatters are installed via Mason or manually.
            formatters_by_ft = {
                lua = { 'stylua' },
                fish = { 'fish_indent' },
                sh = { 'shfmt' },
                python = { 'black' },          -- Example: Multiple formatters
                cpp = { 'clang-format' },      -- Example: Multiple formatters
                -- Add other filetypes and their formatters here
                ['_'] = { 'trim_whitespace' }, -- Example: fallback for all files
            },

            -- Your formatters options are fine.
            formatters = {
                injected = { options = { ignore_errors = true } },
                shfmt = {
                    prepend_args = { '-i', '2', '-ci' }, -- Example: Custom args
                },
                ruff_format = {
                    args = { 'format', '--config=' .. vim.fn.expand '~/.config/nvim/ruff.toml', '-' },
                    stdin = true,
                },
            },
        },
        config = function(_, opts)
            require('conform').setup(opts)

            -- Optional: You can add an autocmd group specifically for conform
            -- although conform.nvim handles the BufWritePre internally when
            -- format_on_save is configured in setup. This is generally not needed.
            -- vim.api.nvim_create_autocmd("BufWritePre", {
            --   pattern = "*",
            --   group = vim.api.nvim_create_augroup("ConformFormatOnSave", { clear = true }),
            --   callback = function(args)
            --     require("conform").format({ bufnr = args.buf })
            --   end,
            -- })

            vim.api.nvim_create_user_command('Format', function(args)
                local range = nil
                if args.count ~= -1 then
                    range = {
                        start = { args.line1, 0 },
                        ['end'] = { args.line2, 999999 },
                    }
                end
                require('conform').format { async = true, lsp_fallback = true, range = range }
            end, { range = true })
        end,
    },
}
