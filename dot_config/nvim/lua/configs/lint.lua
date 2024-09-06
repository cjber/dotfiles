local spec = {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {
      -- python = { "mypy" },
      sh = { "shellcheck" },
      markdown = { "vale" },
      quarto = { "vale" },
      vim = { "vint" },
      yaml = { "yamllint" },
      json = { "jsonlint" },
      dockerfile = { "hadolint" },
      javascript = { "eslint" },
    }
  end,
}

return spec
