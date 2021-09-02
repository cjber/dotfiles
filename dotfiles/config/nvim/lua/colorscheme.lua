local cmd = vim.cmd
local colors = require('colors')

cmd('hi FocusedSymbol guibg=#414868')
cmd('hi LspFloatWinBorder guifg=' .. colors.blue)
cmd 'hi SagaShadow guibg=None'
cmd 'hi Folded guibg=None guifg=#414868 gui=italic'

