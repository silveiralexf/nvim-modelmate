local M = {}
local settings = require('nvim-modelmate.settings')

function M.run()
  return 'q chat'
end

function M.run_with_git_unstaged_changes_commits()
  return 'q chat "@git PR description: conventional commits + emojis + file links + AI note informing use of nvim-modelmate"'
end

function M.run_with_history()
  local input = vim.fn.input('Ask a question with shell history context loaded:')
  if input == '' or nil then
    return false
  end
  return 'q chat "using my @history context... ' .. input .. '"'
end

function M.run_with_git()
  local input = vim.fn.input('Ask a question with git context loaded:')
  if input == '' or nil then
    return false
  end

  return 'q chat "using @git context... ' .. input .. '"'
end

function M.run_with_workspace()
  -- Collect workspace files content
  local workspace_files = {}
  local files = vim.fn.glob(vim.fn.getcwd() .. '/**/*.*', false, true)

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
        table.insert(workspace_files, relative_path)
      end
    end
  end

  -- Create new buffer for terminal
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.cmd('vsplit')
  vim.api.nvim_win_set_buf(0, term_buf)

  return string.format('q chat "@workspace %s"', table.concat(workspace_files, ' '))
end

return M