local options = {
  formatters_by_ft = {
    python = { "isort", "black", "injected" },
    sql = { "sqlfmt" },
    lua = { "stylua" },
    javascript = { "prettier" },
    json = { "prettier" },
  },
}

return options
