local M = {}

M.config = {
  default_user = 'ati',
  remote_base_path = '/app',
  last_robot_ip = nil,
  last_container = nil,
}

-- ---------------------------
-- Utilities
-- ---------------------------

local function check_dependencies()
  local required = { 'ssh', 'scp', 'git' }
  for _, cmd in ipairs(required) do
    if vim.fn.executable(cmd) == 0 then
      vim.notify(string.format('Required command "%s" not found in PATH', cmd), vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

local function current_file()
  local f = vim.fn.expand '%:p'
  if f == '' then
    vim.notify('No file associated with current buffer', vim.log.levels.ERROR)
    return nil
  end
  return vim.fn.fnamemodify(f, ':p') -- normalized absolute path
end

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

  return vim.fn.fnamemodify(vim.trim(out[1]), ':p')
end

local function relative_path()
  local file = current_file()
  if not file then
    return nil
  end

  local dir = vim.fn.fnamemodify(file, ':h')

  local out = vim.fn.systemlist {
    'git',
    '-C',
    dir,
    'ls-files',
    '--full-name',
    file,
  }

  if vim.v.shell_error ~= 0 or not out[1] then
    vim.notify('File is not tracked by git', vim.log.levels.ERROR)
    return nil
  end

  return vim.trim(out[1])
end
local function ssh_target(ip)
  return string.format('%s@%s', M.config.default_user, ip)
end

local function run_command(cmd)
  local output = vim.fn.systemlist(cmd)
  local success = vim.v.shell_error == 0
  return success, output
end

-- ---------------------------
-- Remote path handling
-- ---------------------------

local function ensure_remote_path(opts)
  vim.notify('Checking if remote path exists...', vim.log.levels.INFO)

  local check_cmd = {
    'ssh',
    opts.ssh,
    'docker',
    'exec',
    opts.container,
    'test',
    '-e',
    opts.remote_path,
  }

  local success = run_command(check_cmd)

  if success then
    vim.notify('Remote path exists: ' .. opts.remote_path, vim.log.levels.INFO)
    return true
  end

  vim.notify('Remote path does not exist: ' .. opts.remote_path, vim.log.levels.WARN)

  local choice = vim.fn.input 'Remote file does not exist. Create it? (y/n): '
  if choice ~= 'y' and choice ~= 'Y' then
    vim.notify('Cancelled: remote file does not exist', vim.log.levels.WARN)
    return false
  end

  local parent_dir = vim.fn.fnamemodify(opts.remote_path, ':h')

  local mkdir_cmd = {
    'ssh',
    opts.ssh,
    'docker',
    'exec',
    opts.container,
    'sh',
    '-c',
    string.format('mkdir -p %s && touch %s', vim.fn.shellescape(parent_dir), vim.fn.shellescape(opts.remote_path)),
  }

  local create_success, output = run_command(mkdir_cmd)

  if not create_success then
    vim.notify('Failed to create remote path: ' .. opts.remote_path .. '\n' .. table.concat(output, '\n'), vim.log.levels.ERROR)
    return false
  end

  vim.notify('Created remote path: ' .. opts.remote_path, vim.log.levels.INFO)
  return true
end

-- ---------------------------
-- Copy logic
-- ---------------------------

local function copy_file(opts)
  local remote_tmp = '/tmp/nvim_copy_' .. vim.fn.fnamemodify(opts.local_path, ':t') .. '_' .. os.time()

  local remote_final = M.config.remote_base_path .. '/' .. opts.relative_path

  -- Debug (enable if diagnosing)
  -- vim.notify("Remote final path: " .. remote_final)

  local path_ok = ensure_remote_path {
    ssh = opts.ssh,
    container = opts.container,
    remote_path = remote_final,
  }

  if not path_ok then
    return
  end

  -- Step 1: SCP to remote host
  vim.notify('Copying file to remote host...', vim.log.levels.INFO)

  local scp_cmd = {
    'scp',
    opts.local_path,
    opts.ssh .. ':' .. remote_tmp,
  }

  local scp_success, scp_output = run_command(scp_cmd)

  if not scp_success then
    vim.notify('Failed to copy file to remote host\n' .. table.concat(scp_output, '\n'), vim.log.levels.ERROR)
    return
  end

  -- Step 2: docker cp into container
  vim.notify('Copying file into container...', vim.log.levels.INFO)

  local docker_cp_cmd = {
    'ssh',
    opts.ssh,
    'docker',
    'cp',
    remote_tmp,
    opts.container .. ':' .. remote_final,
  }

  local docker_success, docker_output = run_command(docker_cp_cmd)

  if not docker_success then
    vim.notify('Failed to copy file to container\n' .. table.concat(docker_output, '\n'), vim.log.levels.ERROR)
    return
  end

  -- Step 3: cleanup
  run_command {
    'ssh',
    opts.ssh,
    'rm',
    '-f',
    remote_tmp,
  }

  vim.notify(string.format('✓ Successfully copied to %s:%s', opts.container, remote_final), vim.log.levels.INFO)
end

-- ---------------------------
-- Public API
-- ---------------------------

function M.copy_to_robot()
  if not check_dependencies() then
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
  if not check_dependencies() then
    return
  end

  if not M.config.last_robot_ip or not M.config.last_container then
    vim.notify('No previ robot/container found, using full copy', vim.log.levels.WARN)
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
