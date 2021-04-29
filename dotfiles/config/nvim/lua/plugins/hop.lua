vim.o.termguicolors = true

-- colors for active , inactive buffer tabs
require'bufferline'.setup {
    options = {
        show_close_icon = false,
        show_buffer_close_icons = false,
        view = 'multiwindow',
        modified_icon = '●',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 18,
        tab_size = 18,
        enforce_regular_tabs = true,
        separator_style = 'thin'

    },
    highlights = {
        background = {guifg = comment_fg, guibg = '#1a1b26'},
        fill = {guifg = comment_fg, guibg = '#1a1b26'},
        buffer_selected = {guifg = normal_fg, guibg = '#1a1b26', gui = 'bold'},
        separator_visible = {guifg = '#1a1b26', guibg = '#1a1b26'},
        separator_selected = {guifg = '#1a1b26', guibg = '#1a1b26'},
        separator = {guifg = '#1a1b26', guibg = '#1a1b26'},
        indicator_selected = {guifg = '#1a1b26', guibg = '#1a1b26'},
        modified_selected = {guifg = string_fg, guibg = '#1a1b26'}
    }
}
vim.api
    .nvim_set_keymap('n', 's', '<cmd>lua require\'hop\'.hint_words()<cr>', {})
