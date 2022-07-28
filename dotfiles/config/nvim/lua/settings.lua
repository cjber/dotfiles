local function enable_options(options)
    for _, option in ipairs(options) do
        vim.cmd("set " .. option)
    end
end

local function set_options(options)
    for _, option in ipairs(options) do
        vim.cmd("set " .. option[1] .. "=" .. option[2])
    end
end

vim.cmd("filetype plugin on")
vim.cmd("set formatoptions-=cro")
vim.o.shell = "/bin/zsh"

enable_options({
    "expandtab",
    "autoindent",
    "smartindent",
    "smarttab",
    "termguicolors",
    "wildmenu",
    "list",
    "nu",
    "rnu",
    "splitright",
    "splitbelow",
    "autowrite",
    "ignorecase",
    "smartcase",
    "incsearch",
    "undofile",
    "linebreak",
    "nobackup",
    "noswapfile",
    "nowritebackup",
    "noruler",
    "cursorline"
    -- 'nofoldenable'
})

set_options({
    { "scrolloff", 1 },
    { "shortmess", "aoOstTWAIcqFS" },
    { "sidescrolloff", 5 },
    { "complete", ".,w,b,u,t,i,kspell" },
    { "completeopt", "menu,menuone,noselect" },
    { "wildmode", "longest:full,full" },
    { "tabstop", 4 },
    { "shiftwidth", 4 },
    { "softtabstop", 4 },
    { "grepprg", [[rg\ --vimgrep\ --smart-case\ --follow]] },
    { "timeoutlen", 500 },
    { "updatetime", 250 },
    { "history", 10000 },
    { "signcolumn", "number" },
    { "undolevels", 1000 },
    { "undodir", "~/.local/share/undo" },
    { "showbreak", "¦" },
    { "conceallevel", 2 },
    { "concealcursor", "" },
    { "clipboard", "unnamedplus" },
    { "pumheight", 10 },
    { "cmdheight", 1 },
    { "mouse", "a" },
    { "colorcolumn", 89 },
    { "laststatus", 3 },
    { "spelllang", "en_gb" },
    { "jumpoptions", "stack" },
    { "listchars", "tab:»\\ ,trail:·" },
    -- { "foldcolumn", "1" },
    -- { "foldmethod", "expr" },
    -- { "foldexpr", "nvim_treesitter#foldexpr()" },
    -- { "foldnestmax", 2 },
    -- { "foldminlines", 1 },
    -- { "foldlevelstart", 99 },
})

vim.o.foldcolumn = "1"
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = -1
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
