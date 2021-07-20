vim.o.termguicolors = true

vim.g.nvim_tree_side = 'left'
vim.g.nvim_tree_width = 30
vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
vim.g.nvim_tree_auto_open = 0
vim.g.nvim_tree_auto_close = 0
vim.g.nvim_tree_quit_on_open = 0
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_indent_markers = 0
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_root_folder_modifier = ':~'
vim.g.nvim_tree_tab_open = 1
vim.g.nvim_tree_allow_resize = 1

vim.g.nvim_tree_show_icons = {git = 0, folders = 1, files = 0}
vim.g.nvim_tree_icons = {
    default = '  ',
    folder = {default = '', open = '', empty = '', empty_open = ''}
}

local get_lua_cb = function(cb_name)
    return string.format(':lua require\'nvim-tree\'.on_keypress(\'%s\')<CR>',
                         cb_name)
end
