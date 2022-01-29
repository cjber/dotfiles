local border = {
	{ "┌", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "┐", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "┘", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "└", "FloatBorder" },
	{ "│", "FloatBorder" },
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- customise diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	virtual_text = false,
	signs = true,
	update_in_insert = false,
	border = border,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- require'lspconfig'.pylsp.setup {}
-- require("lspconfig").jedi_language_server.setup({})
--[[ require'lspconfig'.pyre.setup {
    root_dir = require'lspconfig'.util.root_pattern('.git')
} ]]

require("lspconfig").pyright.setup({
	flags = { debounce_text_changes = 150 },
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
				typeCheckingMode = "false",
				extraPaths = { "__pypackages__/<major.minor>/lib" },
			},
			autoComplete = { extraPaths = { "__pypackages__/<major.minor>/lib" } },
		},
	},
	-- root_dir = require'lspconfig'.util.root_pattern('.git'),
	capabilities = capabilities,
})

require("lspconfig").dockerls.setup({ capabilities = capabilities })
require("lspconfig").r_language_server.setup({
	filetypes = { "r", "rmd" },
	capabilities = capabilities,
})
require("lspconfig").texlab.setup({ capabilities = capabilities })
require("lspconfig").vimls.setup({ capabilities = capabilities })
require("lspconfig").yamlls.setup({ capabilities = capabilities })
require("lspconfig").jsonls.setup({ capabilities = capabilities })
require("lspconfig").rust_analyzer.setup({ capabilities = capabilities })
require("lspconfig").sqlls.setup({
	capabilities = capabilities,
	cmd = { "/usr/bin/sql-language-server", "up", "--method", "stdio" },
	root_dir = require("lspconfig").util.root_pattern(".git", ""),
})

require("lspconfig").zeta_note.setup({
	cmd = { "/home/cjber/bin/zeta-note-linux" },
	capabilities = capabilities,
	root_dir = require("lspconfig").util.root_pattern(".git"),
})

local luadev = require("lua-dev").setup({
	lspconfig = {
		cmd = { "lua-language-server" },
		settings = { Lua = { diagnostics = { globals = { "use" } } } },
	},
	capabilities = capabilities,
})

require("lspconfig").sumneko_lua.setup(luadev)
require("sourcery")
require("rust-tools").setup()

require("null-ls").setup({
	sources = {
		-- python
		require("null-ls").builtins.formatting.black,
		require("null-ls").builtins.formatting.isort.with({
			extra_args = { "--float-to-top" },
		}),
		require("null-ls").builtins.diagnostics.flake8.with({
			extra_args = { "--max-line-length=89", "--ignore=E203,W503" },
		}),
		-- require("null-ls").builtins.diagnostics.pylint,
		-- lua
		require("null-ls").builtins.formatting.stylua,
		-- R
		require("null-ls").builtins.formatting.styler,
		-- docker
		require("null-ls").builtins.diagnostics.hadolint,
		-- markdown
		require("null-ls").builtins.hover.dictionary,
		require("null-ls").builtins.diagnostics.markdownlint.with({
			extra_args = { "--disable=line_length" },
		}),
		require("null-ls").builtins.diagnostics.proselint,
		require("null-ls").builtins.formatting.markdownlint,
		-- shell
		require("null-ls").builtins.diagnostics.shellcheck,
		-- general formatting
		require("null-ls").builtins.formatting.prettier,
	},
})
