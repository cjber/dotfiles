require "nvchad.options"
local o = vim.o
local autocmd = vim.api.nvim_create_autocmd
local opt = vim.opt
local g = vim.g

o.cursorlineopt = "both"
o.colorcolumn = "80"

vim.cmd [[let g:undotree_WindowLayout = 4]]

-- autocmds
autocmd("FileType", { pattern = "*", command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o" })
autocmd("TextYankPost", { pattern = "*", command = "lua vim.highlight.on_yank{}" })
autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

g.vscode_snippets_path = vim.fn.stdpath "config" .. "/snips"
g.loaded_python3_provider = nil
g.python3_host_prog = vim.fn.stdpath "config" .. ".venv/bin/python3"

-- options
opt.conceallevel = 2
opt.concealcursor = ""
opt.cmdheight = 0
opt.pumheight = 10
opt.linebreak = true
opt.cursorline = true
-- opt.signcolumn = "number"
opt.shortmess = "aoOstTWAIcqF"
opt.wildmode = "longest:full,full"
opt.complete = ".,w,b,u,t,i,kspell"

-- undo
opt.undofile = true
opt.history = 10000
opt.undodir = os.getenv "HOME" .. "/.local/share/nvim/undo"
opt.swapfile = false
opt.undofile = true
opt.writebackup = false

-- folds
opt.numberwidth = 4
opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ", -- or "│" to use bar for show fold area
}
opt.foldcolumn = "1"
-- opt.foldnestmax = 2
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldtext = ""
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- spell
opt.spelllang = "en_gb"
