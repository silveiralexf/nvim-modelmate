-- lua/nvim-modelmate/keymaps.lua
local M = {}

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.setup()
  -- Leader key for ModelMate
  map('n', '\\m', '', { desc = 'ModelMate' })

  -- Individual commands
  map('n', '\\mo', '<cmd>ModelLlama<cr>', { desc = 'ModelLlama-chat' })
  map('n', '\\mq', '<cmd>ModelQ<cr>', { desc = 'ModelQ-chat' })
  map('n', '\\mg', '<cmd>ModelQgit<cr>', { desc = 'ModelQ-Git context' })
  map('n', '\\mm', '<cmd>ModelQgitCommits<cr>', { desc = 'ModelQ-Git Unstaged Commit Msgs' })
  map('n', '\\mh', '<cmd>ModelQhist<cr>', { desc = 'ModelQ-History context' })
  map('n', '\\mw', '<cmd>ModelQWorkspace<cr>', { desc = 'ModelQ-Workspace context' })
end

return M
