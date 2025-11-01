return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      -- Python (ruff handles everything)
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },

      -- Lua
      lua = { "stylua" },

      -- SQL
      sql = { "sqlfmt" },

      -- Web technologies
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },

      -- Markdown
      markdown = { "prettier" },

      -- Shell
      bash = { "shfmt" },
      sh = { "shfmt" },
    },

    -- Format on save configuration
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },

    -- Formatter configurations
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },
    },
  },
}
