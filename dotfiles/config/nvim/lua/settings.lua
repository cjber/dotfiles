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
	"cursorline",
})

set_options({
	{ "scrolloff", 1 },
	{ "shortmess", "aoOstTWAIcqFS" },
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
	{ "cmdheight", 0 },
	{ "mouse", "a" },
	{ "colorcolumn", 89 },
	{ "laststatus", 0 },
	{ "spelllang", "en_gb" },
	{ "jumpoptions", "stack" },
	{ "listchars", "tab:»\\ ,trail:·" },
	{ "foldcolumn", "0" },
	{ "foldlevel", 99 },
	{ "foldlevelstart", 99 },
	-- { "foldmethod", "expr" },
	-- { "foldexpr", "nvim_treesitter#foldexpr()" },
})
