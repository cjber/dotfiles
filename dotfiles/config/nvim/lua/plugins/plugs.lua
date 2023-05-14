local plugins = {
	{ "wbthomason/packer.nvim" },

	{
		"kaarmu/typst.vim",
		ft = "typst",
		lazy = false,
	},

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
				opts = require("plugins.cmp"),
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
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				init = function()
					require("copilot").setup({
						suggestion = { auto_trigger = true, keymap = { accept = "<C-l>", next = "<C-j>" } },
					})
				end,
			},
			{
				"huggingface/hfcc.nvim",
				opts = {
					api_token = "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",
					-- model = "bigcode/starcoder", -- can be a model ID or an http endpoint
				},
			},

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },

			-- Navigation
			{
				"SmiteshP/nvim-navbuddy",
				dependencies = { "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim" },
				opts = { lsp = { auto_attach = true } },
			},
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		opts = {
			doc_lines = 0,
			bind = true,
			handler_opts = {
				border = "single",
			},
			hint_prefix = "  ",
		},
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
	{ "direnv/direnv.vim" },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { { "nvim-lua/plenary.nvim" } },
		opts = require("plugins.telescope"),
		init = function()
			require("telescope").load_extension("projects")
		end,
	},
	{ "kyazdani42/nvim-web-devicons" },
	{ "kyazdani42/nvim-tree.lua", tag = "nightly", opts = {} },
	{
		"ahmedkhalf/project.nvim",
		init = function()
			require("project_nvim").setup({ silent_chdir = true })
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

	{ "lewis6991/impatient.nvim" }, -- faster loading
	{
		"quarto-dev/quarto-nvim",
		version = "0.7.3",
		ft = "quarto",
		dependencies = {
			"neovim/nvim-lspconfig",
			{
				"jmbuhr/otter.nvim",
				version = "0.8.1",
				init = function()
					require("otter.config").setup()
				end,
			},
			{
				"quarto-dev/quarto-vim",
				ft = "quarto",
				dependencies = { "vim-pandoc/vim-pandoc-syntax" },
			},
		},
		init = function()
			vim.opt.conceallevel = 1
			vim.g["pandoc#syntax#conceal#use"] = false
			vim.g["pandoc#syntax#codeblocks#embeds#use"] = false
			vim.g["pandoc#syntax#conceal#blacklist"] = { "codeblock_delim", "codeblock_start" }
			vim.g["tex_conceal"] = "gm"

			require("quarto").setup({
				lspFeatures = {
					enabled = true,
					languages = { "r", "python" },
					chunks = "curly", -- 'curly' or 'all'
					diagnostics = {
						enabled = true,
						triggers = { "BufWrite" },
					},
					completion = {
						enabled = true,
					},
				},
				keymap = { hover = "<C-K>" },
			})
		end,
	},
	{ "Pocco81/auto-save.nvim", opts = { execution_message = { message = "" } } }, -- autosave
	-- { "Konfekt/FastFold" }, -- better folds
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
		run = ":TSUpdate",
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
	{ "phaazon/hop.nvim", opts = {} },
}

require("lazy").setup(plugins)
