return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_format", "ruff_organize_imports", "injected" },
      sql = { "sqlfmt" },
      lua = { "stylua" },
      javascript = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
    },
    formatters = { isort = { append_args = { "--float-to-top" } } },
  },
}
