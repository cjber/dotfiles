-- load defaults i.e lua_lsp

local lspconfig = require "lspconfig"

vim.diagnostic.config { virtual_text = false }
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "none",
  focus = false,
})

-- EXAMPLE
local servers = {
  -- python
  "pyright",
  "sourcery",
  "ruff",

  -- quarto
  "ltex",

  -- bash
  "bashls",

  -- sql
  "sqlls",

  -- docker
  "dockerls",
}

local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig.ltex.setup {
  filetypes = { "tex", "quarto", "markdown" },
  settings = {
    ltex = {
      additionalRules = { enablePickyRules = true, languageModel = "~/.ngram/" },
      disabledRules = {
        ["en-GB"] = { "OXFORD_SPELLING_Z_NOT_S", "MORFOLOGIK_RULE_EN_GB" },
      },
      language = "en-GB",
      checkfrequency = "save",
    },
  },
}

require("lspconfig").pyright.setup {
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        ignore = { "*" },
      },
    },
  },
}
