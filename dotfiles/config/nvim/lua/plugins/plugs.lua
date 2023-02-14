local plugins = {
	{ "wbthomason/packer.nvim" },
	{ "noib3/nvim-cokeline" },
	{ "nvim-lualine/lualine.nvim" },
	{ "ray-x/lsp_signature.nvim" },
	{ "direnv/direnv.vim" },
	{
		"nvim-telescope/telescope.nvim",
		req = { { "nvim-lua/plenary.nvim" } },
	},
	{ "goolord/alpha-nvim" },

	{ "quarto-dev/quarto-nvim", dependencies = { "jmbuhr/otter.nvim" } },
	{ "kyazdani42/nvim-web-devicons" },
	{ "kyazdani42/nvim-tree.lua", tag = "nightly" },

	{ "ahmedkhalf/project.nvim" }, -- projects
	{ "lukas-reineke/headlines.nvim" }, -- add header highlights for md qmd etc

	{ "lewis6991/impatient.nvim" }, -- faster loading
	{ "vim-pandoc/vim-pandoc-syntax" },
	{ "quarto-dev/quarto-vim" },
	{ "Pocco81/auto-save.nvim" }, -- autosave
	-- { "Konfekt/FastFold" }, -- better folds
	{ "numToStr/Comment.nvim" },
	{ "folke/trouble.nvim" }, -- better lsp error search
	{ "folke/neodev.nvim" }, -- lua dev stuff
	{ "folke/todo-comments.nvim" },
	{ "folke/tokyonight.nvim" }, -- theme
	{ "folke/which-key.nvim" }, -- visualise bindings
	{ -- auto completions
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
			"hrsh7th/vim-vsnip-integ",
			"hrsh7th/cmp-cmdline",
			"lukas-reineke/cmp-under-comparator",
		},
	},
	{ "jalvesaq/vimcmdline" }, -- repl
	{ "danymat/neogen" },
	{ "lervag/vimtex" }, -- latex tools
	{ "lukas-reineke/indent-blankline.nvim" }, -- indent guide
	{ "neovim/nvim-lspconfig" }, -- language servers
	{ "norcalli/nvim-colorizer.lua" }, -- highlight colours
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }, -- syntax highlight
	{ "nvim-treesitter/nvim-treesitter-textobjects" }, -- treesitter movements
	{ "onsails/lspkind-nvim" }, -- lsp symbols
	{ "simrat39/symbols-outline.nvim" },
	{ "mbbill/undotree" }, -- undo tree
	{ "tpope/vim-dispatch" }, -- dispatch commands
	{ "tpope/vim-repeat" }, -- repeat plugin cmds (including lightspeed)
	{ "kylechui/nvim-surround" }, -- change around brackets etc
	{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" }, -- better folding
	{ "tweekmonster/startuptime.vim" }, -- benchmark nvim startup
	{ "windwp/nvim-autopairs" }, -- pairs
	{ "rafamadriz/friendly-snippets" }, -- default snippets
	{ "numToStr/FTerm.nvim" }, -- floating terminal
	{ "petertriho/nvim-scrollbar" }, -- scrollbar with diagnostics
	{ "kevinhwang91/nvim-hlslens" }, -- hl matches
	{ "kazhala/close-buffers.nvim" }, -- buffer close commands
	{ "jose-elias-alvarez/null-ls.nvim" }, -- other lsp
	{ "LostNeophyte/null-ls-embedded" },
	{ "dbeniamine/todo.txt-vim" }, -- todo.txt highlighting
	{ "simrat39/rust-tools.nvim" },
	{ "saecki/crates.nvim" },
	{ "phaazon/hop.nvim" },
	{ "barreiroleo/ltex_extra.nvim" },
}

require("lazy").setup(plugins)
