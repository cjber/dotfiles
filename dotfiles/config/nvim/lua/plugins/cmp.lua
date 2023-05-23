local cmp = require("cmp")

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
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
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
