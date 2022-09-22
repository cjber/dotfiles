vim.cmd [[packadd packer.nvim]]

require("packer").init({
    display = { compact = true }
})

return require("packer").startup(function()
    use({ "wbthomason/packer.nvim" })
    use({ "jmbuhr/quarto-nvim" })
    use({ "kyazdani42/nvim-web-devicons" })
    use({ 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' })
    use({ 'kyazdani42/nvim-tree.lua', tag = 'nightly' })

    use({ 'williamboman/mason.nvim' })
    use({ 'WhoIsSethDaniel/mason-tool-installer.nvim' })

    use({ "nvim-lualine/lualine.nvim" })
    use({ "ahmedkhalf/project.nvim" }) -- projects
    use({ "lukas-reineke/headlines.nvim" })

    use({ "lewis6991/impatient.nvim" })
    use({ "vim-pandoc/vim-pandoc-syntax" })
    use({ "vim-pandoc/vim-rmarkdown" })
    use({ "cjber/quarto-vim" })
    use({ "Pocco81/auto-save.nvim" }) -- autosave
    use({ "Konfekt/FastFold" }) -- better folds
    use({ "noib3/nvim-cokeline" })
    use({ "numToStr/Comment.nvim" })
    use({ "folke/trouble.nvim" }) -- better lsp error search
    use({ "folke/lua-dev.nvim" }) -- lua dev stuff
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
            { "tzachar/cmp-tabnine", run = "./install.sh" },
        },
    })
    use({ "jalvesaq/vimcmdline" }) -- repl
    use({ "danymat/neogen" })
    use({ "lervag/vimtex" }) -- latex tools
    use({ "lukas-reineke/indent-blankline.nvim" }) -- indent guide
    use({ "markonm/traces.vim" }) -- highlight subs etc
    use({ "neovim/nvim-lspconfig" }) -- language servers
    use({ "norcalli/nvim-colorizer.lua" }) -- highlight colours
    use({
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim", "nvim-lua/popup.nvim" },
    }) -- fzf file picker etc
    use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- syntax highlight
    use({ "nvim-treesitter/nvim-treesitter-textobjects" }) -- treesitter movements
    use({ "rcarriga/nvim-notify" }) -- popup notifications
    use({ "onsails/lspkind-nvim" }) -- lsp symbols
    use({ "mbbill/undotree" }) -- undo tree
    use({ "tpope/vim-dispatch" }) -- dispatch commands
    use({ "tpope/vim-repeat" }) -- repeat plugin cmds (including lightspeed)
    use({ "kylechui/nvim-surround" })
    use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" })
    use({ "tweekmonster/startuptime.vim" }) -- benchmark nvim startup
    use({ "windwp/nvim-autopairs" }) -- pairs
    use({ "rafamadriz/friendly-snippets" }) -- default snippets
    use({ "numToStr/FTerm.nvim" })
    use({
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        run = "cd app && yarn install",
        opt = true,
    })
    use({ "petertriho/nvim-scrollbar" }) -- scrollbar with diagnostics
    use({ "kevinhwang91/nvim-hlslens" }) -- hl matches
    use({ "kazhala/close-buffers.nvim" })
    use({ "jose-elias-alvarez/null-ls.nvim" }) -- other lsp
    use({ "nvim-telescope/telescope-file-browser.nvim" }) -- telescope files
    use({ "j-hui/fidget.nvim" }) -- lsp progress
    use({ "yioneko/nvim-yati" }) -- indents
    use({ "dbeniamine/todo.txt-vim" })
    use({ "ggandor/leap-ast.nvim" })
    use({ 'ggandor/leap.nvim' })
    use({ 'simrat39/rust-tools.nvim' })
    use({ 'saecki/crates.nvim' })

    if PackerBootstrap then
        require('packer').sync()
    end
end)
