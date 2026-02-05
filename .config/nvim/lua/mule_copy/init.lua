-- copy_to_robot.lua
-- Neovim plugin to copy current file to robot Docker container

local M = {}

-- Configuration
M.config = {
  script_path = vim.fn.expand '~' .. '/copy.sh',
  default_user = 'user',
  last_robot_ip = nil,
  last_container = nil,
}

-- Function to get the relative path from the mule repository root
local function get_relative_path()
  local current_file = vim.fn.expand '%:p'

  -- Find the repository root by looking for .git directory
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(vim.fn.expand '%:p:h') .. ' rev-parse --show-toplevel')[1]

  if vim.v.shell_error ~= 0 or not git_root then
    vim.notify('Error: Not in a git repository', vim.log.levels.ERROR)
    return nil
  end

  -- Get relative path
  local relative_path = current_file:sub(#git_root + 2)
  return relative_path
end

-- Function to copy file to robot
function M.copy_to_robot()
  local relative_path = get_relative_path()
  if not relative_path then
    return
  end

  vim.notify('File path: ' .. relative_path, vim.log.levels.INFO)

  -- Prompt for robot IP
  local default_ip = M.config.last_robot_ip or ''
  vim.ui.input({
    prompt = 'Robot IP address: ',
    default = default_ip,
  }, function(robot_ip)
    if not robot_ip or robot_ip == '' then
      vim.notify('Cancelled: No IP address provided', vim.log.levels.WARN)
      return
    end

    M.config.last_robot_ip = robot_ip

    -- Prompt for container name
    local default_container = M.config.last_container or ''
    vim.ui.input({
      prompt = 'Container name: ',
      default = default_container,
    }, function(container_name)
      if not container_name or container_name == '' then
        vim.notify('Cancelled: No container name provided', vim.log.levels.WARN)
        return
      end

      M.config.last_container = container_name

      -- Construct the SSH target
      local robot_ssh = M.config.default_user .. '@' .. robot_ip

      -- Construct the command
      local cmd = string.format(
        '%s %s %s %s',
        vim.fn.shellescape(M.config.script_path),
        vim.fn.shellescape(relative_path),
        vim.fn.shellescape(robot_ssh),
        vim.fn.shellescape(container_name)
      )

      vim.notify('Copying to robot...', vim.log.levels.INFO)

      -- Execute the command in a terminal buffer
      vim.cmd 'botright new'
      vim.cmd('terminal ' .. cmd)
      vim.cmd 'startinsert'
    end)
  end)
end

-- Function to copy with remembered values
function M.copy_to_robot_quick()
  if not M.config.last_robot_ip or not M.config.last_container then
    vim.notify('No previous values found. Use the full copy command first.', vim.log.levels.WARN)
    M.copy_to_robot()
    return
  end

  local relative_path = get_relative_path()
  if not relative_path then
    return
  end

  local robot_ssh = M.config.default_user .. '@' .. M.config.last_robot_ip

  local cmd = string.format(
    '%s %s %s %s',
    vim.fn.shellescape(M.config.script_path),
    vim.fn.shellescape(relative_path),
    vim.fn.shellescape(robot_ssh),
    vim.fn.shellescape(M.config.last_container)
  )

  vim.notify(string.format('Copying to %s:%s...', M.config.last_robot_ip, M.config.last_container), vim.log.levels.INFO)

  vim.cmd 'botright new'
  vim.cmd('terminal ' .. cmd)
  vim.cmd 'startinsert'
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_extend('force', M.config, opts)

  -- Create user commands
  vim.api.nvim_create_user_command('CopyToRobot', M.copy_to_robot, {})
  vim.api.nvim_create_user_command('CopyToRobotQuick', M.copy_to_robot_quick, {})

  -- Copy to Robot setup
  -- local ok, copy_to_robot = pcall(require, 'copy_to_robot')
  -- if ok and copy_to_robot then
  -- M.copy_to_robot.setup {
  --   script_path = vim.fn.expand '~' .. '/copy.sh',
  --   default_user = 'ati',
  -- }

  vim.keymap.set('n', '<leader>mC', '<cmd>CopyToRobot<CR>', {
    desc = 'Copy to robot (with prompts)',
  })
  vim.keymap.set('n', '<leader>mc', '<cmd>CopyToRobotQuick<CR>', {
    desc = 'Copy to robot (quick)',
  })
  -- end
end

return M
