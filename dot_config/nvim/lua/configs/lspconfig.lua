return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require "lspconfig"

    vim.diagnostic.config { virtual_text = false }
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "none",
      focus = false,
    })

    local servers = {
      -- lua
      "lua_ls",

      -- python
      -- pyright is configured separately below
      "sourcery",
      "ruff",

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

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
          return
        end
        if client.name == "ruff" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = "LSP: Disable hover capability from Ruff",
    })
  end,
}
