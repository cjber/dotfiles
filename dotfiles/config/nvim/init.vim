if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin('~/.config/nvim/pack')

" auto read and save
Plug 'vim-scripts/vim-auto-save'
Plug 'djoshea/vim-autoread'

" improved navigation
Plug 'phaazon/hop.nvim'
Plug 'liuchengxu/vim-which-key'
Plug 'wellle/targets.vim'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'dylanaraps/root.vim'

Plug 'bling/vim-bufferline'
Plug 'mtdl9/vim-log-highlighting'
Plug 'voldikss/vim-skylight'
Plug 'lukas-reineke/indent-blankline.nvim', {'branch': 'lua'}

" theme
Plug 'rakr/vim-one'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

" IDE configuration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vista.vim'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'roxma/nvim-yarp'
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
Plug 'dstein64/vim-win'
Plug 'junegunn/vim-easy-align'
Plug 'Asheq/close-buffers.vim'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-abolish'
Plug 'simnalamburt/vim-mundo'

"lang stuff
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
Plug 'jalvesaq/vimcmdline'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'romgrk/nvim-treesitter-context'
Plug 'KeitaNakamura/tex-conceal.vim'

" r plugs
Plug 'jalvesaq/Nvim-R'
Plug 'jalvesaq/R-Vim-runtime'
" Plug 'gaalcaras/ncm-R'
" Plug 'vim-pandoc/vim-pandoc-syntax'
" Plug 'vim-pandoc/vim-pandoc'
" Plug 'vim-pandoc/vim-rmarkdown'

" python
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'untitled-ai/jupyter_ascending.vim'

" other
Plug 'chrisbra/csv.vim'
Plug 'google/vim-jsonnet'

call plug#end()

"""""""""""""" External Scripts
runtime configs/defaults.vim
runtime configs/binds.vim
""""""""""""""

colorscheme one
call one#highlight('Normal', '', '1E2127', 'none')
call one#highlight('SignColumn', '', '1E2127', 'none')
call one#highlight('CocErrorSign', 'D1666A', '', 'none')
call one#highlight('CursorLineNr', 'LineNr', 'LineNr', 'none')

" one#highlight doesn't work for this
hi markdownItalic gui='italic'

hi DiffAdd guibg=None
hi DiffDelete guibg=None
hi DiffChange guibg=None
hi Pmenu guibg=Normal
hi PmenuSbar guibg=Normal

let g:one_allow_italics = 1

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1

" i find this very slow even with fast folds
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#keyboard#use_default_mappings = 0

" repl settings
let cmdline_follow_colorscheme = 1
let cmdline_esc_term = 0
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
            \ 'coc-r-lsp',
            \ 'coc-pyright',
            \ 'coc-diagnostic',
            \ 'coc-highlight',
            \ 'coc-sql',
            "\ 'coc-git',
            \ 'coc-markdownlint',
            \ 'coc-toml',
            \ 'coc-vimlsp',
            \ 'coc-yaml'
            \ ]

"autocmd CursorHold * silent call CocActionAsync('highlight')

" tab between snippet place markers
let g:coc_snippet_next = '<tab>'

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

let g:python3_host_prog = '/home/cjber/.pyenv/versions/py3nvim/bin/python'

 if has('nvim') && !empty($CONDA_PREFIX)
 call coc#config('python', {
 \   'pythonPath': $CONDA_PREFIX . '/bin/python'
 \ })
 endif
 if !empty($PYENV_VIRTUAL_ENV)
 call coc#config('python', {
 \   'pythonPath': $PYENV_VIRTUAL_ENV . '/bin/python'
 \ })
 endif

 if !empty($VIRTUAL_ENV)
 call coc#config('python', {
 \ 'pythonPath': $VIRTUAL_ENV . '/bin/python'
 \ })
 endif

let g:loaded_python_provider = 0 " don't use python2

" close if just repl left open
autocmd BufEnter * if (winnr("$") == 1 && &buftype == 'terminal') | q | endif

let g:root#patterns = ['.git', '.venv']
let g:root#autocmd_patterns = "*.py,*.R"
let g:root#auto = 1
let g:root#echo = 0

let g:python_highlight_all = 1

let g:bufferline_show_bufnr = 0
let g:bufferline_active_buffer_left = '[ '

let g:netrw_browsex_viewer='xdg-open'

let g:skylight_borderchars = ['─', '│', '─', '│', '┌', '┐', '┘', '└']
"""

" will use eventually, using coc for now
" require'lspconfig'.pyls.setup{}
" require'lspconfig'.r_language_server.setup{}
""" LUA stuff
lua << EOF

require'nvim-treesitter.configs'.setup {
ensure_installed = "all",
  highlight = {
    enable = true,
    use_languagetree = true,
  },
}
EOF

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=200 }
augroup END

let g:jupyter_ascending_match_pattern='.sync.py'

let g:indent_blankline_char_highlight = 'SpecialKey'
let g:indent_blankline_char = '┆'
"let g:indent_blankline_use_treesitter = v:true
let g:indent_blankline_show_first_indent_level = v:false

lua require"hop".setup {}
let g:mundo_preview_bottom=1
let g:mundo_verbose_graph=0
let g:mundo_width=32
