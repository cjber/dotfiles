return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-telescope/telescope-file-browser.nvim" },

  opts = {
    pickers = { find_files = { follow = true } },
  },
}
