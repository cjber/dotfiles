local scopes = {o = vim.o, b = vim.bo, w = vim.wo}
local cmd = vim.cmd

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= "o" then
        scopes["o"][key] = value
    end
end

opt("o", "hidden", true)
opt("o", "ignorecase", true)
opt("o", "splitbelow", true)
opt("o", "splitright", true)
opt("o", "termguicolors", true)
opt("w", "number", true)
opt("o", "numberwidth", 2)
opt("o", "history", 10000)
opt("o", "ignorecase", true)
opt("o", "smartcase", true)
opt("o", "incsearch", true)

opt("o", "mouse", "a")

opt("w", "signcolumn", "yes")
opt("o", "cmdheight", 1)

opt("o", "updatetime", 250) -- update interval for gitsigns 
opt("o", "clipboard", "unnamedplus")

-- for indentline
opt("b", "expandtab", true)
opt("b", "shiftwidth", 4)
opt("b", "tabstop", 4)
opt("b", "softtabstop", 4)

vim.bo.undofile = true
vim.bo.undolevels = 1000

cmd("set pumheight=10")
cmd("set linebreak")
cmd("set showbreak=¦")
cmd("set conceallevel=2")
cmd("set concealcursor=")

cmd("set nobackup")
cmd("set noswapfile")
cmd("set nowritebackup")

cmd("autocmd BufEnter * if (winnr('$') == 1 && &buftype == 'terminal') | q | endif")

local M = {}

function M.is_buffer_empty()
    -- Check whether the current buffer is empty
    return vim.fn.empty(vim.fn.expand("%:t")) == 1
end

function M.has_width_gt(cols)
    -- Check if the windows width is greater than a given number of columns
    return vim.fn.winwidth(0) / 2 > cols
end

return M
