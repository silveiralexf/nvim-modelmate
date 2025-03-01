local os = require('os')
local home = os.getenv('HOME')

-- Check if a file or directory exists at a given path
-- Attribution: https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
local function dir_exists(target)
  local ok, err, code = os.rename(target, target)

  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end

  return ok, err
end

local function is_ollama_installed()
  -- Use 'command -v' to check if ollama exists in PATH
  local handle = io.popen('command -v ollama')
  if not handle then
    return false, 'Failed to execute command check'
  end

  local result = handle:read('*a')
  local success = handle:close()

  -- If command -v returns a path, ollama is installed
  if success and result and #result > 0 then
    return true
  else
    return false, 'Ollama is not installed or not in PATH'
  end
end

local function is_ollama_running()
  local handle = io.popen('pgrep -x ollama')
  if not handle then
    return false, 'Failed to check Ollama process'
  end

  local result = handle:read('*a')
  local success = handle:close()

  if success and result and #result > 0 then
    return true
  else
    return false, 'Ollama service is not running'
  end
end

local M = {}

function M.start()
  local ollama_dir = home .. '/.ollama'
  local ok, _ = dir_exists(ollama_dir)
  if not ok then
    os.execute('mkdir ' .. ollama_dir)
    print('Created .ollama directory at ' .. ollama_dir)
  end
end

function M.run(model)
  if model == nil then
    print('Ollama model was not provided')

    return false
  end
  return 'ollama run ' .. model
end

function M.list()
  return 'ollama list'
end

function M.is_ready()
  local installed, install_err = is_ollama_installed()
  if not installed then
    return false, install_err
  end

  local running, running_err = is_ollama_running()
  if not running then
    return false, running_err
  end

  return true
end

return M