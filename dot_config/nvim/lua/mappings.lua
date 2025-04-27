require "nvchad.mappings"

local map = vim.keymap.set
local nomap = vim.keymap.del

local M = {}

-- Remove default NvChad mappings
function M.remove_defaults()
  local default_unmaps = {
    "<leader>e",
    "<leader>h",
    "<leader>v",
    "<leader>b",
    "<leader>x",
    "<leader>n",
    "<leader>/",
    "<leader>fm",
    "<leader>cm",
    "<leader>ch",
  }

  for _, key in ipairs(default_unmaps) do
    nomap("n", key)
  end
end

-- Basic navigation mappings
function M.setup_navigation()
  -- Line navigation
  map("n", "j", "gj")
  map("n", "k", "gk")

  -- Paragraph and line position navigation
  local nav_maps = {
    { mode = { "n", "v" }, key = "J", map = "}", desc = "Next paragraph" },
    { mode = { "n", "v" }, key = "K", map = "{", desc = "Previous paragraph" },
    { mode = { "n", "v" }, key = "H", map = "^", desc = "Start of line" },
    { mode = { "n", "v" }, key = "L", map = "$", desc = "End of line" },
  }

  for _, m in ipairs(nav_maps) do
    for _, mode in ipairs(m.mode) do
      map(mode, m.key, m.map, { desc = m.desc })
    end
  end

  -- Window navigation
  map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
  map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
  map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
  map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

  -- Quickfix navigation
  map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
  map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
  map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
  map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
  map("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
  map("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })
end

-- Text editing mappings
function M.setup_editing()
  map("n", "M", "<CMD>join<CR>", { desc = "Join lines" })
  map("n", "U", "<C-r>", { desc = "Redo" })
  -- Removed q: mapping as it overrides command history
  map("v", "M", "J", { desc = "Join lines" })

  map("v", "<", "<gv", { desc = "Indent left and reselect" })
  map("v", ">", ">gv", { desc = "Indent right and reselect" })
end

-- Window and buffer management
function M.setup_window_buffer()
  -- Window resizing
  map("n", "<Up>", "<CMD>resize +2<CR>", { desc = "Increase height" })
  map("n", "<Down>", "<CMD>resize -2<CR>", { desc = "Decrease height" })
  map("n", "<Left>", "<CMD>vertical resize -2<CR>", { desc = "Decrease width" })
  map("n", "<Right>", "<CMD>vertical resize +2<CR>", { desc = "Increase width" })

  -- Buffer management with close_buffers plugin
  map(
    "n",
    "<leader>bo",
    [[<CMD>lua require("close_buffers").delete({type="other", force=true})<CR><CMD>silent on<CR>]],
    { desc = "Close other buffers" }
  )
  map(
    "n",
    "<leader>bd",
    [[<CMD>lua require("close_buffers").delete({type="this", force=true})<CR>]],
    { desc = "Close current buffer" }
  )
end

-- LSP related mappings
function M.setup_lsp()
  map("n", "<leader>le", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Toggle diagnostics" })
  map("n", "<leader>lf", "<CMD>lua require'conform'.format()<CR>", { desc = "Format" })
  map("n", "<leader>la", "<CMD>lua vim.lsp.buf.code_action()<CR>", { desc = "Code action" })
  map("n", "<leader>lk", "<CMD>lua vim.lsp.buf.hover()<CR>", { desc = "Code hover" })
  map("n", "<leader>lg", "<CMD>lua require'neogen'.generate()<CR>", { desc = "Generate doc" })
  map("n", "<leader>lr", function()
    require "nvchad.lsp.renamer"()
  end, { desc = "LSP rename" })
  map(
    "n",
    "<leader>ls",
    "<CMD>lua require('telescope.builtin').lsp_document_symbols({symbols={'method', 'function', 'class'}})<CR>",
    { desc = "LSP symbols" }
  )
  map("n", "<leader>ll", "<CMD>Trouble lsp_document_symbols toggle<CR>", { desc = "LSP symbol list" })
  map("n", "<leader>ld", "<CMD>Trouble lsp_references toggle<CR>", { desc = "LSP references" })
  map("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
  map("n", "gr", "<CMD>lua vim.lsp.buf.references()<CR>", { desc = "Go to references" })
  map("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
  map("n", "gt", "<CMD>lua vim.lsp.buf.type_definition()<CR>", { desc = "Go to type definition" })
end

-- Telescope and finding mappings
function M.setup_telescope()
  map("n", "<leader>ff", "<CMD>Telescope find_files<CR>", { desc = "Find files" })
  map("n", "<leader>fg", "<CMD>Telescope live_grep<CR>", { desc = "Live grep" })
  map("n", "<leader>fb", "<CMD>Telescope buffers<CR>", { desc = "Find buffers" })
  map("n", "<leader>fh", "<CMD>Telescope help_tags<CR>", { desc = "Help tags" })
  map("n", "<leader>fp", "<CMD>Telescope projects<CR>", { desc = "Projects" })
  map("n", "<leader>fl", "<CMD>Telescope file_browser<CR>", { desc = "File Browser" })
  map("n", "<leader>ft", "<CMD>TodoTrouble<CR>", { desc = "Todo list" })
  map("n", "<leader>fT", "<CMD>TodoTelescope<CR>", { desc = "Todo telescope" })
  map("n", "<leader>fu", "<CMD>UndotreeToggle<CR>", { desc = "Undo" })
  map("n", "<leader>fq", "<CMD>Telescope quickfix<CR>", { desc = "Quickfix telescope" })
end

-- Git related mappings
function M.setup_git()
  map("n", "<leader>gg", "<CMD>Neogit<CR>", { desc = "Neogit" })
  map("n", "<leader>gd", "<CMD>Gitsigns diffthis<CR>", { desc = "Git diff" })
  map("n", "<leader>gb", "<CMD>Gitsigns blame_line<CR>", { desc = "Git blame" })
  map("n", "<leader>gp", "<CMD>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
  map("n", "<leader>gr", "<CMD>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
  map("n", "<leader>gR", "<CMD>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
end

-- Tool-related mappings
function M.setup_tools()
  map("n", "<C-n>", "<CMD>Oil<CR>", { desc = "Open Oil" })
  map("n", "<leader>mp", "<CMD>PeekOpen<CR>", { desc = "Open Peek" })
  map("n", "<leader>aa", "<CMD>AvanteToggle<CR>", { desc = "Avante" })
  map("n", "<leader>y", "<CMD>YaRepl<CR>", { desc = "Open REPL" })
end

-- Miscellaneous mappings
function M.setup_misc()
  -- Spell checking
  map("n", "<leader>ss", "<CMD>set invspell<CR>", { desc = "Toggle spell check" })
  map("n", "<leader>sf", "ma[s1z=`a", { desc = "Fix spelling" })

  -- Hop plugin
  map("n", "s", "<CMD>HopWord<CR>", { desc = "Hop to word" })
  map("n", "S", "<CMD>HopLineStart<CR>", { desc = "Hop to line start" })

  -- Terminal
  map("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

  -- Updates
  map("n", "<leader>u", "<CMD>Lazy sync<CR>", { desc = "Lazy Update" })

  -- Peek
  map("n", "<leader>pp", "<CMD>PeekOpen<CR>", { desc = "Peek" })
  map("n", "<leader>pc", "<CMD>PeekClose<CR>", { desc = "Peek" })
end

-- Setup all mappings
function M.setup()
  M.remove_defaults()
  M.setup_navigation()
  M.setup_editing()
  M.setup_window_buffer()
  M.setup_lsp()
  M.setup_telescope()
  M.setup_git()
  M.setup_tools()
  M.setup_misc()
end

-- Initialize all mappings
M.setup()

return M
