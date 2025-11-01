require "nvchad.mappings"

local map = vim.keymap.set
local unmap = vim.keymap.del

-- Remove default NvChad mappings that conflict with custom ones
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
  pcall(unmap, "n", key) -- Use pcall to avoid errors if key doesn't exist
end

-- Line navigation (respect line wrapping)
map("n", "j", "gj", { desc = "Move down (display lines)" })
map("n", "k", "gk", { desc = "Move up (display lines)" })

-- Enhanced movement mappings
local movement_maps = {
  { mode = { "n", "v" }, key = "J", cmd = "}", desc = "Next paragraph" },
  { mode = { "n", "v" }, key = "K", cmd = "{", desc = "Previous paragraph" },
  { mode = { "n", "v" }, key = "H", cmd = "^", desc = "Start of line" },
  { mode = { "n", "v" }, key = "L", cmd = "$", desc = "End of line" },
}

for _, m in ipairs(movement_maps) do
  map(m.mode, m.key, m.cmd, { desc = m.desc })
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Editing enhancements
map("n", "M", "<cmd>join<cr>", { desc = "Join lines" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("v", "M", "J", { desc = "Join lines (visual)" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Buffer management
map("n", "<leader>bo", function()
  require("close_buffers").delete { type = "other", force = true }
  vim.cmd "silent! only"
end, { desc = "Close other buffers" })

map("n", "<leader>bd", function()
  require("close_buffers").delete { type = "this", force = true }
end, { desc = "Close current buffer" })

-- Quickfix navigation
map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
map("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })

-- LSP mappings
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>lk", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>lf", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format buffer" })
map("n", "<leader>lr", function()
  require("nvchad.lsp.renamer")()
end, { desc = "LSP rename" })
map("n", "<leader>ls", function()
  require("telescope.builtin").lsp_document_symbols {
    symbols = { "method", "function", "class" },
  }
end, { desc = "LSP document symbols" })

-- Telescope mappings
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Projects" })
map("n", "<leader>fl", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })
map("n", "<leader>fT", "<cmd>TodoTelescope<cr>", { desc = "Todo telescope" })
map("n", "<leader>fq", "<cmd>Telescope quickfix<cr>", { desc = "Quickfix list" })

-- Git mappings
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Git diff" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame line" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })
map("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset buffer" })

-- Tool mappings
map("n", "<C-n>", "<cmd>Oil<cr>", { desc = "Open Oil file manager" })
map("n", "<leader>aa", "<cmd>AvanteToggle<cr>", { desc = "Toggle Avante" })
map("n", "<leader>y", "<cmd>YaRepl<cr>", { desc = "Open REPL" })

-- Markdown preview
map("n", "<leader>pp", "<cmd>PeekOpen<cr>", { desc = "Open Peek preview" })
map("n", "<leader>pc", "<cmd>PeekClose<cr>", { desc = "Close Peek preview" })

-- Navigation plugins
map("n", "s", "<cmd>HopWord<cr>", { desc = "Hop to word" })
map("n", "S", "<cmd>HopLineStart<cr>", { desc = "Hop to line start" })

-- Spell checking
map("n", "<leader>ss", function()
  vim.opt.spell = not vim.opt.spell:get()
end, { desc = "Toggle spell check" })
map("n", "<leader>sf", "ma[s1z=`a", { desc = "Fix spelling (first suggestion)" })

-- Terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Plugin updates
map("n", "<leader>u", "<cmd>Lazy sync<cr>", { desc = "Update plugins (Lazy sync)" })
