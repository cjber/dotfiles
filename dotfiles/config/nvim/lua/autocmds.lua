local au = require('funcs.autocmds')

au.define_autocmds({
    FileType = {
        ['*'] = {
            -- don't insert comments
            'setlocal formatoptions-=c formatoptions-=r formatoptions-=o'
        },
        ['todo'] = {'setlocal omnifunc=todo#Complete'}
    },
    TermOpen = {
        ['*'] = {
            -- automatically enter insert mode on new terminals
            'startinsert'
        }
    },
    BufReadPost = {
        ['*'] = {
            -- return to last edit position when opening files
            [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]]
        }
    },
    TextYankPost = {['*'] = {[[lua vim.highlight.on_yank{}]]}},
    BufEnter = {
        -- auto close terminal if last window
        ['*'] = {[[if (winnr('$') == 1 && &buftype == 'terminal') | q | endif]]}
    }
})
