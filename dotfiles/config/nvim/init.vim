call plug#begin('~/.config/nvim/pack')

" auto read and save
Plug 'vim-scripts/vim-auto-save'
Plug 'djoshea/vim-autoread'

" improved navigation
Plug 'justinmk/vim-sneak'
Plug 'liuchengxu/vim-which-key'
Plug 'wellle/targets.vim'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'dylanaraps/root.vim'

" theme
Plug 'rakr/vim-one'

" IDE configuration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vista.vim'
Plug 'markonm/traces.vim'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'roxma/nvim-yarp'
Plug 'kkoomen/vim-doge'
Plug 'dstein64/vim-win'
Plug 'junegunn/vim-easy-align'
Plug 'Asheq/close-buffers.vim'
Plug 'tpope/vim-dispatch'

"lang stuff
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jalvesaq/vimcmdline'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'romgrk/nvim-treesitter-context'
Plug 'nvim-treesitter/nvim-treesitter-refactor'

" r plugs
Plug 'jalvesaq/Nvim-R'
Plug 'jalvesaq/R-Vim-runtime'
" Plug 'gaalcaras/ncm-R'
" Plug 'vim-pandoc/vim-pandoc-syntax'
" Plug 'vim-pandoc/vim-pandoc'
" Plug 'vim-pandoc/vim-rmarkdown'
" Plug 'chrisbra/NrrwRgn'

" python
Plug 'petobens/poet-v'
Plug 'jeetsukumaran/vim-pythonsense'

" csv
Plug 'chrisbra/csv.vim'
Plug 'google/vim-jsonnet'

Plug 'inkarkat/vim-SyntaxRange'
call plug#end()

"""""""""""""" External Scripts
runtime configs/defaults.vim
runtime configs/binds.vim
""""""""""""""

colorscheme one
call one#highlight('Normal', '', '1E2127', 'none')
call one#highlight('SignColumn', '', '1E2127', 'none')
let g:one_allow_italics = 1

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1

" i find this very slow even with fast folds
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#keyboard#use_default_mappings = 0

" repl settings
let cmdline_follow_colorscheme = 1
let cmdline_map_send = '<CR>'
let cmdline_app = {}
let cmdline_app['python'] = 'ipython'

" Set all terminal defaults
" no numbers or spell check
augroup TerminalStuff
  autocmd TermOpen * setlocal nonumber norelativenumber nospell
augroup END

""" COC SETTINGS
" coc extensions to auto install
let g:coc_global_extensions = [
            \ 'coc-pairs',
            \ 'coc-texlab',
            \ 'coc-html',
            \ 'coc-css',
            \ 'coc-json',
"\ 'coc-r-lsp',
            \ 'coc-python',
            \ 'coc-snippets',
            \ 'coc-highlight',
            \ 'coc-yank',
            \ 'coc-sql'
            \ ]
" tab between snippet place markers
let g:coc_snippet_next = '<tab>'
" use lk to show doc for function under cursor 
function! g:Show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
nnoremap <silent> <Leader>lk :call Show_documentation()<CR>
" use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use <cr> to confirm completion
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif
"""

""" VIM SNEAK
" use labels in sneak
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1 " use ignorecase/smartcase
"""

""" VIM WIN
" larger vim win increments
let g:win_resize_height=5
let g:win_resize_width=10
"""

""" NVIM R
" there are a lot i don't use but some are useful
" plan to write all my own
"let R_user_maps_only = 1
" include python and r syntax in markdown and rmd
let g:markdown_fenced_languages = ['r', 'python']
let g:rmd_fenced_languages = ['r', 'python']
"""

""" FZF
let g:fzf_layout = { 'window': { 'width': 1, 'height': 0.4, 'yoffset': 1, 'border': 'horizontal' } }
let g:fzf_preview_window = ''
let g:fzf_border = 'sharp'
"""

""" RANGER VIM
let g:ranger_map_keys = 0
let g:ranger_replace_netrw = 1
set shell=bash " fix errors with using fish
"""

""" MISC SETTINGS
" use :call Syn() to find highlight group under cursor
function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()

" fix annoying difference between .rmd and .Rmd
autocmd BufRead,BufNewFile *.rmd set filetype=rmd

" use :call Syn() to find highlight group under cursor
function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()

" fix annoying difference between .rmd and .Rmd
autocmd BufRead,BufNewFile *.rmd set filetype=rmd

" use one big python env for jedi completions
" honestly this is probably not the best way
let g:python3_host_prog = '/home/cjber/.pyenv/versions/py3nvim/bin/python'
let g:loaded_python_provider = 0
let g:poetv_auto_activate = 1

autocmd BufEnter * if (winnr("$") == 1 && &buftype == 'terminal') | q | endif

let g:root#patterns = ['.git', '.toml']
let g:root#autocmd_patterns = "*.py"
let g:root#auto = 1
let g:root#echo = 0

let g:python_highlight_all = 1
"""
""" LUA stuff
lua <<EOF
require'nvim_lsp'.pyls.setup{}
require'nvim_lsp'.jedi_language_server.setup{}
require'nvim_lsp'.r_language_server.setup{}

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",     -- one of "all", "language", or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
  },
  indent = {
    enable = true
  }
}
EOF
