vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use {'wbthomason/packer.nvim'}

    use {'Pocco81/AutoSave.nvim'} -- autosave
    use {'Konfekt/FastFold'} -- better folds
    use {'ahmedkhalf/project.nvim'} -- projects
    use {
        'akinsho/nvim-bufferline.lua',
        requires = 'kyazdani42/nvim-web-devicons'
    } -- bufferline
    use {'b3nj5m1n/kommentary'} -- comment out code
    use {
        'brymer-meneses/grammar-guard.nvim',
        requires = {'williamboman/nvim-lsp-installer'}
    }
    use {'chrisbra/NrrwRgn'} -- move code chunks from md/rmd to small window
    use {'dbeniamine/todo.txt-vim'} -- todo.txt helpers
    use {'folke/trouble.nvim'} -- better lsp error search
    use {'folke/lua-dev.nvim'} -- lua dev stuff
    use {'folke/todo-comments.nvim'}
    use {'folke/tokyonight.nvim'} -- theme
    use {'folke/which-key.nvim'} -- visualise bindings
    use {'ggandor/lightspeed.nvim'} -- movements
    use { -- auto completions
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-vsnip',
            'hrsh7th/vim-vsnip',
            'hrsh7th/vim-vsnip-integ',
            'lukas-reineke/cmp-under-comparator',
            -- {'tzachar/cmp-tabnine', run = './install.sh'}
        }
    }
    use {'jalvesaq/vimcmdline'} -- repl
    use {'kevinhwang91/nvim-bqf'}
    use {'kevinhwang91/nvim-hlslens'}
    use {'kkoomen/vim-doge', run = ':call doge#install()'}
    use {'kyazdani42/nvim-tree.lua'} -- file tree
    use {'lervag/vimtex'} -- latex tools
    use {'lewis6991/spellsitter.nvim'}
    use {'lukas-reineke/indent-blankline.nvim'} -- indent guide
    use {'markonm/traces.vim'} -- highlight subs etc
    -- use {'mhinz/vim-startify'}
    use {'nacro90/numb.nvim'}
    use {'neovim/nvim-lspconfig'} -- language servers
    use {'norcalli/nvim-colorizer.lua'} -- highlight colours
    use {
        'nvim-telescope/telescope.nvim',
        requires = {'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim'}
    } -- fzf file picker etc
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- syntax highlight
    use {'nvim-treesitter/nvim-treesitter-textobjects'} -- treesitter movements
    use {'nvim-treesitter/playground'} -- visualise treesitter
    use {'onsails/lspkind-nvim'} -- lsp symbols
    use {'rcarriga/nvim-notify'} -- popup notifications
    use {'simnalamburt/vim-mundo'} -- see undo tree
    use {'simrat39/symbols-outline.nvim'}
    use {'tpope/vim-dispatch'} -- dispatch commands
    use {'tpope/vim-repeat'} -- repeat plugin cmds (including lightspeed)
    use {'tpope/vim-surround'} -- change surrounding "'< etc
    use {'tweekmonster/startuptime.vim'} -- benchmark nvim startup
    use {'windwp/nvim-autopairs'} -- auto close brackets
    use {'yamatsum/nvim-nonicons'} -- icons
    use {'lukas-reineke/headlines.nvim'} -- highlight code bgs in rmd etc
    use {'direnv/direnv.vim'} -- auto enable direnvs
    use {'goolord/alpha-nvim', requires = {'kyazdani42/nvim-web-devicons'}} -- welcome screen
    -- use {'ray-x/lsp_signature.nvim'} -- show function args
    use {'simrat39/rust-tools.nvim'} -- more rust utils
    use {'saecki/crates.nvim', requires = {'nvim-lua/plenary.nvim'}} -- upgrade crates
    use {'rust-lang/rust.vim'} -- rust utils
    use {'romgrk/nvim-treesitter-context'} -- show context function
    use {'rafamadriz/friendly-snippets'} -- default snippets
    use {'numToStr/FTerm.nvim'}
    use {'https://gitlab.com/yorickpeterse/nvim-dd.git'}
    use {'neo4j-contrib/cypher-vim-syntax'}
    -- use {'github/copilot.vim'}
    use {'mzarnitsa/psql'}
    use {
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        run = 'cd app && yarn install'
    }
    -- use {'eddiebergman/nvim-treesitter-pyfold'}
    use {'anuvyklack/pretty-fold.nvim'}
    use {'petertriho/nvim-scrollbar'}
    use {'AckslD/nvim-pytrize.lua'}
    use {'tpope/vim-dadbod'}
    use {'kristijanhusak/vim-dadbod-ui'}
    use {
        'rcarriga/vim-ultest',
        requires = {'vim-test/vim-test'},
        run = ':UpdateRemotePlugins'
    }
    use {'sidebar-nvim/sidebar.nvim'}
    use {'jose-elias-alvarez/null-ls.nvim'}
end)

