vim.g.doge_mapping = '' -- remove default mapping

local function set_keymap(mode, opts, keymaps)
    for _, keymap in ipairs(keymaps) do
        vim.api.nvim_set_keymap(mode, keymap[1], keymap[2], opts)
    end
end

-- normal
set_keymap('n', {noremap = true, silent = true}, {
    {'<CR>', ''},
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
    {'<C-p>', ':SymbolsOutline<CR>'},
    {'<M-j>', '<C-d>'},
    {'<M-k>', '<C-u>'},
    {'x', '"0x'}
    -- {'<CR>', [[:lua require("iron").core.send_line()<CR>)]]} -- cr breaks

})

-- visual
set_keymap('x', {noremap = true, silent = true}, {
    {'p', '""p:let @"=@0<CR>'},
    {'M', ':join<CR>'},
    {'J', '}'},
    {'K', '{'},
    {'<', '<gv'},
    {'>', '>gv'},
    {'<CR>', [[:lua require("iron").core.visual_send()<CR>)]]}
})

-- insert
set_keymap('i', {noremap = true, silent = true}, {})

-- terminal
set_keymap('t', {noremap = true, silent = true},
           {{'<Esc><Esc>', [[<C-\><C-n>]]}})

local wk = require('which-key')

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

wk.register({
    f = {
        name = '+find',
        f = {'<Cmd>Telescope find_files<CR>', 'files'},
        p = {'<Cmd>Telescope projects<CR>', 'projects'},
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
        f = {'mz[s1z=e`z', 'fix'},
        g = {':GrammarousCheck<CR>', 'grammarous'},
        r = {':GrammarousReset<CR>', 'kill grammarous'}
    },
    l = {
        name = '+lang',
        a = {'<Cmd>lua vim.lsp.buf.code_action()<CR>', 'code action'},
        c = {'<Cmd>lua vim.lsp.buf.rename()<CR>', 'rename'},
        d = {'<Cmd>lua vim.lsp.buf.definition()<CR>', 'definition'},
        e = {'<Cmd>:LspTroubleToggle lsp_document_diagnostics<CR>', 'errors'},
        q = {'<Cmd>:LspTroubleToggle quickfix<CR>', 'quickfix'},
        l = {'<Cmd>:LspTroubleToggle loclist<CR>', 'loclist'},
        f = {'<Cmd>lua vim.lsp.buf.formatting()<CR>', 'format'},
        g = {'<Cmd>DogeGenerate<CR>', 'generate documentation'},
        r = {'<Cmd>LspTroubleToggle lsp_references<CR>', 'references'},
        x = {'<Cmd>lua vim.lsp.diagnostic.disable()<CR>', 'disable lsp'},
        z = {':LspRestart<CR>', 'restart lsp'}
    },
    b = {
        name = '+buffers',
        o = {'<Cmd>%bdelete|edit #|normal `"<CR>', 'del other buffers'}
    },
    t = {
        name = '+todo',
        l = {'<Cmd>:TodoTelescope<CR>', 'todo telescope'},
        t = {'<Cmd>:TodoTrouble<CR>', 'todo trouble'}
    },
    z = {
        name = '+term',
        z = {'<Cmd>lua require("FTerm").toggle()<CR>', 'open term'}
    },
    m = {name = '+mode', z = {'<Cmd>ZenMode<CR>', 'zen'}},
    d = {
        name = '+debug',
        d = {'<Cmd>lua require("dapui").toggle()<CR>', 'ui'},
        n = {'<Cmd>lua require("dap").step_over()<CR>', 'step'},
        f = {'<Cmd>lua require("dap").continue()<CR>', 'continue'},
        j = {'<Cmd>lua require("dap").toggle_breakpoint()<CR>', 'breakpoint'}
    }
}, {prefix = '<leader>'})

wk.register({
    a = {[[:lua require("iron").core.send_line()<CR>)]], 'line'},
    s = {
        name = '+iron',
        s = {[[<Cmd>:IronRepl<CR><ESC>]], 'open'},
        q = {[[<Cmd>:IronRestart<CR><ESC>]], 'restart'},
        f = {
            [[:TSTextobjectSelect @function.outer<CR>:lua require("iron").core.visual_send()<CR>]],
            'function'
        },
        l = {
            [[:TSTextobjectSelect @class.outer<CR>:lua require("iron").core.visual_send()<CR>]],
            'class'
        },
        d = {[[vip:lua require("iron").core.visual_send()<CR>})]], 'paragraph'},
        a = {
            [[Vgg:lua require("iron").core.visual_send()<CR><C-o>]],
            'paragraph'
        }
    }
}, {prefix = '<localleader>'})
