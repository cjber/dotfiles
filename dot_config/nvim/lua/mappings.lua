require "nvchad.mappings"

local map = vim.keymap.set
local nomap = vim.keymap.del

-- unmap some defaults
nomap("n", "<leader>e")
nomap("n", "<leader>h")
nomap("n", "<leader>v")
nomap("n", "<leader>b")
nomap("n", "<leader>x")
nomap("n", "<leader>n")
nomap("n", "<leader>/")
nomap("n", "<leader>fm")
nomap("n", "<leader>cm")
nomap("n", "<leader>ch")

-- normal mappings
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "q:", "<CMD>q<CR>", { desc = "Quit" })
map("n", "M", "<CMD>join<CR>", { desc = "Join lines" })
map("n", "J", "}", { desc = "Next paragraph" })
map("n", "K", "{", { desc = "Previous paragraph" })
map("n", "H", "^", { desc = "Start of line" })
map("n", "L", "$", { desc = "End of line" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<Up>", "<CMD>resize +2<CR>", { desc = "Increase height" })
map("n", "<Down>", "<CMD>resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-n>", "<CMD>Oil<CR>", { desc = "Open Oil" })

-- spell
map("n", "<leader>ss", "<CMD>set invspell<CR>", { desc = "Toggle spell check" })
map("n", "<leader>sf", "ma[s1z=`a", { desc = "Fix spelling" })

-- buffers
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

-- update
map("n", "<leader>u", "<CMD>Lazy sync<CR>", { desc = "Lazy Update" })

-- hop
map("n", "s", "<CMD>HopWord<CR>", { desc = "Hop to word" })
map("n", "S", "<CMD>HopLineStart<CR>", { desc = "Hop to line start" })

-- visual mappings
map("v", "M", "J", { desc = "Join lines" })
map("v", "J", "}", { desc = "Next paragraph" })
map("v", "K", "{", { desc = "Previous paragraph" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- terminal mappings
map("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- LSP mappings
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
map("n", "<leader>fl", "<CMD>Telescope file_browser<CR>", { desc = "File Browser" })
map("n", "<leader>ll", "<CMD>Trouble lsp_document_symbols toggle<CR>", { desc = "LSP symbols" })
map("n", "<leader>ld", "<CMD>Trouble lsp_references toggle<CR>", { desc = "LSP references" })

-- avante
map("n", "<leader>aa", "<CMD>AvanteToggle<CR>", { desc = "Avante" })

-- undo
map("n", "<leader>fu", "<CMD>UndotreeToggle<CR>", { desc = "Undo" })

-- neogit
map("n", "<leader>gg", "<CMD>Neogit<CR>", { desc = "Neogit" })
