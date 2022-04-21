local colors = require("colors")

require("bufferline").setup({
	options = {
		numbers = "none",
		show_buffer_close_icons = false,
		show_close_icon = false,
		separator_style = "slant",
	},

	highlights = {
		background = { guifg = colors.fg_dark, guibg = colors.bg },
		fill = { guifg = colors.bg, guibg = colors.bg },
		separator = { guifg = colors.bg, guibg = colors.bg },
		separator_selected = { guifg = colors.bg, guibg = colors.bg },
		separator_visible = { guifg = colors.bg, guibg = colors.bg },
		buffer_selected = {
			guifg = colors.green,
			guibg = colors.bg,
			gui = "italic",
		},
	},
})
