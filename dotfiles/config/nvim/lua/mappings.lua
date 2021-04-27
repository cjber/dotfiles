vim.g.which_key_fallback_to_native_key = 1
vim.g.which_key_display_names = {['<CR>'] = '↵', ['<TAB>'] = '⇆'}
vim.g.which_key_sep = '→'
vim.g.which_key_timeout = 100
vim.g.doge_mapping = '' -- remove default mapping

local function set_keymap(mode, opts, keymaps)
    for _, keymap in ipairs(keymaps) do
        vim.api.nvim_set_keymap(mode, keymap[1], keymap[2], opts)
    end
end

-- normal
set_keymap('n', {noremap = true, silent = true}, {
    {' ', ''},
    {',', ''},
    {'q:', ':q'},
    {'Q', '<Nop>'},
    {'M', ':join<CR>'},
    {'n', 'nzzzv'},
    {'N', 'Nzzzv'},
    {'J', '}'},
    {'K', '{'},
    {'H', '^'},
    {'L', '$'},
    {'U', '<C-r>'},
    {'Y', 'y$'},
    {'j', 'gj'},
    {'k', 'gk'},
    {'[j', '<C-o>'},
    {']j', '<C-i>'},
    {'<C-h>', '<C-w>h'},
    {'<C-j>', '<C-w>j'},
    {'<C-k>', '<C-w>k'},
    {'<C-l>', '<C-w>l'},
    {'[d', '<PageUp>'},
    {']d', '<PageDown>'},
    {'<Up>', ':resize +2<CR>'},
    {'<Down>', ':resize -2<CR>'},
    {'<Left>', ':vertical resize +2<CR>'},
    {'<Right>', ':vertical resize -2<CR>'},
    {'<C-Space>', ':bnext<CR>'},
    {'<ESC><ESC>', ':noh<CR><ESC>'},
    {'<C-n>', ':NvimTreeToggle<CR>'},
    {'<C-m>', ':SymbolsOutline<CR>'},
    {'[e', ':Lspsaga diagnostic_jump_prev<CR>'},
    {']e', ':Lspsaga diagnostic_jump_next<CR>'}
})

-- visual
set_keymap('x', {noremap = true, silent = true}, {
    {'p', '""p:let @"=@0<CR>'},
    {'M', ':join<CR>'},
    {'J', '}'},
    {'K', '{'},
    {'<', '<gv'},
    {'>', '>gv'}
})

-- insert
set_keymap('i', {noremap = true, silent = true}, {})

-- terminal
set_keymap('t', {noremap = true, silent = true},
           {{'<Esc><Esc>', [[<C-\><C-n>]]}})

local wk = require('whichkey_setup')

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local keymap = {
    f = {
        name = '+find',
        f = {'<Cmd>Telescope find_files', 'files'},
        b = {'<Cmd>Telescope buffers show_all_buffers=true<CR>', 'buffers'},
        h = {'<Cmd>Telescope help_tags<CR>', 'help tags'},
        o = {'<Cmd>Telescope oldfiles<CR>', 'old files'},
        r = {'<Cmd>Telescope live_grep<CR>', 'live grep'},
        u = {'<Cmd>MundoToggle<CR>', 'undotree'},
        c = {
            name = '+commands',
            c = {'<Cmd>Telescope commands<CR>', 'commands'},
            h = {'<Cmd>Telescope command_history<CR>', 'history'}
        },
        q = {'<Cmd>Telescope quickfix<CR>', 'quickfix'},
        g = {
            name = '+git',
            g = {'<Cmd>Telescope git_commits<CR>', 'commits'},
            c = {'<Cmd>Telescope git_bcommits<CR>', 'bcommits'},
            b = {'<Cmd>Telescope git_branches<CR>', 'branches'},
            s = {'<Cmd>Telescope git_status<CR>', 'status'}
        },
        z = {'<Cmd>Telescope z list<CR>', 'list z'}
    },
    w = {
        name = '+window',
        r = {'<Cmd>wincmd H<CR>', 'vertical'},
        e = {'<Cmd>wincmd J<CR>', 'horizontal'}
    },
    s = {
        name = '+spell',
        s = {'<Cmd>set invspell<CR>', 'toggle'},
        f = {'mz[s1z=e`z', 'fix'}
    },
    l = {
        name = '+lang',
        a = {'<Cmd>lua require("lspsaga.codeaction").code_action()<CR>'},
        c = {'<Cmd>lua vim.lsp.buf.rename()<CR>', 'rename'},
        d = {'<Cmd>lua vim.lsp.buf.definition()<CR>', 'definition'},
        e = {'<Cmd>:LspTroubleToggle<CR>', 'errors'},
        f = {'<Cmd>lua vim.lsp.buf.formatting()<CR>', 'format'},
        g = {'<Cmd>DogeGenerate<CR>', 'generate documentation'},
        h = {'<Cmd>lua require("lspsaga.signaturehelp").signature_help()<CR>'},
        k = {
            '<Cmd>lua require("lspsaga.hover").render_hover_doc()<CR>',
            'hover'
        },
        r = {'<Cmd>lua vim.lsp.buf.references()<CR>', 'references'},
        z = {':LspRestart<CR>', 'restart lsp'}
    },
    b = {
        name = '+buffers',
        o = {'<Cmd>%bdelete|edit #|normal `"<CR>', 'del others'}
    },
    z = {
        name = '+term',
        z = {'<Cmd>lua require("lspsaga.floaterm").open_float_terminal()<CR>'},
        l = {
            '<Cmd>lua require("lspsaga.floaterm").open_float_terminal("lazygit")<CR>'
        },
        x = {'<Cmd>lua require("lspsaga.floaterm").close_float_terminal()<CR>'}
    }
}

wk.register_keymap('leader', keymap)

local local_keymap = {['<Space>'] = {'', 'temp'}}
wk.register_keymap('localleader', local_keymap)
