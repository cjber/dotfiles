-- Oxide: A dark colorscheme with orange, teal, and peach accents
vim.cmd("hi clear")
vim.g.colors_name = "oxide"
vim.o.termguicolors = true
vim.o.background = "dark"

local p = {
  bg = "#121113",
  bg_dark = "#0a0a0a",
  bg1 = "#1a1a1c",
  bg2 = "#222222",
  bg3 = "#2a2a2a",
  bg4 = "#333333",
  fg = "#b0b0b0",
  fg_bright = "#d0d0d0",
  fg_dim = "#777777",
  comment = "#555555",
  orange = "#e78a53",
  orange_dim = "#d77a43",
  teal = "#5f8787",
  teal_bright = "#6f9797",
  peach = "#fbcb97",
  muted = "#999999",
  red = "#c75a5a",
  green = "#6a9955",
  none = "NONE",
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor
hl("Normal", { fg = p.fg, bg = p.bg })
hl("NormalFloat", { fg = p.fg, bg = p.bg1 })
hl("FloatBorder", { fg = p.bg4, bg = p.bg1 })
hl("FloatTitle", { fg = p.orange, bg = p.bg1, bold = true })
hl("Cursor", { fg = p.bg, bg = p.fg })
hl("CursorLine", { bg = p.bg1 })
hl("CursorLineNr", { fg = p.orange, bold = true })
hl("LineNr", { fg = p.bg4 })
hl("SignColumn", { bg = p.bg })
hl("FoldColumn", { fg = p.orange_dim, bg = p.bg })
hl("Folded", { fg = p.comment, bg = p.bg1 })
hl("ColorColumn", { bg = p.bg1 })
hl("VertSplit", { fg = p.bg2 })
hl("WinSeparator", { fg = p.bg2 })
hl("StatusLine", { fg = p.fg, bg = p.bg })
hl("StatusLineNC", { fg = p.comment, bg = p.bg })
hl("TabLine", { fg = p.comment, bg = p.bg1 })
hl("TabLineFill", { bg = p.bg_dark })
hl("TabLineSel", { fg = p.fg_bright, bg = p.bg })
hl("WinBar", { fg = p.fg, bg = p.bg })
hl("WinBarNC", { fg = p.comment, bg = p.bg })
hl("Visual", { bg = p.bg3 })
hl("VisualNOS", { bg = p.bg3 })
hl("Search", { fg = p.bg, bg = p.peach })
hl("IncSearch", { fg = p.bg, bg = p.orange })
hl("CurSearch", { fg = p.bg, bg = p.orange })
hl("Substitute", { fg = p.bg, bg = p.orange })
hl("MatchParen", { fg = p.peach, bold = true, underline = true })
hl("Pmenu", { fg = p.fg, bg = p.bg1 })
hl("PmenuSel", { fg = p.fg_bright, bg = p.bg3 })
hl("PmenuSbar", { bg = p.bg2 })
hl("PmenuThumb", { bg = p.bg4 })
hl("WildMenu", { fg = p.bg, bg = p.orange })
hl("Directory", { fg = p.teal })
hl("Title", { fg = p.orange, bold = true })
hl("ErrorMsg", { fg = p.red })
hl("WarningMsg", { fg = p.peach })
hl("ModeMsg", { fg = p.fg_dim })
hl("MoreMsg", { fg = p.teal })
hl("Question", { fg = p.teal })
hl("NonText", { fg = p.bg4 })
hl("SpecialKey", { fg = p.bg4 })
hl("Conceal", { fg = p.comment })
hl("Whitespace", { fg = p.bg3 })
hl("EndOfBuffer", { fg = p.bg })
hl("SpellBad", { undercurl = true, sp = p.red })
hl("SpellCap", { undercurl = true, sp = p.peach })
hl("SpellLocal", { undercurl = true, sp = p.teal })
hl("SpellRare", { undercurl = true, sp = p.muted })

-- Syntax
hl("Comment", { fg = p.comment, italic = true })
hl("Constant", { fg = p.orange })
hl("String", { fg = p.teal })
hl("Character", { fg = p.teal })
hl("Number", { fg = p.orange })
hl("Boolean", { fg = p.orange })
hl("Float", { fg = p.orange })
hl("Identifier", { fg = p.fg })
hl("Function", { fg = p.teal_bright })
hl("Statement", { fg = p.orange })
hl("Conditional", { fg = p.orange })
hl("Repeat", { fg = p.orange })
hl("Label", { fg = p.peach })
hl("Operator", { fg = p.muted })
hl("Keyword", { fg = p.orange })
hl("Exception", { fg = p.orange })
hl("PreProc", { fg = p.peach })
hl("Include", { fg = p.orange })
hl("Define", { fg = p.orange })
hl("Macro", { fg = p.peach })
hl("PreCondit", { fg = p.peach })
hl("Type", { fg = p.peach })
hl("StorageClass", { fg = p.orange })
hl("Structure", { fg = p.peach })
hl("Typedef", { fg = p.peach })
hl("Special", { fg = p.peach })
hl("SpecialChar", { fg = p.peach })
hl("Tag", { fg = p.teal })
hl("Delimiter", { fg = p.muted })
hl("SpecialComment", { fg = p.comment, italic = true })
hl("Debug", { fg = p.orange })
hl("Underlined", { underline = true })
hl("Error", { fg = p.red })
hl("Todo", { fg = p.bg, bg = p.orange, bold = true })
hl("Added", { fg = p.green })
hl("Changed", { fg = p.peach })
hl("Removed", { fg = p.red })

-- Treesitter
hl("@variable", { fg = p.fg })
hl("@variable.builtin", { fg = p.orange })
hl("@variable.parameter", { fg = p.fg_bright })
hl("@variable.member", { fg = p.fg })
hl("@constant", { fg = p.orange })
hl("@constant.builtin", { fg = p.orange })
hl("@module", { fg = p.muted })
hl("@string", { fg = p.teal })
hl("@string.escape", { fg = p.teal_bright })
hl("@string.regexp", { fg = p.teal_bright })
hl("@character", { fg = p.teal })
hl("@number", { fg = p.orange })
hl("@boolean", { fg = p.orange })
hl("@float", { fg = p.orange })
hl("@function", { fg = p.teal_bright })
hl("@function.builtin", { fg = p.teal })
hl("@function.method", { fg = p.teal_bright })
hl("@function.macro", { fg = p.peach })
hl("@constructor", { fg = p.peach })
hl("@keyword", { fg = p.orange })
hl("@keyword.function", { fg = p.orange })
hl("@keyword.return", { fg = p.orange })
hl("@keyword.operator", { fg = p.orange })
hl("@keyword.import", { fg = p.orange })
hl("@operator", { fg = p.muted })
hl("@punctuation.bracket", { fg = p.muted })
hl("@punctuation.delimiter", { fg = p.muted })
hl("@punctuation.special", { fg = p.peach })
hl("@type", { fg = p.peach })
hl("@type.builtin", { fg = p.peach })
hl("@type.qualifier", { fg = p.orange })
hl("@tag", { fg = p.teal })
hl("@tag.attribute", { fg = p.peach })
hl("@tag.delimiter", { fg = p.muted })
hl("@attribute", { fg = p.peach })
hl("@property", { fg = p.fg })
hl("@comment", { fg = p.comment, italic = true })
hl("@markup.heading", { fg = p.orange, bold = true })
hl("@markup.link", { fg = p.teal, underline = true })
hl("@markup.link.url", { fg = p.teal, underline = true })
hl("@markup.raw", { fg = p.teal })
hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.list", { fg = p.orange })

-- LSP Semantic Tokens
hl("@lsp.type.class", { fg = p.peach })
hl("@lsp.type.decorator", { fg = p.peach })
hl("@lsp.type.enum", { fg = p.peach })
hl("@lsp.type.enumMember", { fg = p.orange })
hl("@lsp.type.function", { fg = p.teal_bright })
hl("@lsp.type.interface", { fg = p.peach })
hl("@lsp.type.method", { fg = p.teal_bright })
hl("@lsp.type.namespace", { fg = p.muted })
hl("@lsp.type.parameter", { fg = p.fg_bright })
hl("@lsp.type.property", { fg = p.fg })
hl("@lsp.type.struct", { fg = p.peach })
hl("@lsp.type.type", { fg = p.peach })
hl("@lsp.type.variable", { fg = p.fg })

-- Diagnostics
hl("DiagnosticError", { fg = p.red })
hl("DiagnosticWarn", { fg = p.peach })
hl("DiagnosticInfo", { fg = p.teal })
hl("DiagnosticHint", { fg = p.muted })
hl("DiagnosticOk", { fg = p.green })
hl("DiagnosticUnderlineError", { undercurl = true, sp = p.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = p.peach })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = p.teal })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = p.muted })
hl("DiagnosticVirtualTextError", { fg = p.red, bg = p.bg1 })
hl("DiagnosticVirtualTextWarn", { fg = p.peach, bg = p.bg1 })
hl("DiagnosticVirtualTextInfo", { fg = p.teal, bg = p.bg1 })
hl("DiagnosticVirtualTextHint", { fg = p.muted, bg = p.bg1 })
hl("DiagnosticSignError", { fg = p.red })
hl("DiagnosticSignWarn", { fg = p.peach })
hl("DiagnosticSignInfo", { fg = p.teal })
hl("DiagnosticSignHint", { fg = p.muted })

-- Git signs
hl("GitSignsAdd", { fg = p.green })
hl("GitSignsChange", { fg = p.peach })
hl("GitSignsDelete", { fg = p.red })
hl("DiffAdd", { bg = "#1a2a1a" })
hl("DiffChange", { bg = "#2a2a1a" })
hl("DiffDelete", { bg = "#2a1a1a" })
hl("DiffText", { bg = "#3a3a1a" })

-- Completion (blink.cmp)
hl("BlinkCmpMenu", { fg = p.fg, bg = p.bg1 })
hl("BlinkCmpMenuBorder", { fg = p.bg4, bg = p.bg1 })
hl("BlinkCmpMenuSelection", { bg = p.bg3 })
hl("BlinkCmpLabel", { fg = p.fg })
hl("BlinkCmpLabelMatch", { fg = p.orange, bold = true })
hl("BlinkCmpKind", { fg = p.teal })
hl("BlinkCmpDoc", { fg = p.fg, bg = p.bg1 })
hl("BlinkCmpDocBorder", { fg = p.bg4, bg = p.bg1 })

-- Telescope/Picker fallback
hl("TelescopeNormal", { fg = p.fg, bg = p.bg1 })
hl("TelescopeBorder", { fg = p.bg4, bg = p.bg1 })
hl("TelescopeSelection", { bg = p.bg3 })
hl("TelescopeMatching", { fg = p.orange, bold = true })
hl("TelescopePromptPrefix", { fg = p.orange })

-- Snacks
hl("SnacksPickerMatch", { fg = p.orange, bold = true })
hl("SnacksPickerBorder", { fg = p.bg, bg = p.bg })
hl("SnacksPickerInput", { fg = p.fg, bg = p.bg })
hl("SnacksPickerInputBorder", { fg = p.bg, bg = p.bg })
hl("SnacksPickerList", { fg = p.fg, bg = p.bg })
hl("SnacksPickerListBorder", { fg = p.bg, bg = p.bg })
hl("SnacksPickerPreview", { fg = p.fg, bg = p.bg })
hl("SnacksPickerPreviewBorder", { fg = p.bg, bg = p.bg })
hl("SnacksIndent", { fg = p.bg2 })
hl("SnacksIndentScope", { fg = p.bg4 })
hl("SnacksNotifierInfo", { fg = p.teal })
hl("SnacksNotifierWarn", { fg = p.peach })
hl("SnacksNotifierError", { fg = p.red })

-- Trouble
hl("TroubleNormal", { fg = p.fg, bg = p.bg })
hl("TroubleText", { fg = p.fg })
hl("TroubleCount", { fg = p.orange, bg = p.bg2 })

-- Which-key
hl("WhichKey", { fg = p.orange })
hl("WhichKeyGroup", { fg = p.teal })
hl("WhichKeyDesc", { fg = p.fg })
hl("WhichKeySeparator", { fg = p.comment })
hl("WhichKeyValue", { fg = p.muted })

-- Indent
hl("IblIndent", { fg = p.bg2 })
hl("IblScope", { fg = p.bg4 })

-- Notify/Noice
hl("NotifyINFOBody", { fg = p.fg })
hl("NotifyINFOTitle", { fg = p.teal })
hl("NotifyINFOIcon", { fg = p.teal })
hl("NotifyWARNBody", { fg = p.fg })
hl("NotifyWARNTitle", { fg = p.peach })
hl("NotifyWARNIcon", { fg = p.peach })
hl("NotifyERRORBody", { fg = p.fg })
hl("NotifyERRORTitle", { fg = p.red })
hl("NotifyERRORIcon", { fg = p.red })

-- Neogit
hl("NeogitDiffAdd", { fg = p.green, bg = "#1a2a1a" })
hl("NeogitDiffDelete", { fg = p.red, bg = "#2a1a1a" })
hl("NeogitHunkHeader", { fg = p.teal, bg = p.bg2 })
hl("NeogitBranch", { fg = p.orange, bold = true })
hl("NeogitRemote", { fg = p.teal })

-- Mini (for any mini.nvim usage)
hl("MiniPickMatch", { fg = p.orange, bold = true })

-- Hop
hl("HopNextKey", { fg = p.orange, bold = true })
hl("HopNextKey1", { fg = p.teal, bold = true })
hl("HopNextKey2", { fg = p.teal_bright })
hl("HopUnmatched", { fg = p.bg4 })

-- Lualine theme (exported for lualine)
vim.g.oxide_lualine = {
  normal = {
    a = { fg = p.bg, bg = p.orange, gui = "bold" },
    b = { fg = p.fg, bg = p.bg },
    c = { fg = p.fg_dim, bg = p.bg },
  },
  insert = {
    a = { fg = p.bg, bg = p.teal, gui = "bold" },
  },
  visual = {
    a = { fg = p.bg, bg = p.peach, gui = "bold" },
  },
  replace = {
    a = { fg = p.bg, bg = p.red, gui = "bold" },
  },
  command = {
    a = { fg = p.bg, bg = p.muted, gui = "bold" },
  },
  inactive = {
    a = { fg = p.comment, bg = p.bg },
    b = { fg = p.comment, bg = p.bg },
    c = { fg = p.comment, bg = p.bg },
  },
}
