return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup {
      select = { lookahead = true },
      move = { set_jumps = true },
    }

    local select = require "nvim-treesitter-textobjects.select"
    local swap = require "nvim-treesitter-textobjects.swap"
    local move = require "nvim-treesitter-textobjects.move"

    -- Select text objects
    local select_maps = {
      ["a="] = "@assignment.outer",
      ["i="] = "@assignment.inner",
      ["l="] = "@assignment.lhs",
      ["r="] = "@assignment.rhs",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      ["ai"] = "@conditional.outer",
      ["ii"] = "@conditional.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
      ["af"] = "@call.outer",
      ["if"] = "@call.inner",
      ["am"] = "@function.outer",
      ["im"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
    }
    for key, query in pairs(select_maps) do
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(query, "textobjects")
      end)
    end

    -- Swap text objects
    vim.keymap.set("n", "<leader>na", function() swap.swap_next "@parameter.inner" end)
    vim.keymap.set("n", "<leader>nm", function() swap.swap_next "@function.outer" end)
    vim.keymap.set("n", "<leader>pa", function() swap.swap_previous "@parameter.inner" end)
    vim.keymap.set("n", "<leader>pm", function() swap.swap_previous "@function.outer" end)

    -- Move to next/prev text objects
    local goto_maps = {
      { key = "]f",    fn = "goto_next_start",    query = "@call.outer" },
      { key = "<M-j>", fn = "goto_next_start",    query = "@function.outer" },
      { key = "]c",    fn = "goto_next_start",    query = "@class.outer" },
      { key = "]i",    fn = "goto_next_start",    query = "@conditional.outer" },
      { key = "]l",    fn = "goto_next_start",    query = "@loop.outer" },
      { key = "]s",    fn = "goto_next_start",    query = "@local.scope",       group = "locals" },
      { key = "]z",    fn = "goto_next_start",    query = "@fold",              group = "folds" },
      { key = "]F",    fn = "goto_next_end",      query = "@call.outer" },
      { key = "]M",    fn = "goto_next_end",      query = "@function.outer" },
      { key = "]C",    fn = "goto_next_end",      query = "@class.outer" },
      { key = "]I",    fn = "goto_next_end",      query = "@conditional.outer" },
      { key = "]L",    fn = "goto_next_end",      query = "@loop.outer" },
      { key = "[f",    fn = "goto_previous_start", query = "@call.outer" },
      { key = "<M-k>", fn = "goto_previous_start", query = "@function.outer" },
      { key = "[c",    fn = "goto_previous_start", query = "@class.outer" },
      { key = "[i",    fn = "goto_previous_start", query = "@conditional.outer" },
      { key = "[l",    fn = "goto_previous_start", query = "@loop.outer" },
      { key = "[F",    fn = "goto_previous_end",   query = "@call.outer" },
      { key = "[M",    fn = "goto_previous_end",   query = "@function.outer" },
      { key = "[C",    fn = "goto_previous_end",   query = "@class.outer" },
      { key = "[I",    fn = "goto_previous_end",   query = "@conditional.outer" },
      { key = "[L",    fn = "goto_previous_end",   query = "@loop.outer" },
    }
    for _, m in ipairs(goto_maps) do
      vim.keymap.set({ "n", "x", "o" }, m.key, function()
        move[m.fn](m.query, m.group or "textobjects")
      end)
    end

    -- Repeatable movement with ; and ,
    local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  end,
}
