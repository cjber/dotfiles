return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require "lspconfig"
    local nvlsp = require "nvchad.configs.lspconfig"

    -- Configure diagnostics display
    vim.diagnostic.config {
      virtual_text = false, -- Using tiny-inline-diagnostic instead
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    }

    -- Configure hover handler
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded",
      focus = false,
      max_width = 80,
    })

    -- Configure signature help handler
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "rounded",
      focus = false,
      max_width = 80,
    })

    -- Server configurations
    local servers = {
      lua_ls = {},
      sourcery = {},
      ruff = {},
      bashls = {},
      sqlls = {},
      dockerls = {},
    }

    -- Setup servers with default config
    for server, server_opts in pairs(servers) do
      local opts = vim.tbl_deep_extend("force", {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
      }, server_opts)

      lspconfig[server].setup(opts)
    end

    -- LTEX (grammar/spell checking for LaTeX, Markdown, etc.)
    lspconfig.ltex.setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
      filetypes = { "tex", "quarto", "markdown" },
      settings = {
        ltex = {
          additionalRules = {
            enablePickyRules = true,
            languageModel = "~/.ngram/",
          },
          disabledRules = {
            ["en-GB"] = { "OXFORD_SPELLING_Z_NOT_S", "MORFOLOGIK_RULE_EN_GB" },
          },
          language = "en-GB",
          checkfrequency = "save",
        },
      },
    }

    -- Pyright (Python type checking)
    lspconfig.pyright.setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
      settings = {
        pyright = {
          disableOrganizeImports = true, -- Using Ruff for this
        },
        python = {
          analysis = {
            ignore = { "*" }, -- Only using Pyright for type checking
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    }

    -- Disable Ruff's hover in favor of Pyright
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        -- Disable hover in Ruff, use Pyright instead
        if client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end
      end,
      desc = "LSP: Disable hover capability from Ruff",
    })

    -- Add border to LspInfo window
    require("lspconfig.ui.windows").default_options.border = "rounded"
  end,
}
