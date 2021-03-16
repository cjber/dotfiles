local cmd = vim.cmd
local g = vim.g

-- normal stuff
cmd("hi Normal guibg=None")
cmd("hi Fg guibg=None guifg=#abb2bf")
cmd("hi LineNr guibg=None")
cmd("hi SignColumn guibg=None")
cmd("hi VertSplit guibg=None")
cmd("hi EndOfBuffer guibg=None")
cmd("hi StatusLine guibg=None")

-- telescope
cmd("hi TelescopeBorder guifg=#7f8490")
cmd("hi TelescopePromptBorder guifg=#7f8490")
cmd("hi TelescopeResultsBorder guifg=#7f8490")
cmd("hi TelescopePreviewBorder guifg=#7f8490")

-- pmenu
cmd("hi! link PmenuSel Green")

-- gitdiff
cmd("hi! link DiffAdd Green")
cmd("hi! link DiffChange Grey")
cmd("hi! link DiffDelete Red")
cmd("hi! link DiffModified Cyan")

-- lang
cmd("hi! link TSConstructor Blue")
cmd("hi! link TSNumber Yellow")
cmd("hi! link TSInclude Purple")
cmd("hi! link GreenSign Green")
cmd("hi! link RedSign Red")

-- hop
cmd("hi! link HopNextKey Green")
cmd("hi! link HopNextKey1 Yellow")
cmd("hi! link HopNextKey2 Red")

-- indentline
g.indent_blankline_char_highlight = 'EndOfBuffer'
