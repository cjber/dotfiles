local o = vim.o
local opt = vim.opt
local g = vim.g
local autocmd = vim.api.nvim_create_autocmd

-- General
o.mouse = "a"
o.clipboard = "unnamedplus"
o.termguicolors = true
o.showmode = false
o.laststatus = 3
o.cursorline = true
o.cursorlineopt = "both"
o.colorcolumn = "88"
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.updatetime = 250
o.autoread = true

-- Search
o.ignorecase = true
o.smartcase = true

-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

-- Display
opt.conceallevel = 2
opt.concealcursor = ""
opt.cmdheight = 0
opt.pumheight = 10
opt.linebreak = true
opt.shortmess = "aoOstTWAIcqF"
opt.wildmode = "longest:full,full"
opt.complete = ".,w,b,u,t,i,kspell"
opt.fillchars = {
  fold = " ",
  foldopen = "▼",
  foldclose = "▶",
  foldsep = " ",
  eob = " ",
}

-- Undo
opt.undofile = true
opt.history = 10000
opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undo"
opt.swapfile = false
opt.writebackup = false

-- Folds
opt.numberwidth = 4
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldtext = ""
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Spell
opt.spelllang = "en_gb"

-- Undotree layout
vim.cmd([[let g:undotree_WindowLayout = 4]])

-- Python
g.loaded_python3_provider = 1
g.python3_host_prog = vim.fn.stdpath("config") .. "/.venv/bin/python3"
g.vscode_snippets_path = vim.fn.stdpath("config") .. "/snips"

-- LSP
vim.lsp.enable({ "pyright", "ruff" })

-- Autocmds
autocmd("FileType", {
  pattern = "*",
  command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.hl.on_yank()
  end,
})

autocmd("BufWritePost", {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Auto-reload buffers when files change on disk (e.g. Claude Code edits)
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
  pattern = "*",
  command = "checktime",
})
