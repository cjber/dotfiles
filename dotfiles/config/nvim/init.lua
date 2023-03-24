local cmd = vim.cmd
local g = vim.g

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("settings")
require("plugins")

require("impatient")
require("mappings")
require("autocmds")

cmd("colorscheme tokyonight")
cmd("syntax enable")

require("colorscheme")

g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- python config
g.python_host_skip_check = 1
g.loaded_python_provider = 0
g.python3_host_skip_check = 1

g.python3_host_prog = "/home/cjber/dotfiles/.direnv/python-3.10.10/bin/python"

-- nvim r
g.markdown_fenced_languages = { "r", "python" }
g.rmd_fenced_languages = { "r", "python" }

-- vimcmdline
g.cmdline_follow_colorscheme = 1
g.cmdline_esc_term = 0
g.cmdline_map_send = "<CR>"
g.cmdline_app = { ["python"] = "ipython", ["qmd"] = "ipython", ["rmd"] = "r" }

-- mundo
g.mundo_preview_bottom = 1
g.mundo_verbose_graph = 0
g.mundo_width = 32

-- vimtex
g.vimtex_compiler_progname = "nvr"
g.vimtex_view_method = "zathura"
g.vimtex_compiler_method = "latexrun"

-- zotcite
-- cmd([[let $ZCitationTemplate = "{author}{year}"]])
