return {
    {
        'benlubas/molten-nvim',
        enabled = false,
        version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
        dependencies = { '3rd/image.nvim' },
        build = ':UpdateRemotePlugins',
        init = function()
            -- these are examples, not defaults. Please see the readme
            vim.g.molten_image_provider = 'image.nvim'
            vim.g.molten_output_win_max_height = 20
        end,
    },
    {
        -- see the image.nvim readme for more information about configuring this plugin
        '3rd/image.nvim',
        opts = {
            backend = 'kitty',
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    only_render_image_at_cursor = false,
                    filetypes = { 'markdown', 'vimwiki' },
                },
                neorg = { enabled = true, clear_in_insert_mode = false, download_remote_images = true },
            },
            max_width = 100,
            max_height = 12,
            max_height_window_percentage = math.huge,
            max_width_window_percentage = math.huge,
            window_overlap_clear_enabled = true, -- highly recommended for kitty
            window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
        },
    },
}
