-- lua/nvim-modelmate/ollama_api.lua
local M = {}
local api = vim.api
local fn = vim.fn

-- Function to stream a request to Ollama API
function M.stream_request(endpoint, data, callback)
  -- Create a temporary file for the JSON data
  local temp_file = os.tmpname()
  local temp_handle = io.open(temp_file, 'w')
  if not temp_handle then
    return nil, 'Failed to create temporary file for JSON data'
  end

  -- Write JSON data to the file
  temp_handle:write(vim.fn.json_encode(data))
  temp_handle:close()

  -- Create a job to stream the response
  local cmd = { 'curl', '-s', '-N', '-X', 'POST', 'http://localhost:11434/api/' .. endpoint, '-d', '@' .. temp_file }

  local job_id = fn.jobstart(cmd, {
    on_stdout = function(_, chunk_data, _)
      if chunk_data then
        for _, line in ipairs(chunk_data) do
          if line and line ~= '' then
            -- Parse JSON chunk
            local success, result = pcall(vim.fn.json_decode, line)
            if success and result then
              callback(result)
            end
          end
        end
      end
    end,
    on_exit = function(_, _, _)
      os.remove(temp_file)
    end,
    stdout_buffered = false,
  })

  return job_id
end

-- Function to start a chat session with Ollama
function M.start_chat_session(model, system_message)
  -- Create a buffer for the chat
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  api.nvim_buf_set_option(buf, 'swapfile', false)

  -- Set buffer filetype to markdown for syntax highlighting
  api.nvim_buf_set_option(buf, 'filetype', 'markdown')

  -- Set buffer name
  api.nvim_buf_set_name(buf, 'Ollama Chat - ' .. model)

  -- Create a window for the chat
  local win = api.nvim_get_current_win()
  api.nvim_win_set_buf(win, buf)

  -- Store conversation history
  local conversation = {
    {
      role = 'system',
      content = system_message,
    },
  }

  -- Add welcome message to buffer
  local welcome_msg = {
    '# Welcome to Ollama Chat with workspace context!',
    'Type your message in the input area below and press Enter to send.',
    'Press Ctrl+C to exit the chat session.',
    '',
    '**Model:** ' .. model,
    '-------------------------------------------',
    '',
  }
  api.nvim_buf_set_lines(buf, 0, -1, false, welcome_msg)

  -- Create input buffer at the bottom
  local input_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(input_buf, 'buftype', 'nofile')
  api.nvim_buf_set_option(input_buf, 'bufhidden', 'hide')
  api.nvim_buf_set_option(input_buf, 'swapfile', false)

  -- Split window for input
  vim.cmd('split')
  local input_win = api.nvim_get_current_win()
  api.nvim_win_set_buf(input_win, input_buf)
  api.nvim_win_set_height(input_win, 3)

  -- Set input window options
  vim.wo[input_win].number = false
  vim.wo[input_win].relativenumber = false
  vim.wo[input_win].cursorline = true

  -- Set input buffer prompt
  api.nvim_buf_set_lines(input_buf, 0, -1, false, { 'You: ' })
  api.nvim_win_set_cursor(input_win, { 1, 5 }) -- Position cursor after "You: "

  -- Function to append text to chat buffer
  local function append_to_chat(text, prefix)
    local lines = {}
    prefix = prefix or ''

    -- Format user messages as bold markdown
    if prefix == 'You: ' then
      prefix = '**You:** '
    elseif prefix == 'Model: ' then
      prefix = '**Model:** '
    end

    -- Split text into lines
    for line in string.gmatch(text, '[^\r\n]+') do
      table.insert(lines, prefix .. line)
    end

    -- Add empty line after message
    table.insert(lines, '')

    -- Append to buffer
    local line_count = api.nvim_buf_line_count(buf)
    api.nvim_buf_set_lines(buf, line_count, line_count, false, lines)

    -- Scroll to bottom
    api.nvim_win_set_cursor(win, { line_count + #lines, 0 })
  end

  -- Function to send message to Ollama
  local function send_message()
    -- Get input text
    local input_lines = api.nvim_buf_get_lines(input_buf, 0, -1, false)
    local input_text = table.concat(input_lines, '\n')

    -- Extract message (remove "You: " prefix)
    local message = string.sub(input_text, 6)
    if message == '' then
      return
    end

    -- Add user message to conversation
    table.insert(conversation, {
      role = 'user',
      content = message,
    })

    -- Display user message in chat buffer
    append_to_chat(message, 'You: ')

    -- Clear input buffer and reset prompt
    api.nvim_buf_set_lines(input_buf, 0, -1, false, { 'You: ' })
    api.nvim_win_set_cursor(input_win, { 1, 5 })

    -- Add initial model response line
    append_to_chat('', 'Model: ')

    -- Variables for streaming response
    local full_response = ''

    -- Stream request to Ollama
    M.stream_request('chat', {
      model = model,
      messages = conversation,
      stream = true,
    }, function(chunk)
      if chunk.message then
        -- Update the response with the new chunk
        local chunk_content = chunk.message.content or ''
        full_response = full_response .. chunk_content
      end

      -- When done, add the response to conversation and update the buffer
      if chunk.done then
        -- Split the full response into lines
        local lines = {}
        for line in full_response:gmatch('[^\r\n]+') do
          table.insert(lines, line)
        end

        -- Get the current buffer line count
        local line_count = api.nvim_buf_line_count(buf)

        -- Replace the "Model: " line with the first line of the response
        if #lines > 0 then
          api.nvim_buf_set_lines(buf, line_count - 1, line_count, false, { '**Model:** ' .. lines[1] })

          -- Add the rest of the lines
          if #lines > 1 then
            api.nvim_buf_set_lines(buf, line_count, line_count, false, vim.list_slice(lines, 2))
          end
        end

        -- Add assistant response to conversation
        table.insert(conversation, {
          role = 'assistant',
          content = full_response,
        })

        -- Add an empty line after the response
        line_count = api.nvim_buf_line_count(buf)
        api.nvim_buf_set_lines(buf, line_count, line_count, false, { '' })
      end
    end)
  end

  -- Set up key mappings for input buffer
  api.nvim_buf_set_keymap(
    input_buf,
    'i',
    '<CR>',
    '<Esc>:lua _G.ollama_send_message()<CR>',
    { noremap = true, silent = true }
  )
  api.nvim_buf_set_keymap(
    input_buf,
    'n',
    '<CR>',
    ':lua _G.ollama_send_message()<CR>',
    { noremap = true, silent = true }
  )

  -- Set up Ctrl+C to close both buffers
  api.nvim_buf_set_keymap(input_buf, 'n', '<C-c>', ':lua _G.ollama_close_chat()<CR>', { noremap = true, silent = true })
  api.nvim_buf_set_keymap(
    input_buf,
    'i',
    '<C-c>',
    '<Esc>:lua _G.ollama_close_chat()<CR>',
    { noremap = true, silent = true }
  )
  api.nvim_buf_set_keymap(buf, 'n', '<C-c>', ':lua _G.ollama_close_chat()<CR>', { noremap = true, silent = true })

  -- Store buffers and windows in global state
  _G.ollama_chat_state = {
    chat_buf = buf,
    chat_win = win,
    input_buf = input_buf,
    input_win = input_win,
    conversation = conversation,
  }

  -- Global function to send message
  _G.ollama_send_message = function()
    send_message()
  end

  -- Global function to close chat
  _G.ollama_close_chat = function()
    if _G.ollama_chat_state then
      api.nvim_buf_delete(_G.ollama_chat_state.input_buf, { force = true })
      api.nvim_buf_delete(_G.ollama_chat_state.chat_buf, { force = true })
      _G.ollama_chat_state = nil
    end
  end

  -- Enter insert mode in input buffer
  vim.cmd('startinsert')

  return buf
end

return M
