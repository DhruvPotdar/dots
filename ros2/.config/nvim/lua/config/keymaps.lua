-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "J", ":m '<-1<CR>gv=gv")

-- Center the screen when scrolling by half page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search terms stay on center of screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("n", "<leader>ya", ":%y+<CR>", { desc = "Yank all content in file" })

-- Save as normal
vim.keymap.set("n", "<C-s>", ":write<CR>", { desc = "Save file" })

-- ====================================================
-- Debugging -> dap
-- ====================================================
vim.keymap.set("n", "<F2>", ":lua require('dapui').toggle()<CR>")
vim.keymap.set("n", "<leader>dc", ":lua require('dap').continue()<CR>")
vim.keymap.set("n", "<leader>do", ":lua require('dap').step_over()<CR>")
vim.keymap.set("n", "<leader>di", ":lua require('dap').step_into()<CR>")
vim.keymap.set("n", "<leader>dk", function()
  require("dap.ui.widgets").hover()
end)
vim.keymap.set("n", "<leader>d?", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end)
vim.keymap.set("n", "<leader>du", ":lua require('dap').step_out()<CR>")
vim.keymap.set(
  "n",
  "<leader>dl",
  ":lua require('dapui').float_element()<CR>",
  { silent = true, noremap = true, desc = "Open floating window in Dap UI" }
)
vim.keymap.set(
  "n",
  "<leader>dt",
  ":lua require('dap').toggle_breakpoint()<CR>",
  { silent = true, noremap = true, desc = "Toggle breakpoint" }
)
vim.keymap.set(
  "n",
  "<leader>dm",
  ":lua require('dap-python').test_method()<CR>",
  { silent = true, noremap = true, desc = "DapPytest : Debug method" }
)
vim.keymap.set(
  "n",
  "<leader>df",
  ":lua require('dap-python').test_class()<CR>",
  { silent = true, noremap = true, desc = "DapPytest : Debug class" }
)
