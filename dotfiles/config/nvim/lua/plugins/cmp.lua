return {
	window = {
		completion = {
			border = "single",
			winhighlight = "NormalFloat:NormalFloat,Title:NormalFloat",
			col_offset = -3,
			side_padding = 0,
		},
		documentation = {
			border = "single",
			winhighlight = "NormalFloat:NormalFloat,Title:NormalFloat",
		},
	},
	completion = { keyword_length = 1 },
	sources = {
		{ name = "nvim_lsp" },
		{ name = "otter" },
		{ name = "luasnip" },
		{ name = "kitty", option = { listen_on = vim.env.KITTY_LISTEN_ON } },
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{
			name = "path",
			option = {
				get_cwd = function()
					return vim.fn.expand(vim.fn.getcwd())
				end,
			},
		},
	},
}
--
-- cmp.setup.cmdline({ "/", "?" }, {
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = {
--         { name = "buffer" },
--     },
-- })
--
-- cmp.setup.cmdline(":", {
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = cmp.config.sources({
--         { name = "path" },
--     }, {
--         { name = "cmdline" },
--     }),
-- })
