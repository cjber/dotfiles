return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  opts = function()
    return {
      linters_by_ft = {
        sh = { "shellcheck" },
        markdown = { "vale" },
        quarto = { "vale" },
        vim = { "vint" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        dockerfile = { "hadolint" },
        javascript = { "eslint" },
      },
    }
  end,
  config = function(_, opts)
    local lint = require "lint"

    -- Set linters by filetype
    lint.linters_by_ft = opts.linters_by_ft

    -- Configure linter arguments
    lint.linters.shellcheck.args = {
      "--format=json",
      "-s", "bash",
      "-x", -- Allow sourcing external files
      "-",
    }

    lint.linters.yamllint.args = {
      "-f", "parsable",
      "-d", "{extends: default, rules: {line-length: disable}}",
      "-",
    }
  end,
}
