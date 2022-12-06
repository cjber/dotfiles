local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "single",
})

vim.diagnostic.config({ virtual_text = false, signs = true, update_in_insert = false })
-- require('lsp_lines').setup()

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}
local lsp = require("lspconfig")
lsp.clangd.setup({ capabilities = capabilities })
lsp.pyright.setup({
	flags = { debounce_text_changes = 150 },
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
				typeCheckingMode = "off",
				-- extraPaths = { "__pypackages__/<major.minor>/lib" },
			},
			-- autoComplete = { extraPaths = { "__pypackages__/<major.minor>/lib" } },
			-- autoComplete = false,
		},
	},
	capabilities = capabilities,
})
lsp.jedi_language_server.setup({ capabilities = capabilities })
lsp.taplo.setup({})

lsp.dockerls.setup({ capabilities = capabilities })
lsp.r_language_server.setup({
	filetypes = { "r", "rmd" },
	capabilities = capabilities,
})
lsp.texlab.setup({ capabilities = capabilities })
lsp.vimls.setup({ capabilities = capabilities })
lsp.yamlls.setup({ capabilities = capabilities })
lsp.jsonls.setup({ capabilities = capabilities, cmd = { "vscode-json-languageserver", "--stdio" } })
lsp.rust_analyzer.setup({ capabilities = capabilities })
lsp.sqlls.setup({
	capabilities = capabilities,
	cmd = { "/usr/bin/sql-language-server", "up", "--method", "stdio" },
	root_dir = lsp.util.root_pattern(".git", ""),
})

require("neodev").setup({})
lsp.sumneko_lua.setup({
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},

			format = {
				enable = false,
				defaultConfig = { quote_style = "double", column_limit = 89 },
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
	capabilities = capabilities,
})

lsp.sourcery.setup({
	init_options = { token = "user_kyIXI3RYu2AnkC7QMChz2FdgT92mqUZvw7DOfx1pgJ6kOAcdPyLMUo9pom0" },
})
require("rust-tools").setup()
lsp.ltex.setup({
	filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "quarto" },
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		require("ltex_extra").setup({
			load_langs = { "en-GB" },
			init_check = true,
			path = nil,
			log_level = "none",
		})
	end,
	settings = { ltex = { language = "en-GB" } },
})

-- lsp.grammarly.setup({ filetypes = { "quarto", 'markdown' } })

require("null-ls").setup({
	sources = {
		-- python
		require("null-ls").builtins.formatting.isort.with({
			extra_args = { "--float-to-top", "-m=3" },
		}),
		require("null-ls").builtins.formatting.black,
		-- require("null-ls").builtins.diagnostics.flake8.with({
		--     extra_args = { "--max-line-length=89", "--ignore=E203,W503,F401" },
		-- }),
		require("null-ls").builtins.diagnostics.ruff.with({
			extra_args = { "--max-line-length=89", "--ignore=E203,W503,F401" },
		}),
		-- require("null-ls").builtins.diagnostics.mypy,
		-- lua
		require("null-ls").builtins.formatting.stylua,
		-- R
		-- require("null-ls").builtins.formatting.styler,
		-- docker
		require("null-ls").builtins.diagnostics.hadolint,
		-- markdown
		-- require("null-ls").builtins.diagnostics.vale.with({
		--     extra_filetypes = { "quarto", "rmarkdown" },
		-- }),
		require("null-ls").builtins.hover.dictionary.with({ extra_filetypes = { "quarto", "rmarkdown" } }),
		require("null-ls").builtins.diagnostics.markdownlint.with({
			extra_args = { "--disable=line_length" },
		}),
		require("null-ls").builtins.formatting.markdownlint,
		-- shell
		require("null-ls").builtins.diagnostics.shellcheck,
		-- general formatting
		-- require("null-ls").builtins.formatting.prettier,
	},
})
