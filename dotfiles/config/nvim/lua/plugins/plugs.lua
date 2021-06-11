vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use {'wbthomason/packer.nvim'}

    use {'907th/vim-auto-save'} -- auto save
    use {'AndrewRadev/splitjoin.vim'} -- opposite of merge
    -- use {'airblade/vim-rooter'} -- auto change dir to project roots
    use {'ahmedkhalf/lsp-rooter.nvim'}
    use {
        'akinsho/nvim-bufferline.lua',
        requires = 'kyazdani42/nvim-web-devicons'
    } -- bufferline
    use {'alexaandru/nvim-lspupdate', run = ':LspUpdate'}
    use {'b3nj5m1n/kommentary'} -- comment out code
    use {'beauwilliams/focus.nvim'} -- resize windows on enter
    use {'chrisbra/NrrwRgn'} -- move code chunks from md/rmd to small window
    use {'dbeniamine/todo.txt-vim'} -- todo.txt helpers
    use {'folke/lsp-trouble.nvim'} -- better lsp error search
    use {'folke/lua-dev.nvim'} -- lua dev stuff
    use {'folke/tokyonight.nvim'} -- theme
    use {'folke/which-key.nvim'} -- visualise bindings
    use {'folke/zen-mode.nvim'}
    use {'glepnir/lspsaga.nvim'}
    use {'hrsh7th/nvim-compe'} -- lang completion
    use {'hrsh7th/vim-vsnip'} -- snippets
    use {'hrsh7th/vim-vsnip-integ'}
    use {'jalvesaq/Nvim-R'} -- R repl + utils
    use {'jalvesaq/vimcmdline'} -- repl
    use {'karb94/neoscroll.nvim'} -- smooth scroll
    use {'kevinhwang91/nvim-bqf'}
    use {'kevinhwang91/nvim-hlslens'}
    use {'kkoomen/vim-doge', run = ':call doge#install()'}
    use {'kyazdani42/nvim-tree.lua'} -- file tree
    use {'lervag/vimtex'} -- latex tools
    use {'lewis6991/spellsitter.nvim'}
    use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'} -- indent guide
    use {'markonm/traces.vim'} -- highlight subs etc
    use {'mhinz/vim-startify'}
    use {'nacro90/numb.nvim'}
    use {'neovim/nvim-lspconfig'} -- language servers
    use {'norcalli/nvim-colorizer.lua'} -- highlight colours
    use {
        'nvim-telescope/telescope.nvim',
        requires = {'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim'}
    } -- fzf file picker etc
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- syntax highlight
    use {'nvim-treesitter/nvim-treesitter-textobjects'}
    use {'nvim-treesitter/playground'} -- visualise treesitter
    use {'onsails/lspkind-nvim'} -- lsp symbols
    use {'phaazon/hop.nvim', branch = 'pre-extmarks'} -- hop to words
    use {'rafamadriz/friendly-snippets'}
    use {'rhysd/vim-grammarous'} -- grammar checker
    use {'ryanoasis/vim-devicons'} -- more icons
    use {'simnalamburt/vim-mundo'} -- see undo tree
    use {'simrat39/symbols-outline.nvim'}
    use {'sindrets/diffview.nvim'} -- git diffs
    use {'tpope/vim-dispatch'} -- dispate commands
    use {'tpope/vim-surround'} -- change surrounding "'< etc
    use {'tweekmonster/startuptime.vim'} -- benchmark nvim startup
    use {'wakatime/vim-wakatime'}
    use {'windwp/nvim-autopairs'} -- auto close brackets
    -- use {'winston0410/range-highlight.nvim'}
    use {
        'yamatsum/nvim-web-nonicons',
        requires = {'kyazdani42/nvim-web-devicons'}
    } -- icons
    use {'tmhedberg/SimpylFold'}
    use {'Konfekt/FastFold'}
    use {'ahmedkhalf/jupyter-nvim'}
    use {'mfussenegger/nvim-dap-python'}
    use {'mfussenegger/nvim-dap'}
end)
