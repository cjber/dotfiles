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

" theme
Plug 'joshdick/onedark.vim'
Plug 'mhinz/vim-startify'

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
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jalvesaq/vimcmdline'

" r plugs
Plug 'jalvesaq/Nvim-R'
Plug 'jalvesaq/R-Vim-runtime'
Plug 'gaalcaras/ncm-R'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-pandoc'
Plug 'chrisbra/NrrwRgn'

" python
Plug 'petobens/poet-v'

" csv
Plug 'chrisbra/csv.vim'
Plug 'google/vim-jsonnet'
call plug#end()

"""""""""""""" External Scripts
runtime configs/defaults.vim
runtime configs/binds.vim
""""""""""""""
let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1

" i find this very slow even with fast folds
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#keyboard#use_default_mappings = 0

function! s:patch_onedark_colors()
colorscheme onedark
    hi Comment guifg=#5C6370 ctermfg=59
    hi Normal ctermbg=none guibg=none
    hi StatusLineNC ctermbg=8 guibg=#09121a
    hi StatusLine ctermbg=8 guibg=#09121a
    hi Visual ctermbg=8 guibg=#09121a
    hi ColorColumn ctermbg=8 guibg=#09121a
    hi PMenu ctermbg=8 guibg=#09121a
    hi Folded ctermfg=2 gui=italic guifg=#5c6370 guibg=#262830
    hi WhichKeyFloating ctermbg=0 guibg=#282c34
    hi Conceal ctermfg=2 guifg=#98C379
    hi StatusLine ctermbg=0 guibg=#282c34 ctermfg=59 guifg=#5C6370
    hi LanguageToolGrammarError ctermfg=214 guifg=#d19a66
    hi pandocEmphasis gui=italic guifg=#e5c07b
    hi markdownItalic gui=italic guifg=#e5c07b
    hi markdownBold gui=bold guifg=#e5c07b
    hi pandocStrong gui=bold guifg=#e5c07b
    hi Sneak ctermbg=8 guibg=#09121a ctermfg=3
    hi CocHighlightText gui=bold ctermbg=8 guibg=#2C323C guifg=#e6e6e6
    hi VimwikiLink gui=underline guifg=#50AECD
    hi VimwikiHeader1 guifg=#e5c07b
    hi VimwikiPre guifg=#5C6370
    hi VimwikiItalic gui=italic guifg=#e5c07b
    hi VimwikiBold gui=bold guifg=#e5c07b
    hi Search gui=bold guibg=#2C323C guifg=#e6e6e6
    hi pythonString guifg=#accf93 gui=italic
    hi SpellBad gui=undercurl
    hi ColorColumn guibg=#2c323c
endfunction

autocmd! ColorScheme onedark call s:patch_onedark_colors()
colorscheme onedark

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
            \ 'coc-r-lsp',
            \ 'coc-python',
            \ 'coc-snippets',
            \ 'coc-highlight',
            \ 'coc-yank'
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

""" VIM WIKI
" this needs fixing for hugo wiki
let g:vimwiki_list = [{
  \ 'auto_export': 1,
  \ 'automatic_nested_syntaxes': 1,
  \ 'path_html': '$HOME/drive/wiki/_site',
  \ 'path': '$HOME/drive/wiki/',
  \ 'template_path': '$HOME/drive/wiki/templates/',
  \ 'syntax': 'markdown',
  \ 'ext':'.md',
  \ 'template_default':'markdown',
  \ 'custom_wiki2html': '$HOME/dotfiles/scripts/wiki2html.sh',
  \ 'template_ext':'.html'
\}]
map <leader>vv <Plug>VimwikiIndex
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
" Always enable fzf preview window on the right with 60% width
let g:fzf_preview_window = 'right:60%'
"""

""" STARTIFY
" remove the donkey
let g:startify_custom_header = []
"""

""" RANGER VIM
let g:ranger_map_keys = 0
map <leader>fr :Ranger<CR>
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
"""
