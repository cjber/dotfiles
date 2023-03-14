return {
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--no-ignore-vcs",
		},
		prompt_prefix = ":: ",
		selection_caret = "| ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "ascending",
		layout_strategy = "bottom_pane",
		layout_config = {
			horizontal = { mirror = false, preview_width = 0.5 },
			vertical = { mirror = false, preview_height = 0.5 },
			width = 0.75,
			prompt_position = "bottom",
			preview_cutoff = 40,
		},
		winblend = 0,
		border = true,
		borderchars = {
			prompt = { "─", " ", "─", " ", " ", " ", " ", " " },
			results = { "─", " ", " ", " ", " ", " ", " ", " " },
			preview = { "─", " ", " ", " ", " ", " ", " ", " " },
		},
		color_devicons = true,
	},

	pickers = {
		find_files = {
			-- literally can't get {data,logs} to work
			find_command = {
				"fd",
				"--type",
				"f",
				"--strip-cwd-prefix",
				"--no-ignore",
				"--exclude=data",
				"--exclude=logs",
				"--exclude=*.docx",
				"--exclude=*.pdf",
			},
		},
	},
}
