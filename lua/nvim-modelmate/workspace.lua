-- lua/nvim-modelmate/workspace.lua
local M = {}

M.config = {
  max_file_size = 1024 * 1024,
  file_patterns = {
    '*.lua',
    '*.py',
    '*.js',
    '*.ts',
    '*.jsx',
    '*.tsx',
    '*.java',
    '*.cpp',
    '*.c',
    '*.h',
    '*.hpp',
    '*.rs',
    '*.go',
    '*.md',
    '*.yaml',
    '*.yml',
    '*.json',
  },
  excluded_directories = {
    'node_modules',
    '.git',
    'dist',
    'build',
    'target',
  },
}

function M.is_file_allowed(file)
  for _, excluded in ipairs(M.config.excluded_directories) do
    if file:match('/' .. excluded .. '/') then
      return false
    end
  end

  for _, pattern in ipairs(M.config.file_patterns) do
    if file:match(pattern:gsub('*', '.*')) then
      return true
    end
  end
  return false
end

function M.read_file_content(file)
  local fd = io.open(file, 'r')
  if not fd then
    return ''
  end
  local content = fd:read('*all')
  fd:close()
  return content
end

function M.create_workspace_summary()
  local workspace_root = vim.fn.getcwd()
  local summary = {}

  -- Add header
  table.insert(summary, 'Workspace Files')
  table.insert(summary, string.rep('=', 40))

  local files = vim.fn.systemlist('find ' .. workspace_root .. ' -type f')

  for _, file in ipairs(files) do
    if M.is_file_allowed(file) then
      local stats = vim.loop.fs_stat(file)
      if stats and stats.size < M.config.max_file_size then
        local relative_path = vim.fn.fnamemodify(file, ':.')
        table.insert(summary, '')
        table.insert(summary, 'File: ' .. relative_path)
        table.insert(summary, string.rep('-', 40))

        -- Read and split file content into lines
        local content = M.read_file_content(file)
        for line in content:gmatch('[^\r\n]+') do
          table.insert(summary, line)
        end
      end
    end
  end

  return summary
end

return M