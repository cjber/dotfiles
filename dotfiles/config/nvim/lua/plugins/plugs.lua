vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use {'wbthomason/packer.nvim'}

    use {'Pocco81/AutoSave.nvim'} -- autosave
    use {'ahmedkhalf/project.nvim'}
    use {
        'akinsho/nvim-bufferline.lua',
        requires = 'kyazdani42/nvim-web-devicons'
    } -- bufferline
    use {'alexaandru/nvim-lspupdate', requires = {'rktjmp/hotpot.nvim'}}
    use {'b3nj5m1n/kommentary'} -- comment out code
    use {'brymer-meneses/grammar-guard.nvim'}
    use {'chrisbra/NrrwRgn'} -- move code chunks from md/rmd to small window
    use {'dbeniamine/todo.txt-vim'} -- todo.txt helpers
    use {'dccsillag/magma-nvim', run = ':UpdateRemotePlugins'}
    use {'folke/lsp-trouble.nvim'} -- better lsp error search
    use {'folke/lua-dev.nvim'} -- lua dev stuff
    use {'folke/todo-comments.nvim'}
    use {'folke/tokyonight.nvim'} -- theme
    use {'folke/which-key.nvim'} -- visualise bindings
    use {'ggandor/lightspeed.nvim'}
    use {'glepnir/lspsaga.nvim'}
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/vim-vsnip',
            'hrsh7th/vim-vsnip-integ'
        }
    }
    use {'jalvesaq/Nvim-R'} -- R repl + utils
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
    use {'nvim-treesitter/nvim-treesitter-textobjects'}
    use {'nvim-treesitter/playground'} -- visualise treesitter
    use {'onsails/lspkind-nvim'} -- lsp symbols
    use {'rcarriga/nvim-notify'}
    use {'simnalamburt/vim-mundo'} -- see undo tree
    use {'simrat39/symbols-outline.nvim'}
    use {'tpope/vim-dispatch'} -- dispatch commands
    use {'tpope/vim-repeat'} -- repeat plugin cmds (including lightspeed)
    use {'tpope/vim-surround'} -- change surrounding "'< etc
    use {'tweekmonster/startuptime.vim'} -- benchmark nvim startup
    use {'windwp/nvim-autopairs'} -- auto close brackets
    use {'yamatsum/nvim-nonicons'} -- icons
    use {'lukas-reineke/headlines.nvim'}
    use {'direnv/direnv.vim'}
    use {'goolord/alpha-nvim', requires = {'kyazdani42/nvim-web-devicons'}}
end)
