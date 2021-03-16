vim.cmd [[packadd nvim-lspconfig]]
vim.cmd [[packadd nvim-compe]]

local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local opts = {noremap = true, silent = true}

-- Mappings.
--[[ 
map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
map("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
map("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
map("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
map("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
map("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
]]

map("n", "<Leader>lf", [[<Cmd> Neoformat<CR>]], opts)
map("n", "<Leader>ld", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
map("n", "<Leader>lk", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
map("n", "<Leader>lr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
map("n", "<Leader>lc", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
map("n", "<Leader>le", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts) 

-- customise diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
  }
)
local autocmds = {
	todo = {
		{"CursorHold",     "*", "lua vim.lsp.diagnostic.show_line_diagnostics()"};
                {"FileType", "*", "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"};
	};
}

function nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		vim.cmd('augroup '..group_name)
		vim.cmd('autocmd!')
		for _, def in ipairs(definition) do
			-- if type(def) == 'table' and type(def[#def]) == 'function' then
			-- 	def[#def] = lua_callback(def[#def])
			-- end
			local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
			vim.cmd(command)
		end
		vim.cmd('augroup END')
	end
end

nvim_create_augroups(autocmds)

require"lspconfig".pyright.setup{}
