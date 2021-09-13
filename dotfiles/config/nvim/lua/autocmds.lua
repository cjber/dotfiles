local au = require('funcs.autocmd')

au.define_autocmds({
    FileType = {
        ['*'] = {
            -- don't insert comments
            'setlocal formatoptions-=c formatoptions-=r formatoptions-=o'
        }
    },
    TermOpen = {
        ['*'] = {
            -- automatically enter insert mode on new terminals
            'startinsert'
        }
    },
    TextYankPost = {['*'] = {[[lua vim.highlight.on_yank{}]]}},
    BufEnter = {
        -- auto close terminal if last window
        ['*'] = {[[if (winnr('$') == 1 && &buftype == 'terminal') | q | endif]]}
    },
    CursorHold = {
        ['*'] = {[[lua require'lspsaga.diagnostic'.show_cursor_diagnostics()]]}
    },
    CursorHoldI = {
        ['*'] = {[[lua require'lspsaga.signaturehelp'.signature_help()]]}
    }
})
