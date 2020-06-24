call plug#begin('~/.config/nvim/pack')

" auto read and save
Plug 'vim-scripts/vim-auto-save'
Plug 'djoshea/vim-autoread'

" improved navigation
Plug 'justinmk/vim-sneak'
Plug 'liuchengxu/vim-which-key'

" theme
Plug 'joshdick/onedark.vim'
Plug 'mhinz/vim-startify'

" IDE configuration
Plug 'ervandew/supertab'
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
Plug 'vimwiki/vimwiki'
Plug 'tpope/vim-dispatch'

"lang stuff
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jalvesaq/vimcmdline'
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'

" r plugs
Plug 'jalvesaq/Nvim-R'
Plug 'jalvesaq/R-Vim-runtime'
Plug 'gaalcaras/ncm-R'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-rmarkdown'
Plug 'chrisbra/NrrwRgn'

" nightly stuff
"Plug 'nvim-treesitter/nvim-treesitter'

" python
"Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}

" " spar
" Plug 'vim-scripts/sparql.vim'
" Plug 'neo4j-contrib/cypher-vim-syntax'

" csv
Plug 'chrisbra/csv.vim'

call plug#end()

"""""""""""""" External Scripts
runtime configs/defaults.vim
runtime configs/binds.vim
""""""""""""""

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1

let g:pandoc#modules#disabled = ["folding"]

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
    hi ClapPreview ctermbg=8 guibg=#09121a
    hi Sneak ctermbg=8 guibg=#09121a ctermfg=3
    hi CocHighlightText gui=bold ctermbg=8 guibg=#2C323C guifg=#e6e6e6
    hi VimwikiLink gui=underline guifg=#50AECD
    hi VimwikiHeader1 guifg=#e5c07b
    hi VimwikiPre guifg=#5C6370
    hi VimwikiItalic gui=italic guifg=#e5c07b
    hi VimwikiBold gui=bold guifg=#e5c07b
    hi Search gui=bold guibg=#2C323C guifg=#e6e6e6
    hi semshiImported guifg=#50AECD gui=bold
    hi semshiSelected guibg=#2c323c guifg=#e6e6e6
    hi semshiSelected guibg=#2c323c guifg=#e6e6e6
    hi semshiAttribute guifg=#accf93 gui=bold
    hi semshiSelf guifg=#e06c75
    hi pythonString guifg=#accf93 gui=italic
    hi SpellBad gui=undercurl
endfunction

autocmd! ColorScheme onedark call s:patch_onedark_colors()
colorscheme onedark

let g:silicon = {
      \ 'background':         '#09121a',
      \ 'round-corner':          v:false,
      \ 'window-controls':       v:false,
      \ }

let cmdline_follow_colorscheme = 1
let cmdline_map_send           = '<CR>'
let cmdline_app = {}
let cmdline_app['python'] = 'ipython'

" Set all terminal defaults
augroup TerminalStuff
  autocmd TermOpen * setlocal nonumber norelativenumber nospell
augroup END

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
            \ 'coc-tabnine'
            \ ]

function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()

let g:coc_snippet_next = '<tab>'

" fix annoying difference between .rmd and .Rmd
autocmd BufRead,BufNewFile *.rmd set filetype=rmd
autocmd BufRead,BufNewFile *.rq set filetype=sparql

autocmd FileType clap_input nnoremap <silent> <buffer> <Esc> <Esc>:call clap#handler#exit()<CR>

"let g:sneak#s_next = 1
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1

tnoremap <Esc><Esc> <C-\><C-n>

let g:vimwiki_list = [{'path':'~/drive/wiki', 'auto_export': 0, 'auto_toc': 0, 'path_html': '~/drive/wiki/html/', 'syntax': 'markdown', 'ext': '.md'}]
map <leader>vv <Plug>VimwikiIndex
map <leader>vl <Plug>VimwikiListToggle

let g:python3_host_prog = '/home/cjber/.pyenv/versions/pyds/bin/python'

hi ColorColumn guibg=#2c323c
set colorcolumn=81

let g:markdown_fenced_languages = ['r', 'python']
let g:rmd_fenced_languages = ['r', 'python']

let g:pandoc#folding#fastfolds = 1

let g:win_resize_height=5
let g:win_resize_width=10
let g:SuperTabDefaultCompletionType = "<c-n>"

let R_user_maps_only = 1
" Always enable preview window on the right with 60% width
let g:fzf_preview_window = 'right:60%'

let g:startify_custom_header = []

function! g:Show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nnoremap <silent> <Leader>lk :call Show_documentation()<CR>
