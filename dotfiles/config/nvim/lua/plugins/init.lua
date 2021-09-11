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
require('plugins.alpha')

-- lsp configs
require('plugins.lspconfig') -- lsp config
require('plugins.cmp') -- lsp config
require('plugins.lspsaga')
require('plugins.lspkind') -- completion icons
require('plugins.textobjects') -- Move in functions etc

-- misc
require('trouble').setup()
require('numb').setup()
require('kommentary.config').use_extended_mappings()
require('colorizer').setup({'*'}, {mode = 'foreground'})
require('spellsitter').setup()
require('symbols-outline').setup()
vim.g.symbols_outline = {
    symbol_blacklist = {'Constant', 'Variable'},
    auto_preview = false,
    symbols = {
        Class = {icon = 'ﴯ', hl = 'TSType'},
        Function = {icon = '', hl = 'TSFunction'}
    }
}
require('which-key').setup()
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
require('project_nvim').setup({silent_chdir = false})

vim.fn.sign_define('Headline1', {linehl = 'Headline1'})
vim.fn.sign_define('Headline2', {linehl = 'Headline2'})
require('headlines').setup({
    rmd = {
        source_pattern_start = '^```{.*',
        source_pattern_end = '^```$',
        dash_pattern = '^---+$',
        headline_pattern = '^#+',
        headline_signs = {'Headline', 'Headline1', 'Headline2'},
        codeblock_sign = 'CodeBlock',
        dash_highlight = 'Dash'
    }
})

-- custom notification for square border
local stages_util = require('notify.stages.util')
require('notify').setup({
    timeout = 500,
    stages = {
        function(state)
            local next_height = state.message.height + 2
            local next_row = stages_util.available_row(state.open_windows,
                                                       next_height)
            if not next_row then return nil end
            return {
                relative = 'editor',
                anchor = 'NE',
                width = state.message.width,
                height = state.message.height,
                col = vim.opt.columns:get(),
                row = next_row,
                border = 'single',
                style = 'minimal',
                opacity = 0
            }
        end,
        function()
            return {opacity = {100}, col = {vim.opt.columns:get()}}
        end,
        function() return {col = {vim.opt.columns:get()}, time = true} end,
        function()
            return {
                opacity = {
                    0,
                    frequency = 2,
                    complete = function(cur_opacity)
                        return cur_opacity <= 4
                    end
                },
                col = {vim.opt.columns:get()}
            }
        end
    }

})
