-- copy_to_robot.lua
-- Neovim plugin to copy current file into a robot Docker container at /app/<relative-path>

local M = {}

-- =====================
-- Configuration
-- =====================
M.config = {
  script_path = vim.fn.expand '~' .. '/copy.sh', -- optional fallback, not required
  default_user = 'user',
  last_robot_ip = nil,
  last_container = nil,
}

-- =====================
-- Utilities
-- =====================

-- Get absolute path of current buffer
local function current_file()
  local f = vim.fn.expand '%:p'
  if f == '' then
    vim.notify('No file associated with current buffer', vim.log.levels.ERROR)
    return nil
  end
  return f
end

-- Find git repository root
local function git_root()
  local file = current_file()
  if not file then
    return nil
  end

  local dir = vim.fn.fnamemodify(file, ':h')
  local out = vim.fn.systemlist { 'git', '-C', dir, 'rev-parse', '--show-toplevel' }
  if vim.v.shell_error ~= 0 or not out[1] then
    vim.notify('Not inside a git repository', vim.log.levels.ERROR)
    return nil
  end
  return out[1]
end

-- Get path relative to git root
local function relative_path()
  local root = git_root()
  if not root then
    return nil
  end

  local file = current_file()
  if not file then
    return nil
  end

  if not vim.startswith(file, root .. '/') then
    vim.notify('File is not inside the git repository', vim.log.levels.ERROR)
    return nil
  end

  return file:sub(#root + 2)
end

-- Open a terminal and run a command
local function run_in_terminal(cmd)
  vim.cmd 'botright new'
  vim.cmd('terminal ' .. cmd)
  vim.cmd 'startinsert'
end

-- =====================
-- Core logic
-- =====================

-- Build SSH target
local function ssh_target(ip)
  return string.format('%s@%s', M.config.default_user, ip)
end

-- Ask permission to create file if it does not exist in container
local function ensure_remote_path(opts, cb)
  -- opts: { ssh, container, remote_path }
  local check_cmd = string.format(
    'ssh %s docker exec %s sh -c %s',
    vim.fn.shellescape(opts.ssh),
    vim.fn.shellescape(opts.container),
    vim.fn.shellescape('[ -e ' .. opts.remote_path .. ' ]')
  )

  local ok = (vim.fn.system(check_cmd) == '' and vim.v.shell_error == 0)

  if ok then
    cb(true)
    return
  end

  vim.notify('Remote path checked: ' .. opts.remote_path, vim.log.levels.INFO)

  vim.ui.select({ 'Yes', 'No' }, {
    prompt = 'Remote file does not exist. Create it? ' .. opts.remote_path,
  }, function(choice)
    if choice ~= 'Yes' then
      vim.notify('Cancelled: remote file does not exist: ' .. opts.remote_path, vim.log.levels.WARN)
      cb(false)
      return
    end

    local mkdir_cmd = string.format(
      'ssh %s docker exec %s sh -c %s',
      vim.fn.shellescape(opts.ssh),
      vim.fn.shellescape(opts.container),
      vim.fn.shellescape('mkdir -p "$(dirname ' .. opts.remote_path .. ')" && touch ' .. opts.remote_path)
    )

    vim.fn.system(mkdir_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify('Failed to create remote path: ' .. opts.remote_path, vim.log.levels.ERROR)
      cb(false)
      return
    end

    cb(true)
  end)
end

-- Perform SCP into container
local function copy_file(opts)
  -- opts: { ssh, container, local_path, relative_path }
  local remote_tmp = '/tmp/nvim_copy_' .. vim.fn.fnamemodify(opts.local_path, ':t')
  local remote_final = '/app/' .. opts.relative_path

  ensure_remote_path({
    ssh = opts.ssh,
    container = opts.container,
    remote_path = remote_final,
  }, function(allowed)
    if not allowed then
      return
    end

    local cmd = string.format(
      'scp %s %s:%s && ssh %s docker cp %s %s:%s',
      vim.fn.shellescape(opts.local_path),
      vim.fn.shellescape(opts.ssh),
      vim.fn.shellescape(remote_tmp),
      vim.fn.shellescape(opts.ssh),
      vim.fn.shellescape(remote_tmp),
      vim.fn.shellescape(opts.container),
      vim.fn.shellescape(remote_final)
    )

    vim.notify('Copying file to container...', vim.log.levels.INFO)
    run_in_terminal(cmd)
  end)
end

-- =====================
-- Public API
-- =====================

function M.copy_to_robot()
  local rel = relative_path()
  if not rel then
    return
  end

  local local_path = current_file()
  if not local_path then
    return
  end

  vim.ui.input({
    prompt = 'Robot IP address: ',
    default = M.config.last_robot_ip or '',
  }, function(ip)
    if not ip or ip == '' then
      return
    end
    M.config.last_robot_ip = ip

    vim.ui.input({
      prompt = 'Container name: ',
      default = M.config.last_container or '',
    }, function(container)
      if not container or container == '' then
        return
      end
      M.config.last_container = container

      copy_file {
        ssh = ssh_target(ip),
        container = container,
        local_path = local_path,
        relative_path = rel,
      }
    end)
  end)
end

function M.copy_to_robot_quick()
  if not M.config.last_robot_ip or not M.config.last_container then
    vim.notify('No previous robot/container found', vim.log.levels.WARN)
    M.copy_to_robot()
    return
  end

  local rel = relative_path()
  if not rel then
    return
  end

  local local_path = current_file()
  if not local_path then
    return
  end

  copy_file {
    ssh = ssh_target(M.config.last_robot_ip),
    container = M.config.last_container,
    local_path = local_path,
    relative_path = rel,
  }
end

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})

  vim.api.nvim_create_user_command('CopyToRobot', M.copy_to_robot, {})
  vim.api.nvim_create_user_command('CopyToRobotQuick', M.copy_to_robot_quick, {})

  vim.keymap.set('n', '<leader>mC', '<cmd>CopyToRobot<CR>', { desc = 'Copy to robot (prompt)' })
  vim.keymap.set('n', '<leader>mc', '<cmd>CopyToRobotQuick<CR>', { desc = 'Copy to robot (quick)' })
end

return M
