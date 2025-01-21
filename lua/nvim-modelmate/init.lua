local amazonq = require('nvim-modelmate.amazonq')
local ollama = require('nvim-modelmate.ollama')
local settings = require('nvim-modelmate.settings')
local window = require('nvim-modelmate.window')
local M = {}

M.interactive_window = function(context)
  local cmd = {}
  if context == 'llama' then
    cmd[context] = ollama.run(settings.current.model)
  elseif context == 'amazonq' then
    cmd[context] = amazonq.run()
  elseif context == 'amazonq_history' then
    cmd[context] = amazonq.run_with_history()
  elseif context == 'amazonq_git' then
    cmd[context] = amazonq.run_with_git()
  end

  if cmd[context] then
    window.create_chat_window()
    vim.fn.termopen(cmd[context])
  end
end

local function set_cmds()
  vim.api.nvim_create_user_command('ModelLlama', function()
    M.interactive_window('llama')
  end, {})
  vim.api.nvim_create_user_command('ModelQ', function()
    M.interactive_window('amazonq')
  end, {})
  vim.api.nvim_create_user_command('ModelQhist', function()
    M.interactive_window('amazonq_history')
  end, {})
  vim.api.nvim_create_user_command('ModelQgit', function()
    M.interactive_window('amazonq_git')
  end, {})
end

function M.setup(config)
  if config then
    settings.set(config)
  end

  local status, err = pcall(ollama.is_ready)
  if not status then
    print('Error checking Ollama requirements: ' .. err)
  end

  status = pcall(ollama.start)
  if not status then
    print('Error checking Ollama status: ' .. err)
  end

  set_cmds()
end

return M
