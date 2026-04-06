local spec = {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  build = ":TSUpdate",
  event = { "VeryLazy" },
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      -- main
      "python",
      "dockerfile",
      "sql",
      -- dev
      "bash",
      "query",
      "regex",
      -- neovim
      "lua",
      "vim",
      "vimdoc",
      -- markup-ish
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
      -- sometimes
      "html",
      "css",
    },
  },
}

return spec
