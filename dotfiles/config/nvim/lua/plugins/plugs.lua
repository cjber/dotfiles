local plugins = {
	{ "wbthomason/packer.nvim" },

	{ "kaarmu/typst.vim", ft = "typst", lazy = false },
	-- {
	-- 	"stevearc/aerial.nvim",
	-- 	config = function()
	-- 		require("aerial").setup()
	-- 	end,
	-- },

	-- LSP
	{
		"VonHeikemen/lsp-zero.nvim",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "jose-elias-alvarez/null-ls.nvim", dependencies = { "LostNeophyte/null-ls-embedded" } },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "jay-babu/mason-null-ls.nvim", event = { "BufReadPre", "BufNewFile" } },
			{ "barreiroleo/ltex_extra.nvim" },

			-- Autocompletion
			{
				"hrsh7th/nvim-cmp",
				opts = function()
					local has_words_before = function()
						unpack = unpack or table.unpack
						local line, col = unpack(vim.api.nvim_win_get_cursor(0))
						return col ~= 0
							and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
								== nil
					end

					local luasnip = require("luasnip")
					local cmp = require("cmp")
					return {
						completion = { keyword_length = 2 },
						snippet = {
							expand = function(args)
								require("luasnip").lsp_expand(args.body)
							end,
						},
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
						mapping = cmp.mapping.preset.insert({
							["<C-b>"] = cmp.mapping.scroll_docs(-4),
							["<C-f>"] = cmp.mapping.scroll_docs(4),
							["<C-Space>"] = cmp.mapping.complete(),
							["<C-e>"] = cmp.mapping.abort(),
							["<CR>"] = cmp.mapping.confirm({ select = false }),
							["<Tab>"] = cmp.mapping(function(fallback)
								if cmp.visible() then
									cmp.select_next_item()
								elseif luasnip.expand_or_jumpable() then
									luasnip.expand_or_jump()
								elseif has_words_before() then
									cmp.complete()
								else
									fallback()
								end
							end, { "i", "s" }),

							["<S-Tab>"] = cmp.mapping(function(fallback)
								if cmp.visible() then
									cmp.select_prev_item()
								elseif luasnip.jumpable(-1) then
									luasnip.jump(-1)
								else
									fallback()
								end
							end, { "i", "s" }),
						}),
						sources = {
							{ name = "nvim_lsp" },
							-- { name = "otter" },
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
				end,
			},
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lua" },
			{
				"garyhurtz/cmp_kitty",
				init = function()
					require("cmp_kitty"):setup()
				end,
			},
			-- {
			-- 	"huggingface/hfcc.nvim",
			-- 	opts = {
			-- 		api_token = "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",
			-- 		-- model = "bigcode/starcoder", -- can be a model ID or an http endpoint
			-- 	},
			-- },

			-- Snippets
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
				opts = function()
					require("luasnip.loaders.from_vscode").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snips/" } })
				end,
				dependencies = { "rafamadriz/friendly-snippets" },
			},
			{ "rafamadriz/friendly-snippets" },
		},
	},
	-- {
	-- 	"ray-x/lsp_signature.nvim",
	-- 	opts = {
	-- 		doc_lines = 0,
	-- 		bind = true,
	-- 		handler_opts = {
	-- 			border = "single",
	-- 		},
	-- 		hint_prefix = "  ",
	-- 		-- hint_inline = true,
	-- 	},
	-- },

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({ suggestion = { auto_trigger = true, keymap = { accept = "<Right>" } } })
		end,
	},
	{
		"noib3/nvim-cokeline",
		init = function()
			local get_hex = require("cokeline/utils").get_hex
			require("cokeline").setup({
				default_hl = {
					fg = function(buffer)
						return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
					end,
					bg = "NONE",
				},
				components = {
					{
						text = function(buffer)
							return " " .. buffer.devicon.icon
						end,
						fg = function(buffer)
							return buffer.devicon.color
						end,
					},
					{
						text = function(buffer)
							return buffer.unique_prefix
						end,
						fg = get_hex("Comment", "fg"),
						style = "italic",
					},
					{
						text = function(buffer)
							return buffer.filename .. " "
						end,
					},
					{
						text = " ",
					},
				},
			})
		end,
	},
	-- { "nvim-lualine/lualine.nvim" },
	-- { "direnv/direnv.vim" },
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },

		config = function()
			require("fzf-lua").setup()
		end,
	},
	-- {
	-- 	"nvim-telescope/telescope.nvim",
	-- 	dependencies = { { "nvim-lua/plenary.nvim" } },
	-- 	opts = require("plugins.telescope"),
	-- 	init = function()
	-- 		require("telescope").load_extension("projects")
	-- 		require("telescope").load_extension("aerial")
	-- 	end,
	-- },
	-- { "kyazdani42/nvim-tree.lua", tag = "nightly", opts = {} },
	{
		"ahmedkhalf/project.nvim",
		init = function()
			require("project_nvim").setup({ silent_chdir = true, detection_methods = { "pattern" } })
		end,
	}, -- projects
	{
		"lukas-reineke/headlines.nvim",
		after = "nvim-treesitter",
		config = function()
			require("headlines").setup({
				quarto = {
					query = vim.treesitter.query.parse(
						"markdown",
						[[
                (atx_heading [
                    (atx_h1_marker)
                    (atx_h2_marker)
                    (atx_h3_marker)
                    (atx_h4_marker)
                    (atx_h5_marker)
                    (atx_h6_marker)
                ] @headline)
                (thematic_break) @dash
                (fenced_code_block) @codeblock
                (block_quote_marker) @quote
                (block_quote (paragraph (inline (block_continuation) @quote)))
            ]]
					),
					treesitter_language = "markdown",
					headline_highlights = { "Headline" },
					codeblock_highlight = "CodeBlock",
					dash_highlight = "Dash",
					dash_string = "-",
					quote_highlight = "Quote",
					quote_string = "┃",
					fat_headlines = false,
					fat_headline_upper_string = "▃",
					fat_headline_lower_string = "🬂",
				},
				markdown = { fat_headlines = false },
			})
		end,
	}, -- add header highlights for md qmd etc

	-- {
	-- 	"jmbuhr/otter.nvim",
	-- 	opts = { lsp = {
	-- 		hover = {
	-- 			border = "single",
	-- 		},
	-- 	} },
	-- },
	-- {
	-- 	"quarto-dev/quarto-nvim",
	-- 	ft = "quarto",
	-- 	dependencies = {
	-- 		"neovim/nvim-lspconfig",
	-- 	},
	-- 	init = function()
	-- 		-- vim.opt.conceallevel = 1
	-- 		-- vim.g["pandoc#syntax#conceal#use"] = false
	-- 		-- vim.g["pandoc#syntax#codeblocks#embeds#use"] = false
	-- 		-- vim.g["pandoc#syntax#conceal#blacklist"] = { "codeblock_delim", "codeblock_start" }
	-- 		-- vim.g["tex_conceal"] = "gm"
	--
	-- 		require("quarto").setup({
	-- 			lspFeatures = {
	-- 				enabled = false,
	-- 				languages = { "python" },
	-- 				chunks = "all", -- 'curly' or 'all'
	-- 				diagnostics = {
	-- 					enabled = false,
	-- 					triggers = { "BufWrite" },
	-- 				},
	-- 				completion = {
	-- 					enabled = false,
	-- 				},
	-- 			},
	-- 			keymap = { hover = "<C-K>" },
	-- 		})
	-- 	end,
	-- },
	{ "Pocco81/auto-save.nvim", opts = { execution_message = { message = "" } } }, -- autosave
	{ "Konfekt/FastFold" }, -- better folds
	{ "numToStr/Comment.nvim", opts = {} },
	{ "folke/trouble.nvim", opts = {} }, -- better lsp error search
	{ "folke/neodev.nvim" }, -- lua dev stuff
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
		},
	}, -- theme
	{ "folke/which-key.nvim", opts = {} }, -- visualise bindings
	{ "jalvesaq/vimcmdline" }, -- repl
	{ "danymat/neogen" },
	{ "lervag/vimtex" }, -- latex tools
	{
		"lukas-reineke/indent-blankline.nvim",
		opts = {
			show_current_context = true,
			show_current_context_start = false,
			char = "▎",
			show_first_indent_level = false,
		},
	}, -- indent guide
	{
		"nvim-treesitter/nvim-treesitter",
		build = "TSUpdate",
		init = function()
			require("plugins.treesitter")
		end,
	}, -- syntax highlight
	{ "nvim-treesitter/nvim-treesitter-textobjects" }, -- treesitter movements
	{ "mbbill/undotree" }, -- undo tree
	{ "tpope/vim-dispatch" }, -- dispatch commands
	{ "tpope/vim-repeat" }, -- repeat plugin cmds (including lightspeed)
	{ "kylechui/nvim-surround", opts = {} }, -- change around brackets etc
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		init = function()
			require("plugins.ufo")
		end,
	}, -- better folding
	{ "tweekmonster/startuptime.vim" }, -- benchmark nvim startup
	{ "windwp/nvim-autopairs", opts = {} }, -- pairs
	{ "numToStr/FTerm.nvim" }, -- floating terminal
	{ "kevinhwang91/nvim-hlslens", opts = {} }, -- hl matches
	{ "kazhala/close-buffers.nvim", opts = {} }, -- buffer close commands
	{ "dbeniamine/todo.txt-vim" }, -- todo.txt highlighting
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	{ "smoka7/hop.nvim", opts = {} },
}

require("lazy").setup(plugins)
