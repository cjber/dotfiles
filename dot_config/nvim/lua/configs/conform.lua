return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "isort", "black", "injected" },
      sql = { "sqlfmt" },
      lua = { "stylua" },
      javascript = { "prettier" },
      json = { "prettier" },
    },
    formatters = { isort = { append_args = { "--float-to-top" } } },
  },
}
