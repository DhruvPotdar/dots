M = {
  'mfussenegger/nvim-dap',
    -- stylua: ignore
    keys = {
        { "<leader>dM", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Dap Breakpoint Condition", },
        { "<leader>b",  function() require("dap").toggle_breakpoint() end,                                    desc = "Dap Toggle Breakpoint", },
        { "<leader>dc", function() require("dap").continue() end,                                             desc = "Dap Continue", },
        { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Dap Run to Cursor", },
        { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Dap Go to line (no execute)", },
        { "<leader>di", function() require("dap").step_into() end,                                            desc = "Dap Step Into", },
        { "<leader>dj", function() require("dap").down() end,                                                 desc = "Dap Down", },
        { "<leader>dk", function() require("dap").up() end,                                                   desc = "Dap Up", },
        { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Dap Run Last", },
        { "<leader>do", function() require("dap").step_out() end,                                             desc = "Dap Step Out", },
        { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Dap Step Over", },
        { "<leader>dp", function() require("dap").pause() end,                                                desc = "Dap Pause", },
        { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Dap Toggle REPL", },
        { "<leader>ds", function() require("dap").session() end,                                              desc = "Dap Session", },
        { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Dap Terminate", },
        { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Dap Widgets", },
    },
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
            -- stylua: ignore
            keys = {
                { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",         mode = { "n", "v" } },
                { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap Toggle UI" },
            },
      config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'
        dapui.setup()
        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
          dapui.close()
        end
      end,
    },
    {
      'jay-babu/mason-nvim-dap.nvim',
      dependencies = {
        'mason-org/mason.nvim',
        'mfussenegger/nvim-dap',
      },
      config = function()
        require('mason-nvim-dap').setup {
          automatic_installation = false,
          ensure_installed = {},

          automatic_setup = true,

          handlers = {
            function(config)
              -- all sources with no handler get passed here
              local dap = require 'dap'

              dap.adapters['pwa-node'] = {
                type = 'server',
                host = '127.0.0.1',
                port = 8123,
                executable = {
                  command = 'js-debug-adapter',
                },
              }
              for _, language in ipairs { 'typescript', 'javascript' } do
                dap.configurations[language] = {
                  {
                    type = 'pwa-node',
                    request = 'launch',
                    name = 'Launch file',
                    program = '${file}',
                    cwd = '${workspaceFolder}',
                    runtimeExecutable = 'node',
                  },
                }
              end

              -- Keep original functionality
              require('mason-nvim-dap').default_setup(config)
            end,
          },
        }
        --Change icons
        local sign = vim.fn.sign_define
        sign('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
        sign('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondition' })
        sign('DapLogPoint', { text = '◆', texthl = 'DapLogPoint' })
        sign('DapStopped', { text = '󰁕 ', texthl = 'DiagnosticWarn' })
      end,
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = {},
    },
  },
  config = function() end,
}
return {}
