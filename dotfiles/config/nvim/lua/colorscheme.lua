local cmd = vim.cmd

cmd("highlight! StatusLineNC gui=underline guibg=NONE guifg=#3e4451")

-- normal stuff
cmd('hi Normal guibg=None')
cmd('hi Fg guibg=None guifg=#abb2bf')
cmd('hi LineNr guibg=None')
cmd('hi SignColumn guibg=None')
cmd('hi VertSplit guibg=None')
cmd('hi EndOfBuffer guibg=None')
cmd('hi StatusLine guibg=None')
cmd('hi ColorColumn guibg=#2b2d3a')

-- telescope
cmd('hi TelescopeBorder guifg=#2b2d3a')
cmd('hi TelescopePromptBorder guifg=#2b2d3a')
cmd('hi TelescopeResultsBorder guifg=#2b2d3a')
cmd('hi TelescopePreviewBorder guifg=#2b2d3a')

-- pmenu
cmd('hi! link PmenuSel Green')

-- gitdiff
cmd('hi! link DiffAdd Green')
cmd('hi! link DiffChange Grey')
cmd('hi! link DiffDelete Red')
cmd('hi! link DiffModified Cyan')

-- lang
cmd('hi! link TSConstructor Blue')
cmd('hi! link TSNumber Yellow')
cmd('hi! link TSInclude Purple')
cmd('hi! link GreenSign Green')
cmd('hi! link RedSign Red')
cmd('hi! link BlueSign Blue')
cmd('hi! link YellowSign Yellow')

-- hop
cmd('hi! link HopNextKey Green')
cmd('hi! link HopNextKey1 Yellow')
cmd('hi! link HopNextKey2 Red')

-- indentline
cmd('hi IndentBlanklineChar guifg=#2b2d3a gui=nocombine')

-- bqf
cmd('hi! link BqfPreviewBorder EndOfBuffer')
