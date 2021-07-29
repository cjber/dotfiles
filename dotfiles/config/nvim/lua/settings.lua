local function enable_options(options)
    for _, option in ipairs(options) do vim.cmd('set ' .. option) end
end

local function set_options(options)
    for _, option in ipairs(options) do
        vim.cmd('set ' .. option[1] .. '=' .. option[2])
    end
end

vim.cmd('filetype plugin on')

enable_options({
    'expandtab',
    'autoindent',
    'smartindent',
    'smarttab',
    'termguicolors',
    'wildmenu',
    'list',
    'nu',
    'rnu',
    'splitright',
    'splitbelow',
    'autowrite',
    'ignorecase',
    'smartcase',
    'incsearch',
    'undofile',
    'linebreak',
    'nobackup',
    'noswapfile',
    'nowritebackup',
    'noruler'
})

set_options({
    {'scrolloff', 1},
    {'shortmess', 'aoOstTWAIcqFS'},
    {'sidescrolloff', 5},
    {'complete', '.,w,b,u,t,i,kspell'},
    {'wildmode', 'longest:full,full'},
    {'tabstop', 4},
    {'shiftwidth', 4},
    {'softtabstop', 4},
    {'grepprg', [[rg\ --vimgrep\ --smart-case\ --follow]]},
    {'timeoutlen', 500},
    {'updatetime', 300},
    {'history', 10000},
    {'signcolumn', 'number'},
    {'undolevels', 1000},
    {'showbreak', '¦'},
    {'conceallevel', 2},
    {'concealcursor', ''},
    {'clipboard', 'unnamedplus'},
    {'pumheight', 10},
    {'cmdheight', 1},
    {'mouse', 'a'},
    {'colorcolumn', 88},
    {'laststatus', 0},
    {'spelllang', 'en_gb'},
    {'foldmethod', 'indent'},
    {'foldlevelstart', 99}
})

vim.o.shell = '/bin/zsh'

vim.o.errorformat = vim.o.errorformat ..
                        [[\%*\\sFile\ \"%f\"\\,\ line\ %l\\,\ %m,]] ..
                        [[\%*\\sFile\ \"%f\"\\,\ line\ %l,]] .. [[\%f:%l:\ %m,]] ..
                        [[\%f:%l:,]] .. [[\%-G%.%#]]

vim.cmd('set formatoptions-=cro')
