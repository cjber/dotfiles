local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
        'git',
        'clone',
        'https://github.com/wbthomason/packer.nvim',
        install_path
    })
    execute 'packadd packer.nvim'
end

require('plugins.plugs')
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.nvimtree')
require('plugins.betterqf')
require('plugins.bufferline')

-- lsp configs
require('plugins.lspconfig') -- lsp config
require('plugins.lspsaga')
require('plugins.nvimcompe') -- completions
require('plugins.lspkind') -- completion icons
require('plugins.textobjects') -- Move in functions etc
require('trouble').setup()

require('numb').setup()
require('kommentary.config').use_extended_mappings()
require('colorizer').setup({'*'}, {mode = 'foreground'})
require('spellsitter').setup()
require('symbols-outline').setup()
require('which-key').setup()
require('zen-mode').setup()
require('jupyter-nvim').setup()
require('dap-python').setup('~/.virtualenvs/nvim/bin/python')
require('lightspeed').setup {
    jump_to_first_match = true,
    jump_on_partial_input_safety_timeout = 400,
    highlight_unique_chars = false,
    grey_out_search_area = true,
    match_only_the_start_of_same_char_seqs = true,
    limit_ft_matches = 5,
    full_inclusive_prefix_key = '<c-x>'
}
require('todo-comments').setup()
require('autosave').setup()
