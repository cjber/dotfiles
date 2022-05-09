local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({ virtual_text = false, signs = true, update_in_insert = false })

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

require("lspconfig").clangd.setup({ capabilities = capabilities })

require("lspconfig").pyright.setup({
	flags = { debounce_text_changes = 150 },
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly",
				typeCheckingMode = "off",
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
local luadev = require("lua-dev").setup({
	lspconfig = {
		cmd = { "lua-language-server" },
		settings = { Lua = { diagnostics = { globals = { "use" } } } },
	},
	capabilities = capabilities,
})
require("lspconfig").sumneko_lua.setup(luadev)

require("lspconfig").sourcery.setup({
	init_options = { token = "user_kyIXI3RYu2AnkC7QMChz2FdgT92mqUZvw7DOfx1pgJ6kOAcdPyLMUo9pom0" },
})
require("rust-tools").setup()

require("null-ls").setup({
	sources = {
		-- python
		require("null-ls").builtins.formatting.isort.with({
			extra_args = { "--float-to-top", "-m=3" },
		}),
		require("null-ls").builtins.formatting.black,
		require("null-ls").builtins.diagnostics.flake8.with({
			extra_args = { "--max-line-length=89", "--ignore=E203,W503,F401" },
		}),
		-- require("null-ls").builtins.diagnostics.mypy,
		-- lua
		require("null-ls").builtins.formatting.stylua,
		-- R
		-- require("null-ls").builtins.formatting.styler,
		require("null-ls").builtins.diagnostics.hadolint,
		-- markdown
		require("null-ls").builtins.diagnostics.proselint.with({
			extra_filetypes = { "quarto" },
		}),

		require("null-ls").builtins.code_actions.proselint.with({
			extra_filetypes = { "quarto" },
		}),
		require("null-ls").builtins.completion.spell.with({
			extra_filetypes = { "quarto" },
		}),
		require("null-ls").builtins.diagnostics.misspell.with({
			extra_filetypes = { "quarto" },
		}),
		require("null-ls").builtins.hover.dictionary.with({ extra_filetypes = { "quarto" } }),
		require("null-ls").builtins.formatting.codespell,
		require("null-ls").builtins.hover.dictionary,
		require("null-ls").builtins.diagnostics.markdownlint.with({
			extra_args = { "--disable=line_length" },
		}),
		require("null-ls").builtins.formatting.markdownlint,
		-- shell
		require("null-ls").builtins.diagnostics.shellcheck,
		-- general formatting
		require("null-ls").builtins.formatting.prettier,
	},
})
