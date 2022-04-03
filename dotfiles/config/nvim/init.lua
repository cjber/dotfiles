local cmd = vim.cmd
local g = vim.g

-- g.do_filetype_lua = 1
-- g.did_load_filetypes = 0

require("settings")

-- load plugins
require("plugins")
vim.notify = require("notify")
require("mappings")
require("autocmds")

-- colorscheme settings
g.tokyonight_style = "night"
g.tokyonight_hide_inactive_statusline = false
g.tokyonight_dark_sidebar = false

cmd("colorscheme tokyonight")
cmd("syntax enable")

require("colorscheme")

-- python config
g.python_host_skip_check = 1
g.loaded_python_provider = 0
g.python3_host_skip_check = 1

g.python3_host_prog = "/home/cjber/dotfiles/.direnv/python-3.10.1/bin/python"

-- indentline
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_current_context = true

g.indent_blankline_show_first_indent_level = false
g.indent_blankline_buftype_exclude = { "terminal" }
g.indent_blankline_bufname_exclude = { "", "man:.*", "NvimTree" }
g.indent_blankline_char = "│"

-- nvim r
g.markdown_fenced_languages = { "r", "python" }
g.rmd_fenced_languages = { "r", "python" }

-- vimcmdline
g.cmdline_follow_colorscheme = 1
g.cmdline_esc_term = 0
g.cmdline_map_send = "<CR>"
g.cmdline_app = { ["python"] = "ipython", ["qmd"] = "ipython" }

-- mundo
g.mundo_preview_bottom = 1
g.mundo_verbose_graph = 0
g.mundo_width = 32

-- vimtex
g.vimtex_compiler_progname = "nvr"
g.vimtex_view_method = "zathura"
g.vimtex_compiler_method = "latexrun"
