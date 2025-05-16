local spec = {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {
      sh = { "shellcheck" },
      markdown = { "vale" },
      quarto = { "vale" },
      vim = { "vint" },
      yaml = { "yamllint" },
      json = { "jsonlint" },
      dockerfile = { "hadolint" },
      javascript = { "eslint" },
    }
    require("lint").linters.shellcheck.args = { "-x" }
    require("lint").linters.yamllint.args = { "--line_length disable" }
  end,
}

return spec
