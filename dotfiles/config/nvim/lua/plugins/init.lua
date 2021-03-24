-- check if packer is installed (~/local/share/nvim/site/pack)
local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

if not packer_exists then
	if vim.fn.input("Install packer.nvim? (y for yes)") ~= "y" then
		return
	end

	local directory = string.format(
	'%s/site/pack/packer/opt/',
	vim.fn.stdpath('data')
	)
	vim.fn.mkdir(directory, 'p')

	local git_clone_cmd = vim.fn.system(string.format(
	'git clone %s %s',
	'https://github.com/wbthomason/packer.nvim',
	directory .. '/packer.nvim'
	))

	print(git_clone_cmd)
	print("Installing packer.nvim...")

	return
end

require('plugins.plugs')
require('plugins.bufferline')
require('plugins.galaxyline')
require('plugins.treesitter')
require('plugins.gitsigns')
require('plugins.telescope')
require('plugins.nvimtree')
require('plugins.hop')
require('plugins.autopairs')

-- lsp configs
require('plugins.lspconfig') -- lsp config
require('plugins.nvimcompe') -- completions
require('plugins.lspkind') -- completion icons
require('plugins.textobjects') -- Move in functions etc

require('kommentary.config').use_extended_mappings()
require'colorizer'.setup({'*'}, {mode = 'foreground'})
require('telescope').load_extension('dap')
require('dap-python').setup('~/.pyenv/versions/py3nvim/bin/python')
