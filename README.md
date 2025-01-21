# nvim-modelmate

LLM coding mate for Neovim.

## Requirements

- [Ollama](https://github.com/ollama/ollama)
- [AmazonQ CLI](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line.html)

## Installation

Use your favorite package manager to install the plugin:

### lazy.nvim

```lua
{
    'silveiralexf/nvim-modelmate'
}
```

### Packer

```lua
use 'silveiralexf/nvim-modelmate'
```

### vim-plug

```lua
Plug 'silveiralexf/nvim-modelmate'
```

## Setup & configuration

In your `init.vim`, setup the plugin:

```lua
require('nvim-modelmate').setup {}
```

You can provide the following optional configuration table to the `setup`
function, for setting a different model on Ollama:

```lua
  {
    'silveiralexf/nvim-modelmate',
    config = function()
      require('nvim-modelmate').setup({
        debug = false,
        model = 'llama3:8b',
      })
    end,
  }
```

## Keybindings

You may set custom keybindings like this:

```lua
-- nvim/lua/config/keymaps.lua

-- Wrapper for vim.keymap.set function
local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

map('n', '\\m', '', { desc = 'ModelMate' })
map('n', '\\mo', '<cmd>ModelLlama<cr>', { desc = 'ModelLlama-chat' })
map('n', '\\mq', '<cmd>ModelQ<cr>', { desc = 'ModelQ-chat' })
map('n', '\\mg', '<cmd>ModelQgit<cr>', { desc = 'ModelQ-Git ask?' })
map('n', '\\mh', '<cmd>ModelQhist<cr>', { desc = 'ModelQ-History ask?' })
```

## Usage

Use on of the following auto-commands for directly chatting in a new
`Terminal` window where you can start chatting with your LLM.

- `:ModelLlama`
- `:ModelQ`
- `:ModelQhist`
- `:ModelQgit`

To exit `Terminal` mode, which by default locks the focus to the terminal
buffer, use the bindings `Ctrl-\ Ctrl-n`

## References & Inspirations

A big shout-out to thank the amazing folks, from which I borrowed ideas (and code),
for this plugin:

- [jpmcb/nvim-llama](https://github.com/jpmcb/nvim-llama)
- [Jacob411/Ollama-Copilot](https://github.com/Jacob411/Ollama-Copilot)
