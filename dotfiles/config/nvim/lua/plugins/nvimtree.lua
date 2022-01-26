require('nvim-tree').setup {
    disable_netrw = true,
    hijack_netrw = true,
    auto_close = true,
    update_cwd = true,
    nvim_tree_hide_dotfiles = true,
    nvim_tree_ignore = {'.git', 'node_modules', '.cache'},
    git = {ignore = false}
}

vim.g.nvim_tree_quit_on_open = 0
vim.g.nvim_tree_indent_markers = 0
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_root_folder_modifier = ':~'
vim.g.nvim_tree_allow_resize = 1

vim.g.nvim_tree_show_icons = {git = 0, folders = 1, files = 0}
vim.g.nvim_tree_icons = {
    default = '  ',
    folder = {default = '', open = '', empty = '', empty_open = ''}
}
