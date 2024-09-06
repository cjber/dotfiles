local spec = {
  "milanglacier/yarepl.nvim",
  event = "VeryLazy",
  config = function()
    local yarepl = require "yarepl"

    yarepl.setup { metas = { quarto = { cmd = "ipython", formatter = yarepl.trim_empty_lines } } }

    vim.api.nvim_create_user_command("REPLToCurLine", function(opts)
      local id = opts.count
      local name = opts.args
      local current_buffer = vim.api.nvim_get_current_buf()
      local current_line = vim.api.nvim_win_get_cursor(0)[1]

      local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, current_line, false)
      yarepl._send_strings(id, name, current_buffer, lines)
    end, {
      count = true,
      nargs = "?",
    })
  end,
}

return spec
