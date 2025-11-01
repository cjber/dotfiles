require "nvchad.options"

-- Use vim.opt consistently for better type safety and modern API
local opt = vim.opt
local g = vim.g
local autocmd = vim.api.nvim_create_autocmd

-- Display options
opt.cursorlineopt = "both"
opt.colorcolumn = "88"
opt.conceallevel = 2
opt.concealcursor = ""
opt.cmdheight = 0
opt.pumheight = 10
opt.linebreak = true
opt.cursorline = true
opt.shortmess = "aoOstTWAIcqF"
opt.wildmode = "longest:full,full"
opt.complete = ".,w,b,u,t,i,kspell"

-- File handling
opt.undofile = true
opt.history = 10000
opt.undodir = vim.fn.stdpath "data" .. "/undo"
opt.swapfile = false
opt.writebackup = false

-- Folding (use opt instead of vim.wo for consistency)
opt.numberwidth = 4
opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
}
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Spelling
opt.spelllang = "en_gb"

-- Global variables
g.vscode_snippets_path = vim.fn.stdpath "config" .. "/snips"
g.loaded_python3_provider = nil
g.python3_host_prog = vim.fn.stdpath "config" .. "/.venv/bin/python3"
g.undotree_WindowLayout = 4

-- Autocmds (use callbacks for better performance and error handling)
autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove { "c", "r", "o" }
  end,
  desc = "Disable automatic comment continuation",
})

autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { timeout = 200 }
  end,
  desc = "Highlight yanked text",
})

autocmd("BufWritePost", {
  callback = function()
    require("lint").try_lint()
  end,
  desc = "Trigger linting on save",
})
