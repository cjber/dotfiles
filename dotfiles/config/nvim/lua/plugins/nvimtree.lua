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

-- Mappings for nvimtree


vim.g.nvim_tree_bindings = {
    ['<CR>'] = get_lua_cb('edit'),
    ['o'] = get_lua_cb('edit'),
    ['<2-LeftMouse>'] = get_lua_cb('edit'),
    ['<2-RightMouse>'] = get_lua_cb('cd'),
    ['<C-]>'] = get_lua_cb('cd'),
    ['<C-v>'] = get_lua_cb('vsplit'),
    ['<C-x>'] = get_lua_cb('split'),
    ['<C-t>'] = get_lua_cb('tabnew'),
    ['<BS>'] = get_lua_cb('close_node'),
    ['<S-CR>'] = get_lua_cb('close_node'),
    ['<Tab>'] = get_lua_cb('preview'),
    ['I'] = get_lua_cb('toggle_ignored'),
    ['H'] = get_lua_cb('toggle_dotfiles'),
    ['R'] = get_lua_cb('refresh'),
    ['a'] = get_lua_cb('create'),
    ['d'] = get_lua_cb('remove'),
    ['r'] = get_lua_cb('rename'),
    ['<C-r>'] = get_lua_cb('full_rename'),
    ['x'] = get_lua_cb('cut'),
    ['c'] = get_lua_cb('copy'),
    ['p'] = get_lua_cb('paste'),
    ['[c'] = get_lua_cb('prev_git_item'),
    [']c'] = get_lua_cb('next_git_item'),
    ['-'] = get_lua_cb('dir_up'),
    ['q'] = get_lua_cb('close')
}
