return {
  {
    "mfussenegger/nvim-dap", -- Enable debug adapters
    dependencies = {
      "mfussenegger/nvim-dap-python", -- Python debug adapter
      "rcarriga/nvim-dap-ui", -- UI-like for debugging
      "theHamsta/nvim-dap-virtual-text", -- Inline text during debugging
      "nvim-neotest/nvim-nio", -- Needed by nvim-dap-ui
      "folke/lazydev.nvim", -- Recommended by nvim-dap-ui
    },
    config = function()
      -- require("lazydev").setup({
      --   library = { plugins = { "nvim-dap-ui" }, types = true },
      -- })
      -- PERF:
      -- ===================================================
      -- UI related configurations
      -- ====================================================
      local dap = require("dap")
      local sign = vim.fn.sign_define

      sign("DapBreakpoint", { text = " ", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      sign("DapBreakpointCondition", { text = " ", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      sign("DapLogPoint", { text = "◆ ", texthl = "DapLogPoint", linehl = "", numhl = "" })
      sign("DapStoppedLine", { text = "󰁕 ", texthl = "DapLogPoint", linehl = "", numhl = "" })
      sign("DapBreakpointRejected", { text = " ", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })

      -- PERF:
      -- ===================================================
      -- Adapters
      -- ====================================================
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/codelldb"),
          args = { "--port", "${port}" },
        },
      }
      -- PERF:
      -- ===================================================
      -- Configurations
      -- ====================================================
      dap.configurations.cpp = {
        {
          name = "C++: Run file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          -- If you get an "Operation not permitted" error using this, try disabling YAMA:
          --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
          name = "C++: Attach to process",
          type = "codelldb", -- Adjust this to match your adapter name (`dap.adapters.<name>`)
          request = "attach",
          pid = require("dap.utils").pick_process,
          args = {},
        },
        {
          name = "C++: ROS Node",
          type = "codelldb",
          request = "launch",
          -- Might need to consider using vim.ui.input
          program = function()
            local pkgName = vim.fn.input("ROS Package: ", "")
            return vim.fn.input(
              "Path to executable: ",
              vim.fn.getcwd() .. "/install/" .. pkgName .. "/lib/" .. pkgName .. "/",
              "file"
            )
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      -- PERF:
      -- ====================================================
      -- Extensions configurations
      -- ====================================================
      require("dapui").setup({
        controls = {
          icons = {
            pause = "⏸ ",
            play = "▶ ",
            terminate = "⏹ ",
          },
        },
        floating = {
          border = "rounded",
        },
        layouts = {
          {
            elements = {
              { id = "stacks", size = 0.30 },
              { id = "breakpoints", size = 0.20 },
              { id = "scopes", size = 0.50 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "console", size = 0.50 },
              { id = "repl", size = 0.50 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })
      require("nvim-dap-virtual-text").setup()
      require("dap-python").setup()
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Python: ROS2 lauch test",
        program = "/opt/ros/humble/bin/launch_test",
        args = { "${file}" },
      })

      require("dap-python").test_runner = "pytest"

      -- PERF:
      -- ====================================================
      -- Custom User Commands for Dap
      -- ====================================================
      vim.api.nvim_create_user_command("DapUIToggle", ":lua require('dapui').toggle()", {})
      vim.api.nvim_create_user_command("DapPytestMethod", ":lua require('dap-python').test_method()", {})

      vim.api.nvim_create_user_command(
        "DapResetUI",
        ":lua require('dapui').open({reset = true})",
        { desc = "Reset DAP UI Layout" }
      )

      vim.api.nvim_create_user_command(
        "DapLogBreakpoint",
        ":lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log Message: '))",
        { desc = "Set log message breakpoint" }
      )
      vim.api.nvim_create_user_command(
        "DapConditionBreakpoint",
        ":lua require('dap').set_breakpoint(vim.fn.input('Breakpoint Condition: '))",
        { desc = "Set conditional breakpoint" }
      )
      vim.api.nvim_create_user_command(
        "DapConditionHitBreakpoint",
        ":lua require('dap').set_breakpoint(vim.fn.input('Breapoint Condition: '), vim.fn.input('Hit Condition: '))",
        { desc = "Set condition and hit breakpoint" }
      )
      vim.api.nvim_create_user_command(
        "DapHitBreakpoint",
        ":lua require('dap').set_breakpoint(nil, vim.fn.input('Hit Condition: '))",
        { desc = "Set hit breakpoint" }
      )

      -- PERF:
      -- ====================================================
      -- Configure DAP UI Listeners
      -- ====================================================
      local dapui = require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
