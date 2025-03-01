local amazonq = require('nvim-modelmate.amazonq')
local keymaps = require('nvim-modelmate.keymaps')
local ollama = require('nvim-modelmate.ollama')
local settings = require('nvim-modelmate.settings')
local window = require('nvim-modelmate.window')
local M = {}

M.interactive_window = function(context)
  local cmd = {}
  if context == 'llama' then
    window.create_chat_window()
    cmd[context] = ollama.run(settings.current.model)
  elseif context == 'amazonq' then
    window.create_chat_window()
    cmd[context] = amazonq.run()
  elseif context == 'amazonq_git' then
    cmd[context] = amazonq.run_with_git()
  elseif context == 'amazonq_git_unstaged_changes_commits' then
    cmd[context] = amazonq.run_with_git_unstaged_changes_commits()
  elseif context == 'amazonq_history' then
    cmd[context] = amazonq.run_with_history()
  elseif context == 'amazonq_workspace' then
    cmd[context] = amazonq.run_with_workspace()
  end

  if cmd[context] then
    window.create_chat_window()
    vim.fn.termopen(cmd[context])
    vim.cmd('startinsert')
  end
end

local function set_cmds()
  vim.api.nvim_create_user_command('ModelLlama', function()
    M.interactive_window('llama')
  end, {})

  vim.api.nvim_create_user_command('ModelQ', function()
    M.interactive_window('amazonq')
  end, {})

  vim.api.nvim_create_user_command('ModelQWorkspace', function()
    M.interactive_window('amazonq_workspace')
  end, {})

  vim.api.nvim_create_user_command('ModelQgit', function()
    M.interactive_window('amazonq_git')
  end, {})

  vim.api.nvim_create_user_command('ModelQgitCommits', function()
    M.interactive_window('amazonq_git_unstaged_changes_commits')
  end, {})

  vim.api.nvim_create_user_command('ModelQhist', function()
    M.interactive_window('amazonq_history')
  end, {})
end

function M.setup(opts)
  settings.setup(opts or {})
  keymaps.setup()

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

