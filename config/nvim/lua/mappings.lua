local map = vim.keymap.set

-- Line navigation (soft wrap aware)
map("n", "j", "gj")
map("n", "k", "gk")

-- Paragraph and line position
map({ "n", "v" }, "J", "}", { desc = "Next paragraph" })
map({ "n", "v" }, "K", "{", { desc = "Previous paragraph" })
map({ "n", "v" }, "H", "^", { desc = "Start of line" })
map({ "n", "v" }, "L", "$", { desc = "End of line" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Quickfix
map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix" })
map("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix" })

-- Editing
map("n", "M", "<cmd>join<cr>", { desc = "Join lines" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("v", "M", "J", { desc = "Join lines" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Window resizing
map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

-- Buffer management
map("n", "<leader>bo", function()
  require("close_buffers").delete({ type = "other", force = true })
end, { desc = "Close other buffers" })
map("n", "<leader>bd", function()
  require("close_buffers").delete({ type = "this", force = true })
end, { desc = "Close current buffer" })

-- LSP
map("n", "<leader>le", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics" })
map("n", "<leader>lf", function() require("conform").format() end, { desc = "Format" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>lk", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>lg", function() require("neogen").generate() end, { desc = "Generate doc" })
map("n", "<leader>lr", function() require("configs.lsp-rename").rename_fancy() end, { desc = "LSP rename" })
map("n", "<leader>ls", function()
  Snacks.picker.lsp_symbols({ filter = { kind = { "Method", "Function", "Class" } } })
end, { desc = "LSP symbols" })
map("n", "<leader>ll", "<cmd>Trouble lsp_document_symbols toggle<cr>", { desc = "LSP symbol list" })
map("n", "<leader>ld", "<cmd>Trouble lsp_references toggle<cr>", { desc = "LSP references" })

map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
map("n", "<leader>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List workspace folders" })

-- Finding (snacks.picker)
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live grep" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find buffers" })
map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help tags" })
map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
map("n", "<leader>fl", function() Snacks.picker.explorer() end, { desc = "File explorer" })
map("n", "<leader>fo", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<leader>ft", "<cmd>TodoTrouble<cr>", { desc = "Todo list" })
map("n", "<leader>fT", function() Snacks.picker.todo_comments() end, { desc = "Todo picker" })
map("n", "<leader>fu", "<cmd>UndotreeToggle<cr>", { desc = "Undo tree" })
map("n", "<leader>fq", function() Snacks.picker.qflist() end, { desc = "Quickfix picker" })

-- Git
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Git diff" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })
map("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset buffer" })

-- Tools
map("n", "<C-n>", "<cmd>Oil<cr>", { desc = "Open Oil" })
map("n", "<leader>mp", "<cmd>PeekOpen<cr>", { desc = "Open Peek" })
map("n", "<leader>aa", "<cmd>AvanteToggle<cr>", { desc = "Avante" })
map("n", "<leader>y", "<cmd>YaRepl<cr>", { desc = "Open REPL" })

-- Misc
map("n", "<leader>ss", "<cmd>set invspell<cr>", { desc = "Toggle spell check" })
map("n", "<leader>sf", "ma[s1z=`a", { desc = "Fix spelling" })
map("n", "s", "<cmd>HopWord<cr>", { desc = "Hop to word" })
map("n", "S", "<cmd>HopLineStart<cr>", { desc = "Hop to line start" })
map("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>u", "<cmd>Lazy sync<cr>", { desc = "Lazy update" })
map("n", "<leader>pp", "<cmd>PeekOpen<cr>", { desc = "Peek" })
map("n", "<leader>pc", "<cmd>PeekClose<cr>", { desc = "Peek close" })
