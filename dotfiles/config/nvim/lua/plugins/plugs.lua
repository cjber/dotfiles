vim.cmd([[packadd packer.nvim]])

require("packer").init({
	display = { compact = true },
})

return require("packer").startup(function()
	use({ "wbthomason/packer.nvim" })
	use({ "noib3/nvim-cokeline" })
	use({ "nvim-lualine/lualine.nvim" })
	use({ "ray-x/lsp_signature.nvim" })
	use({ "direnv/direnv.vim" })

	use({ "quarto-dev/quarto-nvim", requires = { "jmbuhr/otter.nvim" } })
	use({ "kyazdani42/nvim-web-devicons" })
	use({ "kyazdani42/nvim-tree.lua", tag = "nightly" })

	use({ "ahmedkhalf/project.nvim" }) -- projects
	use({ "lukas-reineke/headlines.nvim" }) -- add header highlights for md qmd etc

	use({ "lewis6991/impatient.nvim" }) -- faster loading
	use({ "vim-pandoc/vim-pandoc-syntax" })
	use({ "vim-pandoc/vim-rmarkdown" })
	use({ "cjber/quarto-vim" })
	use({ "Pocco81/auto-save.nvim" }) -- autosave
	use({ "Konfekt/FastFold" }) -- better folds
	use({ "numToStr/Comment.nvim" })
	use({ "folke/trouble.nvim" }) -- better lsp error search
	use({ "folke/neodev.nvim" }) -- lua dev stuff
	use({ "folke/todo-comments.nvim" })
	use({ "folke/tokyonight.nvim" }) -- theme
	use({ "folke/which-key.nvim" }) -- visualise bindings
	use({ -- auto completions
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			"uga-rosa/cmp-dictionary",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
			"hrsh7th/vim-vsnip-integ",
			"lukas-reineke/cmp-under-comparator",
			-- { "tzachar/cmp-tabnine", run = "./install.sh" },
		},
	})
	use({ "jalvesaq/vimcmdline" }) -- repl
	use({ "danymat/neogen" })
	use({ "lervag/vimtex" }) -- latex tools
	use({ "lukas-reineke/indent-blankline.nvim" }) -- indent guide
	use({ "neovim/nvim-lspconfig" }) -- language servers
	use({ "norcalli/nvim-colorizer.lua" }) -- highlight colours
	use({ "nvim-lua/plenary.nvim" })
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- syntax highlight
	use({ "nvim-treesitter/nvim-treesitter-textobjects" }) -- treesitter movements
	use({ "onsails/lspkind-nvim" }) -- lsp symbols
	use({ "simrat39/symbols-outline.nvim" })
	use({ "mbbill/undotree" }) -- undo tree
	use({ "tpope/vim-dispatch" }) -- dispatch commands
	use({ "tpope/vim-repeat" }) -- repeat plugin cmds (including lightspeed)
	use({ "kylechui/nvim-surround" }) -- change around brackets etc
	use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" }) -- better folding
	use({ "tweekmonster/startuptime.vim" }) -- benchmark nvim startup
	use({ "windwp/nvim-autopairs" }) -- pairs
	use({ "rafamadriz/friendly-snippets" }) -- default snippets
	use({ "numToStr/FTerm.nvim" }) -- floating terminal
	use({ "petertriho/nvim-scrollbar" }) -- scrollbar with diagnostics
	use({ "kevinhwang91/nvim-hlslens" }) -- hl matches
	use({ "kazhala/close-buffers.nvim" }) -- buffer close commands
	use({ "jose-elias-alvarez/null-ls.nvim" }) -- other lsp
	use({ "LostNeophyte/null-ls-embedded" })
	-- use({ "j-hui/fidget.nvim" }) -- lsp progress
	use({ "dbeniamine/todo.txt-vim" }) -- todo.txt highlighting
	use({ "simrat39/rust-tools.nvim" })
	use({ "saecki/crates.nvim" })
	use({ "ibhagwan/fzf-lua" })
	use({ "phaazon/hop.nvim" })
	use({ "barreiroleo/ltex_extra.nvim" })

	if PackerBootstrap then
		require("packer").sync()
	end
end)
