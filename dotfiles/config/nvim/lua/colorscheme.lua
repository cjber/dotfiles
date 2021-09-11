local cmd = vim.cmd
local colors = require('colors')

cmd('hi FocusedSymbol guibg=' .. colors.fg_dark)
cmd('hi LspFloatWinBorder guifg=' .. colors.blue)
cmd 'hi SagaShadow guibg=None'
cmd('hi Folded guibg=Nonegui=italic guifg=' .. colors.fg_dark)
cmd 'hi LspFloatWinNormal guibg=None'
cmd 'hi Headline guibg=#242232'
cmd 'hi Headline1 guibg=#1E2332'
cmd 'hi Headline2 guibg=#1E2332'
