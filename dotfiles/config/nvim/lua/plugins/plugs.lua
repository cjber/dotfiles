return require("packer").startup(function()
    use {"wbthomason/packer.nvim", opt = true}
    use {"sainnhe/edge"} -- colorscheme
    use {"lewis6991/gitsigns.nvim"} -- git symbols
    use {"glepnir/galaxyline.nvim"} -- statusline
    use {"kyazdani42/nvim-web-devicons"} -- icons
    use {"kyazdani42/nvim-tree.lua"} -- file tree
    use {"akinsho/nvim-bufferline.lua"} -- bufferline
    use {"nvim-treesitter/nvim-treesitter", run = ':TSUpdate'} -- syntax highlight
    use {"nvim-treesitter/nvim-treesitter-textobjects"}
    use {"nvim-telescope/telescope.nvim"} -- fzf file picker etc
    use {"nvim-telescope/telescope-media-files.nvim"} -- pick media files
    use {"b3nj5m1n/kommentary"} -- comment out code
    use {"norcalli/nvim-colorizer.lua"} -- highlight colours
    use {"907th/vim-auto-save"} -- auto save
    use {'lukas-reineke/indent-blankline.nvim', branch = 'lua'} -- indent guide
    use {"ryanoasis/vim-devicons"} -- more icons
    -- use {"sbdchd/neoformat"} -- format different file types
    use {"neovim/nvim-lspconfig"} -- language servers
    use {"hrsh7th/nvim-compe"} -- lang completion
    use {"hrsh7th/vim-vsnip"} -- snippets
    use {"windwp/nvim-autopairs"} -- auto close brackets
    use {"tweekmonster/startuptime.vim"} -- benchmark nvim startup
    use {"onsails/lspkind-nvim"} -- lsp symbols
    use {"phaazon/hop.nvim", branch = "pre-extmarks"} -- hop to words

    use {"nvim-lua/popup.nvim"} -- misc required
    use {"nvim-lua/plenary.nvim"} -- same

    use {"jalvesaq/Nvim-R"} -- R repl + utils
    use {"jalvesaq/vimcmdline"} -- repl
    use {"simnalamburt/vim-mundo"} -- see undo tree
    use {"tpope/vim-surround"} -- change surrounding "'< etc
    use {"airblade/vim-rooter"} -- auto change dir to project roots
    use {"lervag/vimtex"} -- latex tools
    use {"tpope/vim-dispatch"} -- dispate commands
    use {"dstein64/vim-win"} -- window tools
    use {"markonm/traces.vim"} -- highlight subs etc

    use {"nvim-telescope/telescope-dap.nvim"}
    use {"mfussenegger/nvim-dap"}
    use {"mfussenegger/nvim-dap-python"}
    use {"theHamsta/nvim-dap-virtual-text"}
    use {'glepnir/lspsaga.nvim'}
    use {
      'yamatsum/nvim-web-nonicons',
      requires = {'kyazdani42/nvim-web-devicons'}
    }
end)
