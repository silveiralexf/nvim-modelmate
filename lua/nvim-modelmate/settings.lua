-- lua/nvim-modelmate/settings.lua
local M = {}

M.defaults = {
  model = 'llama2',
  included_extensions = {
    '.lua',
    '.py',
    '.js',
    '.ts',
    '.jsx',
    '.tsx',
    '.java',
    '.cpp',
    '.c',
    '.h',
    '.hpp',
    '.rs',
    '.go',
    '.md',
    '.yaml',
    '.yml',
    '.json',
  },
  excluded_patterns = {
    'node_modules/',
    'dist/',
    'build/',
    'target/',
  },
}

M.current = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.current = vim.tbl_deep_extend('force', M.defaults, opts or {})
end

return M
