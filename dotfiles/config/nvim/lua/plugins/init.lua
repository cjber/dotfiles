local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({
		"git",
		"clone",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	execute("packadd packer.nvim")
end

require("plugins.plugs") -- load plugins
require("plugins.treesitter") -- syntax
require("plugins.telescope") -- interactive search
require("plugins.nvimtree") -- file browser
-- require("plugins.bufferline") -- show butters as tabline
require("plugins.alpha") -- welcome screen

require("incline").setup({
	debounce_threshold = {
		falling = 50,
		rising = 10,
	},
	hide = {
		cursorline = false,
		focused_win = false,
		only_win = false,
	},
	highlight = {
		groups = {
			InclineNormal = {
				default = true,
				group = "NormalFloat",
			},
			InclineNormalNC = {
				default = true,
				group = "NormalFloat",
			},
		},
	},
	ignore = {
		buftypes = "special",
		filetypes = {},
		floating_wins = true,
		unlisted_buffers = true,
		wintypes = "special",
	},
	render = "basic",
	window = {
		margin = {
			horizontal = 1,
			vertical = 1,
		},
		options = {
			signcolumn = "no",
			wrap = false,
		},
		padding = 1,
		padding_char = " ",
		placement = {
			horizontal = "right",
			vertical = "top",
		},
		width = "fit",
		winhighlight = {
			active = {
				EndOfBuffer = "None",
				Normal = "InclineNormal",
				Search = "None",
			},
			inactive = {
				EndOfBuffer = "None",
				Normal = "InclineNormalNC",
				Search = "None",
			},
		},
		zindex = 50,
	},
})

-- lsp configs
require("plugins.langconfig") -- lsp config
require("plugins.cmp") -- lsp config
require("plugins.textobjects") -- Move in functions etc

-- require("copilot").setup()

-- misc
require("lightspeed").setup({ ignore_case = true })
require("nvim-autopairs").setup({})
require("fidget").setup({ text = {
	spinner = "dots",
} }) -- show lsp progress

require("trouble").setup() -- diagnostic results window etc
require("Comment").setup()
require("colorizer").setup({ "*" }, { mode = "foreground" })
require("which-key").setup()
require("autosave").setup()
require("project_nvim").setup({ silent_chdir = true })

-- vim.fn.sign_define("Headline1", { linehl = "Headline1" })
-- vim.fn.sign_define("Headline2", { linehl = "Headline2" })

require("headlines").setup({
	rmd = {
		source_pattern_start = "^```{.*",
		source_pattern_end = "^```$",
		dash_pattern = "^---+$",
		headline_pattern = "^#+ [A-Z]",
		headline_highlights = { "Headline", "Headline1", "Headline2" },
		codeblock_highlight = "CodeBlock",
		dash_highlight = "Dash",
		dash_string = "-",
		-- fat_headlines = true,
	},
	quarto = {
		source_pattern_start = "^```{.*",
		source_pattern_end = "^```$",
		dash_pattern = "^---+$",
		headline_pattern = "^#+ [A-Z]",
		headline_highlights = { "Headline", "Headline1", "Headline2" },
		codeblock_highlight = "CodeBlock",
		dash_highlight = "Dash",
		dash_string = "-",
		-- fat_headlines = true,
	},
})

-- custom notification for square border
local stages_util = require("notify.stages.util")
require("notify").setup({
	timeout = 200,
	stages = {
		function(state)
			local next_height = state.message.height + 2
			local next_row = stages_util.available_row(state.open_windows, next_height)
			if not next_row then
				return nil
			end
			return {
				relative = "editor",
				anchor = "NE",
				width = state.message.width,
				height = state.message.height,
				col = vim.opt.columns:get(),
				row = next_row,
				border = "single",
				style = "minimal",
				opacity = 0,
			}
		end,
		function()
			return { opacity = { 100 }, col = { vim.opt.columns:get() } }
		end,
		function()
			return { col = { vim.opt.columns:get() }, time = true }
		end,
		function()
			return {
				opacity = {
					0,
					frequency = 2,
					complete = function(cur_opacity)
						return cur_opacity <= 4
					end,
				},
				col = { vim.opt.columns:get() },
			}
		end,
	},
})

vim.cmd([[
let g:dbs = { 'cjber': 'postgres://postgres:cjber@localhost:5432/cjber'}
let g:db_ui_auto_execute_table_helpers = 1
let g:db_ui_use_nerd_fonts = 1
]])

require("neogen").setup() -- add docstrings

require("scrollbar.handlers.search").setup()
local colors = require("tokyonight.colors").setup()
require("scrollbar").setup({
	handlers = { diagnostic = true, search = true },
	handle = { color = colors.bg_highlight },
	marks = {
		Search = { color = colors.orange },
		Error = { color = colors.error },
		Warn = { color = colors.warning },
		Info = { color = colors.info },
		Hint = { color = colors.hint },
		Misc = { color = colors.purple },
	},
})
