local cmd = vim.cmd
local g = vim.g

-- load plugins
require('plugins')
require('settings')
require('mappings')
require('autocmds')

-- colorscheme settings
g.tokyonight_style = 'night'
g.tokyonight_hide_inactive_statusline = false
g.tokyonight_dark_sidebar = false

cmd 'colorscheme tokyonight'
cmd 'syntax enable'

require('colorscheme')

-- python config
g.python_host_skip_check = 1
g.loaded_python_provider = 0
g.python3_host_skip_check = 1

g.python3_host_prog = '/home/cjber/.virtualenvs/nvim/bin/python'

-- indentline
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_current_context = true

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

-- vimtex
g.vimtex_compiler_progname = 'nvr'
g.vimtex_view_method = 'zathura'

-- doge
g.doge_doc_standard_python = 'numpy'
