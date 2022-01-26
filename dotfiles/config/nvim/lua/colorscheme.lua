local cmd = vim.cmd
local colors = require('colors')

cmd('hi FocusedSymbol guibg=' .. colors.fg_dark)
cmd('hi LspFloatWinBorder guifg=' .. colors.blue)
cmd('hi FloatBorder guibg=None guifg=' .. colors.blue)
cmd 'hi SagaShadow guibg=None'
-- cmd('hi Folded guibg=Nonegui=italic guifg=' .. colors.fg_dark)
cmd 'hi LspFloatWinNormal guibg=None'
cmd 'hi Headline guibg=#242232'
cmd 'hi Headline1 guibg=#1E2332'
cmd 'hi Headline2 guibg=#1E2332'
cmd 'hi NormalFloat guibg=None'

--[[ cmd 'hi HlSearchNear guibg=None guifg=#bb9af7 gui=underline'
cmd 'hi HlSearchFloat guibg=None guifg=#bb9af7 gui=underline'
cmd 'hi HlSearchLensNear guibg=None guifg=#bb9af7 gui=italic'
cmd 'hi HlSearchLens guibg=None guifg=#bb9af7 gui=underline'
cmd 'hi Search guibg=#15161E guifg=#bb9af7 gui=underline'
cmd 'hi IncSearch guibg=#15161E guifg=#bb9af7 gui=underline' ]]

--[[ cmd 'hi DiagnosticUnderlineError guibg=#2D202A guisp=#2D202A'
-- cmd 'hi! link DiagnosticUnderlineError DiagnosticVirtualTextError'
cmd 'hi! link DiagnosticUnderlineWarn DiagnosticVirtualTextWarning'
cmd 'hi! link DiagnosticUnderlineHint DiagnosticVirtualTextHint'
cmd 'hi! link DiagnosticUnderlineInfo DiagnosticVirtualTextInfo' ]]
