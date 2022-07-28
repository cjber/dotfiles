local ts_config = require("nvim-treesitter.configs")

ts_config.setup({
	ensure_installed = "all",
	highlight = { enable = true, use_languagetree = true },
	indent = { enable = false }, -- sometimes breaks
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
})
require("nvim-treesitter.configs").setup({
	textobjects = {
		move = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = { ["<M-j>"] = "@function.outer" },
			goto_previous_start = { ["<M-k>"] = "@function.outer" },
		},
	},
	yati = { enable = false },
})

-- require("ufo").setup({
-- 	provider_selector = function(bufnr, filetype)
-- 		return { "treesitter", "indent" }
-- 	end,
-- })
