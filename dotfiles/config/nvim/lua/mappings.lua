local g = vim.g

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

g.mapleader = " "
g.maplocalleader = ","

-- basic remaps
map('', 'J', '}')
map('', 'K', '{')
map('', 'H', '^')
map('', 'L', '$')
map('', 'U', '<C-r>')
map('', 'Y', 'y$')
map('', 'j', 'gj')
map('', 'k', 'gk')

map('', '<C-Space>', ':bnext<CR>')
map('', '<ESC><ESC>', ':noh<Return><ESC>')

-- window movement
map('', '<C-j>', '<C-w>j')
map('', '<C-k>', '<C-w>k')
map('', '<C-l>', '<C-w>l')
map('', '<C-h>', '<C-w>h')

-- spell
map('', '<Leader>ss', ':set invspell<CR>')
map('', '<Leader>sf', 'mz[s1z=e`z')

-- nvimr
map('', '<LocalLeader>s', '<Plug>RStart')

-- mundu
map('', '<Leader>fu', ':MundoToggle<CR>')
