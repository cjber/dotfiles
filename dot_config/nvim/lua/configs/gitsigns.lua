return {
  "lewis6991/gitsigns.nvim",
  enabled = true,
  opts = {
    signcolumn = true,
    current_line_blame = true,
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "│" },
      topdelete = { text = "┆" },
      changedelete = { text = "┆" },
      untracked = { text = "┆" },
    },
    signs_staged_enable = false,
  },
}
