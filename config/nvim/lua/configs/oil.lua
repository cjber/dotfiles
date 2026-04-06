return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    columns = { "icon", "permissions", "size", "mtime" },
    delete_to_trash = true,
    keymaps_help = { border = "single" },
    view_options = { show_hidden = true },
  },
}
