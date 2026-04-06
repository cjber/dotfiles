return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    picker = {
      enabled = true,
      layout = {
        preset = "ivy",
        layout = { height = 0.4, border = "none" },
      },
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
      },
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
          },
          border = "none",
        },
        list = { border = "none" },
        preview = { border = "none" },
      },
      formatters = {
        file = { filename_first = true },
      },
      icons = {
        files = { enabled = true },
      },
    },
    notifier = {
      enabled = true,
      timeout = 2000,
      style = "compact",
    },
    indent = {
      enabled = true,
      animate = { enabled = false },
    },
    statuscolumn = {
      enabled = true,
      left = { "sign" },
      right = { "fold" },
      folds = {
        open = true,
        git_hl = true,
      },
    },
    dashboard = { enabled = false },
    input = { enabled = true },
    scope = { enabled = true },
  },
}
