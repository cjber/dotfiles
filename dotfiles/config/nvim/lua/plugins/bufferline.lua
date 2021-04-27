vim.o.termguicolors = true

-- colors for active , inactive buffer tabs
require'bufferline'.setup {
    options = {
        show_close_icon=false,
        show_buffer_close_icons=false,
        view = 'multiwindow',
        modified_icon = '●',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 18,
        tab_size = 18,
        enforce_regular_tabs = true,
        show_buffer_close_icons = true,
        separator_style = 'thin'

    },
    highlights = {
        background = {guifg = comment_fg, guibg = '#1E2127'},
        fill = {guifg = comment_fg, guibg = '#1E2127'},
        buffer_selected = {guifg = normal_fg, guibg = '#1E2127', gui = 'bold'},
        separator_visible = {guifg = '#1E2127', guibg = '#1E2127'},
        separator_selected = {guifg = '#1E2127', guibg = '#1E2127'},
        separator = {guifg = '#1E2127', guibg = '#1E2127'},
        indicator_selected = {guifg = '#1E2127', guibg = '#1E2127'},
        modified_selected = {guifg = string_fg, guibg = '#1E2127'}
    }
}
