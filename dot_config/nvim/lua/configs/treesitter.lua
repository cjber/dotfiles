local spec = {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  build = ":TSUpdate",
  event = { "VeryLazy" },
  opts = { highlight = { enable = true }, indent = { enable = true }, ensure_installed = "all" },
}

return spec
