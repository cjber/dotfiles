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
	"pylsp",
	"lua_ls",
	"ltex",
	"sourcery",
})

lsp.configure("pylsp", {
	settings = {
		pylsp = {
			plugins = {
				pyflakes = { enabled = false },
				flake8 = { enabled = false },
				yapf = { enabled = false },
				pycodestyle = { enabled = false },
			},
		},
	},
})

lsp.configure("ltex", {
	filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "quarto" },
	cmd = { "/home/cjber/temp/ltex-ls-16.0.0-alpha.1.nightly.2023-03-10/bin/ltex-ls" },
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
			disabledRules = { ["en-GB"] = { "OXFORD_SPELLING_Z_NOT_S" } },
			language = "en-GB",
			checkfrequency = "save",
		},
	},
})

lsp.configure("lua_ls", {
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
})

require("null-ls").setup({
	sources = {
		-- python
		require("null-ls").builtins.formatting.isort.with({
			extra_args = { "--float-to-top", "-m=3" },
		}),
		require("null-ls").builtins.formatting.black,
		require("null-ls").builtins.diagnostics.ruff,
		require("null-ls").builtins.formatting.ruff,
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

lsp.setup()
