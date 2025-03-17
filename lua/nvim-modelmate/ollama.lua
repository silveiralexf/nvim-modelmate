local os = require('os')
local home = os.getenv('HOME')
local ollama_api = require('nvim-modelmate.ollama_api')
local settings = require('nvim-modelmate.settings')

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

  -- Start chat session with Ollama API without workspace context
  ollama_api.start_chat_session(model, 'You are a helpful assistant.')

  -- Return empty string since we're handling the UI in Lua
  return ''
end

function M.run_with_workspace(model)
  if model == nil then
    print('Ollama model was not provided')
    return false
  end

  -- Get all files in the workspace
  local files = vim.fn.glob(vim.fn.getcwd() .. '/**/*.*', false, true)

  -- Build workspace context
  local workspace_context = 'Workspace files:\n\n'

  -- Track how many files we've added to the context
  local files_added = 0

  for _, file in ipairs(files) do
    local ext = '.' .. vim.fn.fnamemodify(file, ':e')
    local relative_path = vim.fn.fnamemodify(file, ':~:.')

    -- Check if file extension is included and not in excluded patterns
    local should_include = vim.tbl_contains(settings.current.included_extensions, ext)
    if should_include then
      local excluded = false
      for _, pattern in ipairs(settings.current.excluded_patterns) do
        if relative_path:match(pattern) then
          excluded = true
          break
        end
      end

      if not excluded then
        -- Read file content
        local file_handle = io.open(file, 'r')
        if file_handle then
          local content = file_handle:read('*all')
          file_handle:close()

          -- Add file with content to the workspace context
          workspace_context = workspace_context .. 'File: ' .. relative_path .. '\n\n' .. content .. '\n\n---\n\n'
          files_added = files_added + 1
        end
      end
    end
  end

  -- Check if we added any files
  if files_added == 0 then
    print(
      'No files were added to the workspace context. Check your included_extensions and excluded_patterns settings.'
    )
    return false
  end

  print(string.format('Added %d files to workspace context', files_added))

  -- Create system message with workspace context
  local system_message = workspace_context
    .. '\n\nYou are a helpful assistant. Use the code files above to answer questions about this codebase.'

  -- Start chat session with Ollama API
  ollama_api.start_chat_session(model, system_message)

  -- Return empty string since we're handling the UI in Lua
  return ''
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
