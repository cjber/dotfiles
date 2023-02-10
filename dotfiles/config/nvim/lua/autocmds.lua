local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	group = "YankHighlight",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = "250" })
	end,
})

autocmd("FileType", { pattern = "*", command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o" })
autocmd("TermOpen", { pattern = "*", command = "startinsert" })
autocmd("TextYankPost", { pattern = "*", command = "lua vim.highlight.on_yank{}" })
autocmd("BufEnter", { pattern = "*", command = [[if (winnr('$') == 1 && &buftype == 'terminal') | q | endif]] })
autocmd("CursorHold", {
	pattern = "*",
	command = [[lua vim.diagnostic.open_float({border='single', focusable=false, show_header=false, scope='cursor'})]],
})
-- autocmd("CursorHold", { pattern = "*", command = [[lua vim.lsp.buf.hover()]] })
-- autocmd("CursorHold", { pattern = "*", command = [[lua require('ufo').peekFoldedLinesUnderCursor()]] })
autocmd("CursorHold", { pattern = "python", command = "lua vim.lsp.buf.document_highlight()" })
autocmd("CursorMoved", { pattern = "python", command = "lua vim.lsp.buf.clear_references()" })
autocmd("BufEnter", { pattern = "*.jsonnet", command = "set filetype=jsonnet" })
autocmd("BufEnter", { pattern = "*.jsonl", command = "set filetype=json" })
autocmd("FileType", { pattern = "alpha", command = "set laststatus=0 | autocmd BufUnload <buffer> set laststatus=2" })
