require("nvchad.configs.lspconfig").defaults()

local servers = { "pyright", "ruff" }
vim.lsp.enable(servers)
