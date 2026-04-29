-- =============================================================================
-- jupyter.lua — Full VSCode-parity notebook setup
-- Stack: jupytext.nvim → molten-nvim → quarto-nvim → otter.nvim → image.nvim
-- =============================================================================
--
-- PREREQUISITES (install in the .venv at ~/.config/nvim/.venv):
--   pip install pynvim jupyter_client ipykernel nbformat cairosvg
--   pip install ipython                        -- better REPL experience
--   pip install requests websocket-client      -- for :MoltenInit <server url>
--   luarocks --lua-version=5.1 install magick  -- for image.nvim
--   sudo apt install imagemagick               -- system dep for magick
--
-- PER-PROJECT kernel (run once per venv you want to use):
--   pip install ipykernel
--   python -m ipykernel install --user --name myenv --display-name "My Env"
--   jupyter kernelspec list                    -- verify it shows up
--
-- :checkhealth molten   -- always run this first when something breaks
-- =============================================================================

return {

  -- ── 1. jupytext.nvim ────────────────────────────────────────────────────────
  -- Transparently converts .ipynb ↔ markdown on open/save.
  -- You edit a nice .md; Jupytext keeps the real .ipynb in sync.
  {
    'GCBallesteros/jupytext.nvim',
    lazy = false, -- must load early so BufReadCmd fires before other plugins
    opts = {
      style = 'markdown', -- convert notebooks to markdown format
      output_extension = 'md', -- the temp buffer will look like a .md file
      force_ft = 'markdown', -- force markdown filetype on the scratch buffer
    },
  },

  -- ── 2. image.nvim ───────────────────────────────────────────────────────────
  -- Renders images inline inside Neovim using the Kitty graphics protocol.
  -- Pin to 1.1.0 — image.nvim breaks often; don't float on HEAD.
  {
    '3rd/image.nvim',
    version = '1.1.0',
    build = false, -- don't build the luarocks rock; use the system magick
    opts = {
      backend = 'kitty', -- best quality; requires Kitty terminal
      processor = 'magick_cli', -- uses `magick` CLI instead of the Lua rock
      integrations = {}, -- disable built-in markdown/neorg integrations;
      -- molten manages image display itself
      max_width = 100, -- cols — tweak to taste
      max_height = 12, -- rows — tweak to taste
      -- CRITICAL: must be math.huge (not just 100%).
      -- A percentage cap causes images to be resized instead of cropped when
      -- the molten output window is partially off-screen.
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      -- Clear images when a completion menu or docs float appears over them
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },

  -- ── 3. otter.nvim ───────────────────────────────────────────────────────────
  -- Creates hidden "otter" buffers for each language in a markdown/quarto file.
  -- LSP servers attach to those buffers, giving you real completions/diags.
  {
    'jmbuhr/otter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      lsp = {
        hover = {
          border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
        },
        diagnostic_update_events = { 'BufWritePost' },
      },
      buffers = {
        set_filetype = true, -- set filetype on otter buffers for TS + LSP
        write_to_disk = false, -- don't clutter disk with .otter.* files
      },
    },
  },

  -- ── 4. quarto-nvim ──────────────────────────────────────────────────────────
  -- Orchestrates otter.nvim for LSP + molten for execution.
  -- Gives you run_cell / run_above / run_all helpers used in keymaps below.
  {
    'quarto-dev/quarto-nvim',
    dependencies = {
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    ft = { 'quarto', 'markdown' },
    opts = {
      lspFeatures = {
        languages = { 'python', 'r', 'julia', 'bash', 'lua' },
        chunks = 'all', -- 'all' includes inline code, not just fenced blocks
        diagnostics = {
          enabled = true,
          triggers = { 'BufWritePost' },
        },
        completion = {
          enabled = true,
        },
      },
      keymap = {
        -- These are quarto's own hover/goto keys (separate from molten run keys).
        -- They proxy LSP calls through otter to the correct language server.
        hover = 'K',
        definition = 'gd',
        rename = '<leader>rn',
        references = 'gr',
        format = '<leader>gf',
      },
      codeRunner = {
        enabled = true,
        default_method = 'molten', -- use molten as the execution backend
      },
    },
  },

  -- ── 5. molten-nvim ──────────────────────────────────────────────────────────
  {
    'benlubas/molten-nvim',
    -- Don't pin to ^1.0.0 unless you want to avoid breaking changes.
    -- Remove 'version' to track latest, or add it back for stability.
    build = ':UpdateRemotePlugins', -- required — registers the remote plugin
    lazy = false,
    dependencies = { '3rd/image.nvim' },

    init = function()
      -- ── Output window behaviour ────────────────────────────────────────────
      vim.g.molten_auto_open_output = false -- don't auto-pop the float;
      -- use <localleader>os to open
      vim.g.molten_output_win_max_height = 20 -- float height cap (rows)
      vim.g.molten_output_win_max_width = 999 -- effectively unlimited width
      vim.g.molten_output_crop_border = true -- crop bottom border at screen edge
      vim.g.molten_output_win_border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }
      vim.g.molten_output_win_hide_on_leave = true -- hide float on cursor leave

      -- "open_then_enter" → first press opens float, second enters it.
      -- "open_and_enter"  → immediately enters the float (useful for scrolling).
      vim.g.molten_enter_output_behavior = 'open_then_enter'

      -- ── Virtual text output ────────────────────────────────────────────────
      -- Renders output as virtual text *below* the cell. Stays visible even
      -- when cursor moves away. Works with images. Can be buggy with very
      -- tall image outputs — toggle off if that bothers you.
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true -- place virt text below the ``` line

      -- ── Image rendering ────────────────────────────────────────────────────
      vim.g.molten_image_provider = 'image.nvim' -- use image.nvim (not wezterm)
      vim.g.molten_auto_image_popup = false -- don't call Image.show() automatically

      -- ── Execution / kernel behaviour ──────────────────────────────────────
      vim.g.molten_tick_rate = 200 -- ms between kernel polls (lower = snappier)
      vim.g.molten_wrap_output = true -- word-wrap output text
      vim.g.molten_limit_output_chars = 10000 -- prevent huge outputs from lagging nvim

      -- "init": silently initialise when a kernel name can be inferred.
      -- "raise": throw an error (useful for scripting/other plugins).
      vim.g.molten_auto_init_behavior = 'init'

      -- ── Cell highlight ─────────────────────────────────────────────────────
      -- MoltenCell is applied to lines that belong to the active cell.
      -- Linked to CursorLine by default; override here if you want something different.
      -- vim.api.nvim_set_hl(0, 'MoltenCell', { bg = '#1e2030' })

      -- ── Use border highlights to visually distinguish pass/fail ────────────
      vim.g.molten_use_border_highlights = true
      -- You can link to your colour scheme:
      -- vim.api.nvim_set_hl(0, 'MoltenOutputBorderSuccess', { link = 'DiagnosticOk' })
      -- vim.api.nvim_set_hl(0, 'MoltenOutputBorderFail',    { link = 'DiagnosticError' })

      -- ── Save / load ────────────────────────────────────────────────────────
      vim.g.molten_save_path = vim.fn.stdpath 'data' .. '/molten_saves'

      -- ── HTML outputs ───────────────────────────────────────────────────────
      vim.g.molten_auto_open_html_in_browser = false -- open with <localleader>mx

      -- ══════════════════════════════════════════════════════════════════════
      -- KEYMAPS — set in init so they're available immediately (before config)
      -- ══════════════════════════════════════════════════════════════════════
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end

      -- ── Kernel lifecycle ──────────────────────────────────────────────────
      map('n', '<localleader>mi', ':MoltenInit<CR>', 'Kernel: init (prompt)')
      map('n', '<localleader>ms', ':MoltenInit shared<CR>', 'Kernel: attach to running kernel')
      map('n', '<localleader>mq', ':MoltenDeinit<CR>', 'Kernel: deinit (kill)')
      map('n', '<localleader>mQ', ':MoltenRestart!<CR>', 'Kernel: restart + clear outputs')
      map('n', '<localleader>mk', ':MoltenInterrupt<CR>', 'Kernel: interrupt (stop cell)')
      map('n', '<localleader>m?', ':MoltenInfo<CR>', 'Kernel: show info')

      -- ── Evaluation ────────────────────────────────────────────────────────
      -- MoltenEvaluateOperator: acts like a Vim operator — use with motion.
      --   e.g. <localleader>eip → evaluate inner paragraph
      map('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', 'Eval: operator (+ motion)')
      map('n', '<localleader>el', ':MoltenEvaluateLine<CR>', 'Eval: current line')
      map('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', 'Eval: re-run cell')
      map('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', 'Eval: visual selection')

      -- ── Output window ────────────────────────────────────────────────────
      -- noautocmd is REQUIRED for MoltenEnterOutput — without it the cursor
      -- jumps back when the window re-renders.
      map('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', 'Output: open / enter')
      map('n', '<localleader>oh', ':MoltenHideOutput<CR>', 'Output: hide float')
      map('n', '<localleader>ot', ':MoltenShowOutput<CR>', 'Output: show float')
      map('n', '<localleader>oy', ':MoltenYankOutput<CR>', 'Output: yank to register')
      map('n', '<localleader>oY', ':MoltenYankOutput!<CR>', 'Output: yank to clipboard')
      map('n', '<localleader>mx', ':MoltenOpenInBrowser<CR>', 'Output: open HTML in browser')
      map('n', '<localleader>op', ':MoltenImagePopup<CR>', 'Output: open image externally')

      -- ── Cell management ───────────────────────────────────────────────────
      map('n', '<localleader>md', ':MoltenDelete<CR>', 'Cell: delete molten cell')

      -- ── Persistence ───────────────────────────────────────────────────────
      map('n', '<localleader>mw', ':MoltenSave<CR>', 'Notebook: save outputs to JSON')
      map('n', '<localleader>mr', ':MoltenLoad<CR>', 'Notebook: load outputs from JSON')
      map('n', '<localleader>me', ':MoltenExportOutput!<CR>', 'Notebook: export to .ipynb')
      map('n', '<localleader>mi2', ':MoltenImportOutput<CR>', 'Notebook: import outputs from .ipynb')
    end,

    config = function()
      -- ── Treesitter: ensure markdown highlighting is active ─────────────────
      -- jupytext opens .ipynb as markdown; make sure TS is attached.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function(e)
          if e.file:match '%.ipynb$' or e.file:match '%.md$' then
            vim.schedule(function()
              if not vim.treesitter.highlighter.active[e.buf] then
                pcall(vim.treesitter.start, e.buf, 'markdown')
              end
            end)
          end
        end,
      })

      -- ── Auto-import outputs when opening .ipynb ────────────────────────────
      -- Attempts to match the kernel from notebook metadata, falling back to
      -- the active venv name.
      local function init_molten_buffer(e)
        vim.schedule(function()
          if vim.fn.exists '*MoltenAvailableKernels' == 0 then
            return
          end
          local kernels = vim.fn.MoltenAvailableKernels()

          -- try to read kernel name from notebook metadata
          local ok, kernel_name = pcall(function()
            local f = io.open(e.file, 'r')
            if not f then
              return nil
            end
            local data = vim.json.decode(f:read 'a')
            f:close()
            return data['metadata']['kernelspec']['name']
          end)

          -- fall back to active venv name
          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
            if venv then
              kernel_name = venv:match '/.+/(.+)'
            end
          end

          if kernel_name and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(('MoltenInit %s'):format(kernel_name))
          end
          -- import saved outputs (no-op if no export exists)
          pcall(vim.cmd, 'MoltenImportOutput')
        end)
      end

      -- BufAdd fires for files passed on the command line before BufEnter
      vim.api.nvim_create_autocmd('BufAdd', {
        pattern = { '*.ipynb' },
        callback = init_molten_buffer,
      })

      -- BufEnter fires for files opened via :e / netrw after vim has started
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = { '*.ipynb' },
        callback = function(e)
          if vim.api.nvim_get_vvar 'vim_did_enter' ~= 1 then
            init_molten_buffer(e)
          end
        end,
      })

      -- Auto-export outputs back to .ipynb on every write
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { '*.ipynb' },
        callback = function()
          local ok, status = pcall(require, 'molten.status')
          if ok and status.initialized() == 'Molten' then
            pcall(vim.cmd, 'MoltenExportOutput!')
          end
        end,
      })

      -- ── Per-filetype molten option tweaks ─────────────────────────────────
      -- In plain .py files disable virt_lines_off_by_1 (no ``` cell delimiters).
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*.py',
        callback = function(e)
          if e.file:match '%.otter%.' then
            return
          end
          local ok, status = pcall(require, 'molten.status')
          if ok and status.initialized() == 'Molten' then
            vim.fn.MoltenUpdateOption('virt_lines_off_by_1', false)
            vim.fn.MoltenUpdateOption('virt_text_output', false)
          else
            vim.g.molten_virt_lines_off_by_1 = false
            vim.g.molten_virt_text_output = false
          end
        end,
      })

      -- Re-enable virt_lines_off_by_1 when back in a notebook / quarto file
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = { '*.qmd', '*.md', '*.ipynb' },
        callback = function(e)
          if e.file:match '%.otter%.' then
            return
          end
          local ok, status = pcall(require, 'molten.status')
          if ok and status.initialized() == 'Molten' then
            vim.fn.MoltenUpdateOption('virt_lines_off_by_1', true)
            vim.fn.MoltenUpdateOption('virt_text_output', true)
          else
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_virt_text_output = true
          end
        end,
      })

      -- ── quarto.runner keymaps ─────────────────────────────────────────────
      -- These use quarto's higher-level runners which understand cell boundaries
      -- in both .qmd and jupytext-converted .ipynb files.
      local runner = require 'quarto.runner'
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end

      map('n', '<localleader>rc', runner.run_cell, 'Run: cell')
      map('n', '<localleader>ra', runner.run_above, 'Run: cell + all above')
      map('n', '<localleader>rb', runner.run_below, 'Run: cell + all below') -- if available
      map('n', '<localleader>rA', runner.run_all, 'Run: all cells')
      map('n', '<localleader>rl', runner.run_line, 'Run: current line')
      map('v', '<localleader>r', runner.run_range, 'Run: visual range')
      map('n', '<localleader>RA', function()
        runner.run_all(true) -- true = all languages, not just the active one
      end, 'Run: all cells (all languages)')

      -- ── NewNotebook helper command ─────────────────────────────────────────
      -- :NewNotebook myanalysis → creates myanalysis.ipynb with boilerplate
      local default_notebook = [[{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": ["# New Notebook\n"]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {},
      "outputs": [],
      "source": []
    }
  ],
  "metadata": {
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "name": "python",
      "version": "3.11.0"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}]]

      vim.api.nvim_create_user_command('NewNotebook', function(opts)
        local path = opts.args .. '.ipynb'
        local file = io.open(path, 'w')
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd('edit ' .. path)
        else
          vim.notify('NewNotebook: could not write ' .. path, vim.log.levels.ERROR)
        end
      end, { nargs = 1, complete = 'file', desc = 'Create a new blank .ipynb file' })
    end,
  },

  -- ── 6. hydra.nvim — modal cell navigation ──────────────────────────────────
  -- Activate with <localleader>j, then use j/k/r/l/R without the prefix.
  -- Press <esc> or q to exit. Perfect for stepping through cells quickly.
  {
    'nvimtools/hydra.nvim',
    config = function()
      local function keys(str)
        return function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(str, true, false, true), 'm', true)
        end
      end

      local Hydra = require 'hydra'

      -- ── Cell navigation hydra ──────────────────────────────────────────────
      Hydra {
        name = 'Notebook',
        hint = [[
  Navigate & Run
  _j_ / _k_  : next / prev cell     _r_ : run cell
  _a_        : run + all above       _A_ : run all
  _l_        : run line              _s_ : stop kernel
  _o_        : open output           _h_ : hide output
  ^^                     _<esc>_ / _q_ : exit
        ]],
        config = {
          color = 'pink', -- pink: exit on unbound keys
          invoke_on_body = true,
          hint = {
            float_opts = { border = 'rounded' },
          },
        },
        mode = 'n',
        body = '<localleader>j', -- trigger key
        heads = {
          { 'j', keys ']c', { desc = 'next cell' } },
          { 'k', keys '[c', { desc = 'prev cell' } },
          { 'r', ':QuartoSend<CR>', { desc = 'run cell' } },
          { 'l', ':QuartoSendLine<CR>', { desc = 'run line' } },
          { 'a', ':QuartoSendAbove<CR>', { desc = 'run above' } },
          { 'A', ':QuartoSendAll<CR>', { desc = 'run all' } },
          { 's', ':MoltenInterrupt<CR>', { desc = 'stop kernel' } },
          { 'o', ':noautocmd MoltenEnterOutput<CR>', { desc = 'enter output' } },
          { 'h', ':MoltenHideOutput<CR>', { desc = 'hide output' } },
          { '<esc>', nil, { exit = true, nowait = true } },
          { 'q', nil, { exit = true, nowait = true } },
        },
      }
    end,
  },
}

-- =============================================================================
-- QUICK REFERENCE — all <localleader> bindings
-- (default localleader is \, set with vim.g.maplocalleader)
-- =============================================================================
--
-- KERNEL
--   \mi   MoltenInit (prompt for kernel)
--   \ms   MoltenInit shared (attach to running kernel)
--   \mq   MoltenDeinit  (kill kernel for this buffer)
--   \mQ   MoltenRestart! (restart + wipe outputs)
--   \mk   MoltenInterrupt (stop running cell — like Ctrl-C)
--   \m?   MoltenInfo
--
-- EVALUATE
--   \e    MoltenEvaluateOperator  (then motion, e.g. \eip = inner paragraph)
--   \el   MoltenEvaluateLine
--   \rr   MoltenReevaluateCell
--   \r    (visual) MoltenEvaluateVisual
--
-- QUARTO RUNNERS (cell-aware, recommended over raw Molten eval)
--   \rc   run current cell
--   \ra   run cell + all above
--   \rb   run cell + all below
--   \rA   run all cells
--   \rl   run current line
--   \r    (visual) run visual range
--   \RA   run all cells (all languages)
--
-- OUTPUT
--   \os   open/enter output float  (noautocmd required!)
--   \oh   hide output float
--   \ot   show output float
--   \oy   yank output to " register
--   \oY   yank output to system clipboard
--   \mx   open HTML output in browser
--   \op   open image output externally (Image.show())
--
-- CELLS
--   \md   delete current molten cell
--
-- PERSISTENCE
--   \mw   save outputs to JSON  (:MoltenSave)
--   \mr   load outputs from JSON (:MoltenLoad)
--   \me   export outputs to .ipynb
--   \mi2  import outputs from .ipynb
--
-- NAVIGATION HYDRA  (enter with \j, exit with q/<esc>)
--   j/k   next/prev cell
--   r     run cell    l  run line
--   a     run above   A  run all
--   s     stop kernel
--   o     enter output  h  hide output
--
-- LSPFEATURES (via quarto → otter → pyright/ruff)
--   K     hover doc       gd   go to definition
--   gr    references      \rn  rename
--   \gf   format
--   (diagnostics update on BufWritePost)
--
-- MISC
--   :NewNotebook <name>   create a blank .ipynb
--   :checkhealth molten   diagnose setup
-- =============================================================================
