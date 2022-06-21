require("plugins.plugs") -- load plugins
require("plugins.treesitter") -- syntax
require("plugins.telescope") -- interactive search
require("plugins.nvimtree") -- file browser
-- require("plugins.bufferline") -- show butters as tabline
require("plugins.alpha") -- welcome screen

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
local get_hex = require("cokeline/utils").get_hex

require("cokeline").setup({
	default_hl = {
		fg = function(buffer)
			return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
		end,
		bg = colors.bg_dark,
	},

	components = {
		{
			text = " ",
			bg = get_hex("Normal", "bg"),
		},
		{
			text = "",
			fg = colors.bg_dark,
			bg = get_hex("Normal", "bg"),
		},
		{
			text = function(buffer)
				return buffer.devicon.icon
			end,
			fg = function(buffer)
				return buffer.devicon.color
			end,
		},
		{
			text = " ",
		},
		{
			text = function(buffer)
				return buffer.filename .. "  "
			end,
			style = function(buffer)
				return buffer.is_focused and "bold" or nil
			end,
		},
		{
			text = "",
			fg = colors.bg_dark,
			bg = get_hex("Normal", "bg"),
		},
	},
})
