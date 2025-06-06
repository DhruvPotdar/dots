---@diagnostic disable: undefined-doc-name
local M = {}

M.on_very_lazy = function(fn)
    vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
            fn()
        end,
    })
end

M.pick = function(action, opts)
    opts = opts or {}
    return function()
        local cwd = opts.cwd or (opts.root and require('radtop').get_root()) or vim.fn.getcwd()
        require('fzf-lua')[action](vim.tbl_extend('force', opts, { cwd = cwd }))
    end
end

M.get_clients = function(opts)
    local ret = {} ---@type vim.lsp.Client[]
    if vim.lsp.get_clients then
        ret = vim.lsp.get_clients(opts)
    else
        ---@diagnostic disable-next-line: deprecated
        ret = vim.lsp.get_active_clients(opts)
        if opts and opts.method then
            ---@param client vim.lsp.Client
            ret = vim.tbl_filter(function(client)
                return client.supports_method(opts.method, { bufnr = opts.bufnr })
            end, ret)
        end
    end
    return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

function M.has(plugin)
    return M.get_plugin(plugin) ~= nil
end

M.filterout_lua_diagnosing = function(notif_arr)
    local not_diagnosing = function(notif)
        return not vim.startswith(notif.msg, 'lua_ls: Diagnosing')
    end
    notif_arr = vim.tbl_filter(not_diagnosing, notif_arr)
    return MiniNotify.default_sort(notif_arr)
end

M.is_loaded = function(name)
    local Config = require 'lazy.core.config'
    return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
function M.get_plugin(name)
    return require('lazy.core.config').spec.plugins[name]
end

---@param name string
M.opts = function(name)
    local plugin = M.get_plugin(name)
    if not plugin then
        return {}
    end
    local Plugin = require 'lazy.core.plugin'
    return Plugin.values(plugin, 'opts', false)
end

-- Utility from mini.statusline
M.isnt_normal_buffer = function()
    return vim.bo.buftype ~= ''
end

M.has_no_lsp_attached = function()
    return #vim.lsp.get_clients() == 0
end

M.get_filetype_icon = function()
    -- Have this `require()` here to not depend on plugin initialization order
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if not has_devicons then
        return ''
    end

    local file_name, file_ext = vim.fn.expand '%:t', vim.fn.expand '%:e'
    return devicons.get_icon(file_name, file_ext, { default = true })
end

M.section_location = function(args)
    -- Use virtual column number to allow update when past last column
    if MiniStatusline.is_truncated(args.trunc_width) then
        return '%-2l│%-2v'
    end

    return '󰉸 %-2l│󱥖 %-2v'
end

M.section_filetype = function(args)
    if MiniStatusline.is_truncated(args.trunc_width) then
        return ''
    end

    local filetype = vim.bo.filetype
    if (filetype == '') or M.isnt_normal_buffer() then
        return ''
    end

    local icon = M.get_filetype_icon()
    if icon ~= '' then
        filetype = string.format('%s %s', icon, filetype)
    end

    return filetype
end

--- Section for current search count
---
--- Show the current status of |searchcount()|. Empty output is returned if
--- window width is lower than `args.trunc_width`, search highlighting is not
--- on (see |v:hlsearch|), or if number of search result is 0.
---
--- `args.options` is forwarded to |searchcount()|. By default it recomputes
--- data on every call which can be computationally expensive (although still
--- usually on 0.1 ms order of magnitude). To prevent this, supply
--- `args.options = { recompute = false }`.
M.section_searchcount = function(args)
    if vim.v.hlsearch == 0 then
        return ''
    end
    -- `searchcount()` can return errors because it is evaluated very often in
    -- statusline. For example, when typing `/` followed by `\(`, it gives E54.
    local ok, s_count = pcall(vim.fn.searchcount, (args or {}).options or { recompute = true })
    if not ok or s_count.current == nil or s_count.total == 0 then
        return ''
    end

    local icon = MiniStatusline.is_truncated(args.trunc_width) and '' or ' '
    if s_count.incomplete == 1 then
        return icon .. '?/?│'
    end

    local too_many = ('>%d'):format(s_count.maxcount)
    local current = s_count.current > s_count.maxcount and too_many or s_count.current
    local total = s_count.total > s_count.maxcount and too_many or s_count.total
    return ('%s%s/%s│'):format(icon, current, total)
end

M.section_buffers = function(args)
    local buffers = vim.fn.execute 'ls'
    local count = 0
    for line in string.gmatch(buffers, '[^\r\n]+') do
        if string.match(line, '^%s*%d+') then
            count = count + 1
        end
    end
    if string.len(buffers) == 0 then
        return ''
    end
    local icon = MiniStatusline.is_truncated(args.trunc_width) and '' or ' '
    return ('%s(%s)│'):format(icon, count)
end

M.section_pathname = function(args)
    args = vim.tbl_extend('force', {
        modified_hl = nil,
        filename_hl = nil,
        trunc_width = 80,
    }, args or {})

    if vim.bo.buftype == 'terminal' then
        return '%t'
    end

    local path = vim.fn.expand '%:p'
    local cwd = vim.uv.cwd() or ''
    cwd = vim.uv.fs_realpath(cwd) or ''

    if path:find(cwd, 1, true) == 1 then
        path = path:sub(#cwd + 2)
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, sep)
    if require('mini.statusline').is_truncated(args.trunc_width) and #parts > 3 then
        parts = { parts[1], '…', parts[#parts - 1], parts[#parts] }
    end

    local dir = ''
    if #parts > 1 then
        dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep) .. sep
    end

    local file = parts[#parts]
    local file_hl = ''
    if vim.bo.modified and args.modified_hl then
        file_hl = '%#' .. args.modified_hl .. '#'
    elseif args.filename_hl then
        file_hl = '%#' .. args.filename_hl .. '#'
    end
    local modified = vim.bo.modified and ' [+]' or ''
    return dir .. file_hl .. file .. modified
end

M.get_root_dir_component = function(opts)
    opts = vim.tbl_extend('force', {
        cwd = false,
        subdirectory = true,
        parent = true,
        other = true,
        icon = '󱉭 ',
        color = nil, -- We'll handle color differently
    }, opts or {})

    return function()
        local current_file = vim.fn.expand '%:p:h' -- Get the directory of the current file
        local root_path = find_project_root(opts.cwd and vim.fn.getcwd() or current_file)

        if not root_path then
            return ''
        end

        local parts = {}

        if opts.parent then
            local parent = vim.fn.fnamemodify(root_path, ':h:t')
            if parent ~= '' and parent ~= '.' then
                table.insert(parts, parent)
            end
        end

        table.insert(parts, vim.fn.fnamemodify(root_path, ':t')) -- Always add the root directory name

        if opts.subdirectory and current_file ~= root_path then
            local relative_path = vim.fn.fnamemodify(current_file, ':' .. #root_path + 2 .. ':.') -- Get path relative to root
            local subdirectories = vim.split(relative_path, '/', true)
            if #subdirectories > 0 and subdirectories[1] ~= '' then
                table.insert(parts, subdirectories[1])
            end
        end

        -- Handle 'other' option (you might need to customize this based on LazyVim's behavior)
        if opts.other and #parts == 1 and current_file ~= root_path then
            local relative_path = vim.fn.fnamemodify(current_file, ':' .. #root_path + 2 .. ':.')
            if relative_path ~= '' then
                table.insert(parts, relative_path)
            end
        end

        local formatted_path = table.concat(parts, '/')
        local colored_path = opts.color and ('%' .. opts.color .. formatted_path .. '%#') or formatted_path

        return opts.icon .. colored_path
    end
end

-- optimized treesitter foldexpr for Neovim >= 0.10.0
M.foldexpr = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].ts_folds == nil then
        -- as long as we don't have a filetype, don't bother
        -- checking if treesitter is available (it won't)
        if vim.bo[buf].filetype == '' then
            return '0'
        end
        if vim.bo[buf].filetype:find 'dashboard' then
            vim.b[buf].ts_folds = false
        else
            vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
        end
    end
    return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or '0'
end

function M.formatexpr()
    conform, ok = pcall(require 'conform.nvim')
    if ok then
        return require('conform').formatexpr()
    end
    return vim.lsp.formatexpr { timeout_ms = 3000 }
end

-- complete buffer at once
function M.ai_buffer(ai_type)
    local start_line, end_line = 1, vim.fn.line '$'
    if ai_type == 'i' then
        -- Skip first and last blank lines for `i` textobject
        local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
        -- Do nothing for buffer with all blanks
        if first_nonblank == 0 or last_nonblank == 0 then
            return { from = { line = start_line, col = 1 } }
        end
        start_line, end_line = first_nonblank, last_nonblank
    end

    local to_col = math.max(vim.fn.getline(end_line):len(), 1)
    return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

return M
