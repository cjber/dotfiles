return require('packer').startup(function()
    use {'907th/vim-auto-save'} -- auto save
    use {
        'AckslD/nvim-whichkey-setup.lua',
        requires = {'liuchengxu/vim-which-key'}
    }
    use {'airblade/vim-rooter'} -- auto change dir to project roots
    use {'akinsho/nvim-bufferline.lua'} -- bufferline
    use {'b3nj5m1n/kommentary'} -- comment out code
    use {'dbeniamine/todo.txt-vim'}
    use {'glepnir/galaxyline.nvim'} -- statusline
    use {'glepnir/lspsaga.nvim'}
    use {'hrsh7th/nvim-compe'} -- lang completion
    use {'hrsh7th/vim-vsnip'} -- snippets
    use {'jalvesaq/Nvim-R'} -- R repl + utils
    use {'jalvesaq/vimcmdline'} -- repl
    use {'kevinhwang91/nvim-bqf'}
    use {'kkoomen/vim-doge', run = ':call doge#install()'}
    use {'kyazdani42/nvim-tree.lua'} -- file tree
    use {'kyazdani42/nvim-web-devicons'} -- icons
    use {'lervag/vimtex'} -- latex tools
    use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'} -- indent guide
    use {'markonm/traces.vim'} -- highlight subs etc
    use {'mfussenegger/nvim-dap'}
    use {'mfussenegger/nvim-dap-python'}
    use {'neovim/nvim-lspconfig'} -- language servers
    use {'norcalli/nvim-colorizer.lua'} -- highlight colours
    use {'nvim-lua/plenary.nvim'} -- same
    use {'nvim-lua/popup.nvim'} -- misc required
    use {'nvim-telescope/telescope-dap.nvim'}
    use {'nvim-telescope/telescope-media-files.nvim'} -- pick media files
    use {'nvim-telescope/telescope.nvim'} -- fzf file picker etc
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- syntax highlight
    use {'nvim-treesitter/nvim-treesitter-textobjects'}
    use {'onsails/lspkind-nvim'} -- lsp symbols
    use {'phaazon/hop.nvim', branch = 'pre-extmarks'} -- hop to words
    use {'ryanoasis/vim-devicons'} -- more icons
    use {'sainnhe/edge'} -- colorscheme
    use {'simnalamburt/vim-mundo'} -- see undo tree
    use {'theHamsta/nvim-dap-virtual-text'}
    use {'tpope/vim-dispatch'} -- dispate commands
    use {'tpope/vim-surround'} -- change surrounding "'< etc
    use {'tweekmonster/startuptime.vim'} -- benchmark nvim startup
    use {'wbthomason/packer.nvim', opt = true}
    use {'windwp/nvim-autopairs'} -- auto close brackets
    use {'nvim-treesitter/playground'}
    use {
        'nvim-telescope/telescope-z.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'nvim-lua/popup.nvim'},
            {'nvim-telescope/telescope.nvim'}
        },
        config = function()
            require'telescope'.load_extension 'z'
            -- ... other telescope settings
        end
    }

end)
