local au = require("funcs.autocmd")

au.define_autocmds({
	FileType = {
		["*"] = {
			-- don't insert comments
			"setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
		},
	},
	TermOpen = {
		["*"] = {
			-- automatically enter insert mode on new terminals
			"startinsert",
		},
	},
	TextYankPost = { ["*"] = { [[lua vim.highlight.on_yank{}]] } },
	BufEnter = {
		-- auto close terminal if last window
		["*"] = { [[if (winnr('$') == 1 && &buftype == 'terminal') | q | endif]] },
	},
	CursorHold = {
		["*"] = {
			"lua vim.diagnostic.open_float({border='single', focusable=false, show_header=false, scope='cursor'})",
		},
		["python"] = { "lua vim.lsp.buf.document_highlight()" },
	},
	CursorMoved = {
		["python"] = { "lua vim.lsp.buf.clear_references()" },
	},
})
