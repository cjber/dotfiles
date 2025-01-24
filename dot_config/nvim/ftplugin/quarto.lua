-- keymaps
vim.api.nvim_set_keymap(
  "n",
  "<Leader>kk",
  ":term quarto render %:p --execute-dir $PWD<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<Leader>kp", ":silent! !zathura %:r.pdf &<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<CR>", "<CMD>REPLSendLine<CR>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>cl", "<CMD>REPLStart ipython<CR>:wincmd p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>c;", "<CMD>REPLToCurLine<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>cd", "<CMD>REPLHideOrFocus<CR>:wincmd p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<CR>", "<CMD>REPLSendVisual<CR>", { noremap = true, silent = true })

vim.opt.spell = true
