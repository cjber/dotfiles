local au = require('funcs.autocmd')
local border = {
    {'┌', 'FloatBorder'},
    {'─', 'FloatBorder'},
    {'┐', 'FloatBorder'},
    {'│', 'FloatBorder'},
    {'┘', 'FloatBorder'},
    {'─', 'FloatBorder'},
    {'└', 'FloatBorder'},
    {'│', 'FloatBorder'}
}

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
        ['*'] = {
            'lua vim.diagnostic.open_float({border =' ..
                vim.inspect(border) .. ', focusable=false, show_header=false, scope="cursor"})'
        }
    }
})
