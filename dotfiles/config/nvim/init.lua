local cmd = vim.cmd
local g = vim.g

-- load plugins
require('plugins')
require('settings')
require('mappings')
require('autocmds')

-- colorscheme settings
g.tokyonight_style = 'night'
g.tokyonight_hide_inactive_statusline = true
g.tokyonight_dark_sidebar = false

cmd 'colorscheme tokyonight'
cmd 'syntax enable'

require('colorscheme')

-- auto save
g.auto_save = 1
g.auto_save_in_insert_mode = 0
g.auto_save_silent = 1

-- python config
g.python_host_skip_check = 1
g.loaded_python_provider = 0
g.python3_host_skip_check = 1
g.python3_host_prog = '/home/cjber/.virtualenvs/nvim/bin/python'

-- indentline
g.indent_blankline_show_first_indent_level = false
g.indent_blankline_buftype_exclude = {'terminal'}
g.indent_blankline_bufname_exclude = {'', 'man:.*', 'NvimTree'}
g.indent_blankline_char = '┋'

-- nvim r
g.markdown_fenced_languages = {'r', 'python'}
g.rmd_fenced_languages = {'r', 'python'}

-- vimcmdline
g.cmdline_follow_colorscheme = 1
g.cmdline_esc_term = 0
g.cmdline_map_send = '<CR>'
g.cmdline_app = {['python'] = 'ipython'}

-- mundo
g.mundo_preview_bottom = 1
g.mundo_verbose_graph = 0
g.mundo_width = 32

-- rooter
g.rooter_patterns = {'.git', '*.toml'}
g.rooter_targets = '*.py,*.R,*.Rmd'

-- startify
g.startify_lists = {
    {type = 'dir', header = {'MRU ' .. vim.fn.getcwd()}},
    {type = 'files', header = {'MRU'}}
}

-- focus
require('focus').width = 1
require('focus').height = 35
require('focus').signcolumn = false
