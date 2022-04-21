local cmp = require("cmp")

cmp.setup({
	window = {
		completion = {
			border = "single",
			winhighlight = "NormalFloat:NormalFloat,Title:NormalFloat",
		},

		documentation = {
			border = "single",
			winhighlight = "NormalFloat:NormalFloat,Title:NormalFloat",
		},
	},
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = {
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = false,
		}),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "cmp_tabnine" },
		{ name = "vsnip" },
		{ name = "buffer" },
		{ name = "dictionary", keyword_length = 2 },
		{
			name = "path",
			option = {
				get_cwd = function()
					return vim.fn.expand(vim.fn.getcwd())
				end,
			},
		},
		{ name = "crates" },
	},
	sorting = {
		comparators = {
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.score,
			require("cmp-under-comparator").under,
			cmp.config.compare.kind,
			cmp.config.compare.sort_text,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
	formatting = {
		format = require("lspkind").cmp_format({
			mode = "symbol",
			maxwidth = 50,
			symbols = "mdi",
		}),
	},
})

require("cmp_tabnine.config"):setup({
	max_lines = 1000,
	max_num_results = 20,
	sort = true,
	show_prediction_strength = true,
})

require("cmp_dictionary").setup({
	dic = {
		["*"] = { "/usr/share/dict/gb_english.dic" },
		filename = {
			["xmake.lua"] = { "path/to/xmake.dic", "path/to/lua.dic" },
		},
		filepath = {
			["%.tmux.*%.conf"] = "path/to/tmux.dic",
		},
	},
	-- The following are default values, so you don't need to write them if you don't want to change them
	exact = 2,
	first_case_insensitive = false,
	async = false,
	capacity = 5,
	debug = false,
})

vim.cmd([[
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]])
