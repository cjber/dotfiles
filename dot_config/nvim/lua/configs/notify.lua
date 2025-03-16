return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    vim.notify = require "notify"
    require("notify").setup {
      stages = "fade",
      render = "wrapped-compact",
      timeout = 200,
      merge_duplicates = true,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { border = "none" })
      end,
    }
  end,
}
