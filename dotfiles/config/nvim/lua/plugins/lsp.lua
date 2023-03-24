vim.diagnostic.config({ virtual_text = false, signs = true, update_in_insert = false })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "single",
})
local lsp = require("lsp-zero").preset({
	suggest_lsp_servers = true,
	setup_servers_on_start = true,
	set_lsp_keymaps = true,
	configure_diagnostics = true,
	cmp_capabilities = true,
	manage_nvim_cmp = true,
	sign_icons = {
		error = "✘ ",
		warn = " ",
		hint = "⚑",
		info = "",
	},
})
lsp.nvim_workspace()
lsp.ensure_installed({
	"jedi_language_server",
	"lua_ls",
	"ltex",
	"sourcery",
	"vimls",
	"dockerls",
})

-- lsp.configure("jedi-language-server", {})

lsp.configure("ltex", {
	filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "quarto" },
	on_attach = function(client, bufnr)
		require("ltex_extra").setup({
			load_langs = { "en-GB" },
			init_check = true,
			path = nil,
			log_level = "none",
		})
	end,
	settings = {
		ltex = {
			additionalRules = { enablePickyRules = true },
			disabledRules = {
				["en-GB"] = { "OXFORD_SPELLING_Z_NOT_S", "MORFOLOGIK_RULE_EN_GB", "TOO_LONG_SENTENCE", "EN_QUOTES" },
			},
			language = "en-GB",
			checkfrequency = "save",
		},
	},
})

lsp.configure("lua_ls", {
	settings = {
		Lua = {
			format = {
				enable = false,
			},
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

require("null-ls").setup({
	sources = {
		-- python
		require("null-ls").builtins.formatting.isort.with({
			extra_args = { "--float-to-top", "-m=3" },
		}),
		require("null-ls").builtins.formatting.black,
		require("null-ls").builtins.diagnostics.ruff,
		-- require("null-ls").builtins.formatting.ruff,
		require("null-ls-embedded").nls_source,
		-- lua
		require("null-ls").builtins.formatting.stylua,
		-- docker
		require("null-ls").builtins.diagnostics.hadolint,
		require("null-ls").builtins.hover.dictionary.with({ extra_filetypes = { "quarto", "rmarkdown" } }),
		require("null-ls").builtins.diagnostics.markdownlint.with({
			extra_args = { "--disable MD013 MD025" },
		}),
		require("null-ls").builtins.formatting.markdownlint,
		-- shell
		require("null-ls").builtins.diagnostics.shellcheck,
	},
})
require("mason-null-ls").setup({
	ensure_installed = { "stylua", "black", "ruff", "isort", "hadolint", "markdownlint", "shellcheck" },
    automatic_installation = true,
})

lsp.setup()
