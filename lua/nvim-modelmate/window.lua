local M = {}

M.create_chat_window = function()
  -- Split the window vertically and set size
  vim.cmd('vsplit')
  vim.cmd('vertical resize 80')

  -- Open a new buffer in the split window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  -- Get the current window handle
  local win = vim.api.nvim_get_current_win()

  -- Set window-local options using vim.wo
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  -- Set buffer-local options using vim.bo
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'

  return buf
end

return M
