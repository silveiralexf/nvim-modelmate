local M = {}

function M.run()
  return 'q chat'
end

function M.run_with_history()
  local input = vim.fn.input('Ask a question with shell history context loaded:')
  if input == '' or nil then
    return false
  end
  return 'q chat "@history ' .. input .. '"'
end

function M.run_with_git()
  local input = vim.fn.input('Ask a question with git context loaded:')
  if input == '' or nil then
    return false
  end

  return 'q chat "@git ' .. input .. '"'
end

return M
