-- lua/nvim-modelmate/commands.lua
local M = {}
local workspace = require('nvim-modelmate.workspace')

function M.setup_commands()
  -- Add workspace-aware command
  vim.api.nvim_create_user_command('ModelQWorkspace', function()
    -- Create split layout
    vim.cmd('vsplit')

    -- Create workspace context buffer on the left
    local context_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, context_buf)

    -- Set workspace content
    local summary = workspace.create_workspace_summary()
    vim.api.nvim_buf_set_lines(context_buf, 0, -1, false, summary)
    vim.api.nvim_buf_set_option(context_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(context_buf, 'buftype', 'nofile')

    -- Create Amazon Q chat on the right
    vim.cmd('vsplit')
    vim.cmd('terminal aws q chat')
    vim.cmd('startinsert')

    -- Set buffer name
    vim.api.nvim_buf_set_name(context_buf, 'Workspace Context')
  end, {})
end

return M