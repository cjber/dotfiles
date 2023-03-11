local function set_keymap(mode, opts, keymaps)
	for _, keymap in ipairs(keymaps) do
		vim.api.nvim_set_keymap(mode, keymap[1], keymap[2], opts)
	end
end

-- normal
set_keymap("n", { noremap = true, silent = true }, {
	{ "<CR>", "" },
	{ "q:", ":q" },
	{ "Q", "<Nop>" },
	{ "M", ":join<CR>" },
	{ "n", "nzzzv" },
	{ "N", "Nzzzv" },
	{ "J", "}" },
	{ "K", "{" },
	{ "H", "^" },
	{ "L", "$" },
	{ "U", "<C-r>" },
	{ "Y", "y$" },
	{ "j", "gj" },
	{ "k", "gk" },
	{ "[j", "<C-o>" },
	{ "]j", "<C-i>" },
	{ "<C-h>", "<C-w>h" },
	{ "<C-j>", "<C-w>j" },
	{ "<C-k>", "<C-w>k" },
	{ "<C-l>", "<C-w>l" },
	{ "[d", "<PageUp>" },
	{ "]d", "<PageDown>" },
	{ "<Up>", ":resize +2<CR>" },
	{ "<Down>", ":resize -2<CR>" },
	{ "<Left>", ":vertical resize +2<CR>" },
	{ "<Right>", ":vertical resize -2<CR>" },
	{ "<C-Space>", ":bnext<CR>" },
	{ "<ESC><ESC>", ":noh<CR><ESC>" },
	{ "<C-n>", ":NvimTreeToggle<CR>" },
	{ "<C-p>", ":SymbolsOutline<CR>" },
	-- { "<M-j>", "<C-d>" },
	-- { "<M-k>", "<C-u>" },
	{ "x", '"0x' },
	-- { "<C-d>", ":lua vim.lsp.buf.hover()<CR>" },
	{ "zR", ":lua require('ufo').openAllFolds()<CR>" },
	{ "zM", ":lua require('ufo').closeAllFolds()<CR>" },
})

-- visual
set_keymap("x", { noremap = true, silent = true }, {
	{ "p", '""p:let @"=@0<CR>' },
	{ "M", ":join<CR>" },
	{ "J", "}" },
	{ "K", "{" },
	{ "<", "<gv" },
	{ ">", ">gv" },
	{ "<CR>", [[:]] },
})

-- terminal
set_keymap("t", { noremap = true, silent = true }, { { "<Esc><Esc>", [[<C-\><C-n>]] } })

local wk = require("which-key")

vim.g.mapleader = " "
vim.g.maplocalleader = ","

wk.register({
	f = {
		name = "+find",
		f = { [[<CMD>Telescope find_files<CR>]], "files" },
		l = { "<Cmd>NvimTreeToggle<CR>", "files" },
		p = { "<Cmd>Telescope projects<CR>", "projects" },
		j = { "<Cmd>Telescope buffers<CR>", "buffers" },
		h = { "<Cmd>Telescope help_tags<CR>", "help tags" },
		o = { "<Cmd>Telescope oldfiles<CR>", "old files" },
		r = { "<Cmd>Telescope live_grep<CR>", "live grep" },
		u = { "<Cmd>UndotreeToggle<CR>", "undotree" },
		c = {
			name = "+commands",
			c = { "<Cmd>Telescope commands<CR>", "commands" },
			h = { "<Cmd>Telescope command_history<CR>", "history" },
		},
		q = { "<Cmd>Telescope quickfix<CR>", "quickfix" },
		g = {
			name = "+git",
			g = { "<Cmd>Telescope git_commits<CR>", "commits" },
			c = { "<Cmd>Telescope git_bcommits<CR>", "bcommits" },
			b = { "<Cmd>Telescope git_branches<CR>", "branches" },
			s = { "<Cmd>Telescope git_status<CR>", "status" },
		},
		z = { "<Cmd>Telescope z list<CR>", "list z" },
	},
	w = {
		name = "+window",
		r = { "<Cmd>wincmd H<CR>", "vertical" },
		e = { "<Cmd>wincmd J<CR>", "horizontal" },
	},
	s = {
		name = "+spell",
		s = { "<Cmd>set invspell<CR>", "toggle" },
		-- f = { "ma[s1z=`a", "fix" },
		f = { "ma[s1z=`a", "fix" },
		-- g = { ":GrammarousCheck<CR>", "grammarous" },
		-- r = { ":GrammarousReset<CR>", "kill grammarous" },
	},
	l = {
		name = "+lang",
		a = { "<Cmd>lua vim.lsp.buf.code_action()<CR>", "code action" },
		c = { "<Cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
		d = { "<Cmd>lua vim.lsp.buf.definition()<CR>", "definition" },
		e = { "<Cmd>:TroubleToggle document_diagnostics<CR>", "errors" },
		q = { "<Cmd>:TroubleToggle quickfix<CR>", "quickfix" },
		l = { "<Cmd>:TroubleToggle loclist<CR>", "loclist" },
		f = { "<Cmd>lua vim.lsp.buf.format{async=true}<CR>", "format" },
		g = { "<Cmd>:Neogen<CR>", "generate documentation" },
		r = { "<Cmd>TroubleToggle lsp_references<CR>", "references" },
		x = { "<Cmd>lua vim.diagnostic.hide()<CR>", "hide diagnostics" },
		s = { "<Cmd>lua vim.diagnostic.show()<CR>", "show diagnostics" },
		z = { ":LspRestart<CR>", "restart lsp" },
	},
	b = {
		name = "+buffers",
		o = { '<Cmd>lua require("close_buffers").delete({type = "other"})<CR>', "del other buffers" },
	},
	t = {
		name = "+todo",
		l = { "<Cmd>:TodoTelescope<CR>", "todo telescope" },
		t = { "<Cmd>:TodoTrouble<CR>", "todo trouble" },
	},
	z = {
		name = "+term",
		z = { '<Cmd>lua require("FTerm").toggle()<CR>', "open term" },
	},
	m = { name = "+mode", z = { "<Cmd>ZenMode<CR>", "zen" } },
	d = {
		name = "+debug",
		d = { '<Cmd>lua require("neotest").run.run({strategy="dap"})<CR>', "dap" },
		f = { '<Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', "file" },
	},
	r = {
		name = "+rotate",
		r = { "<Cmd>windo wincmd H<CR>", "horizontal" },
		e = { "<Cmd>windo wincmd K<CR>", "vertical" },
	},
	c = {
		name = "+open",
		c = { "<Cmd>Copen<CR>", "copen" },
		d = { "<Cmd>on<CR>", "close" },
	},
	p = { "<Cmd>Lazy<CR>", "plugins" },
}, { prefix = "<leader>" })

-- wk.register({
-- 	s = {
-- 		name = "+repl",
-- 		s = { [[<Cmd>IronRepl<CR><ESC>]], "start repl" },
-- 		q = { [[<Cmd>IronHide<CR>]], "stop repl" },
-- 	},
-- }, { prefix = "<localleader>" })

vim.cmd([[
" vimcmdline mappings
 let cmdline_map_start          = '<LocalLeader>ss'
 let cmdline_map_send           = '<CR>'
 let cmdline_map_send_and_stay  = '<M-CR>'
 let cmdline_map_source_fun     = '<LocalLeader>f'
 let cmdline_map_send_paragraph = '<LocalLeader>p'
 let cmdline_map_send_block     = '<LocalLeader>b'
 let cmdline_map_send_motion    = '<LocalLeader>m'
 let cmdline_map_quit           = '<LocalLeader>q'
 " let cmdline_external_term_cmd = 'kitty %s &'
]])

local kopts = { noremap = true, silent = true }

-- hlslens
vim.api.nvim_set_keymap(
	"n",
	"n",
	[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts
)
vim.api.nvim_set_keymap(
	"n",
	"N",
	[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts
)
vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

local hop = require("hop")
vim.keymap.set("", "s", function()
	hop.hint_words({})
end, { remap = true })
vim.keymap.set("", "S", function()
	hop.hint_lines_skip_whitespace({})
end, { remap = true })
