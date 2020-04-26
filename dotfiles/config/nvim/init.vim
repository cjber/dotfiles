call plug#begin('~/.config/nvim/pack')


" set better defaults
Plug 'vim-scripts/vim-auto-save'
Plug 'djoshea/vim-autoread'
Plug 'Konfekt/FastFold'
Plug 'justinmk/vim-sneak'

" Emacs style which key
Plug 'liuchengxu/vim-which-key'

" theme
Plug 'joshdick/onedark.vim'
Plug 'segeljakt/vim-silicon'

" Startify
Plug 'mhinz/vim-startify'

" Languages
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'neovim/nvim-lsp'
"Plug 'haorenW1025/completion-nvim'
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }

" IDE Stuff
Plug 'liuchengxu/vista.vim'
Plug 'markonm/traces.vim'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
Plug 'tpope/vim-repeat'
Plug 'thaerkh/vim-indentguides'
Plug 'roxma/nvim-yarp'
Plug 'kkoomen/vim-doge'
Plug 'dstein64/vim-win'
Plug 'junegunn/vim-easy-align'
Plug 'Asheq/close-buffers.vim'
Plug 'vimwiki/vimwiki'

"lang stuff
Plug 'jalvesaq/vimcmdline'
Plug 'chrisbra/Nrrwrgn'
Plug 'gaalcaras/ncm-R'

" r plugs
"Plug 'vim-pandoc/vim-pandoc'
"Plug 'vim-pandoc/vim-pandoc-syntax'
"Plug 'vim-pandoc/vim-rmarkdown'
Plug 'jalvesaq/Nvim-R'
Plug 'jalvesaq/R-Vim-runtime'

" python
Plug 'kalekundert/vim-coiled-snake'
"Plug 'szymonmaszke/vimpyter'
Plug 'goerz/jupytext.vim'

" spar
Plug 'vim-scripts/sparql.vim'
Plug 'neo4j-contrib/cypher-vim-syntax'


call plug#end()

"""""""""""""" External Scripts
runtime configs/defaults.vim
runtime configs/binds.vim
""""""""""""""

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1

function! s:patch_onedark_colors()
colorscheme onedark
    hi Comment guifg=#5C6370 ctermfg=59
    hi Normal ctermbg=none guibg=none
    hi StatusLineNC ctermbg=8 guibg=#09121a
    hi StatusLine ctermbg=8 guibg=#09121a
    hi Visual ctermbg=8 guibg=#09121a
    hi ColorColumn ctermbg=8 guibg=#09121a
    hi PMenu ctermbg=8 guibg=#09121a
    hi Folded ctermfg=2 gui=italic guifg=#5c6370
    hi WhichKeyFloating ctermbg=0 guibg=#282c34
    hi Conceal ctermfg=2 guifg=#98C379
    hi StatusLine ctermbg=0 guibg=#282c34 ctermfg=59 guifg=#5C6370
    hi LanguageToolGrammarError ctermfg=214 guifg=#d19a66
    hi pandocEmphasis gui=italic guifg=#e5c07b
    hi markdownItalic gui=italic guifg=#e5c07b
    hi markdownBold gui=italic guifg=#e5c07b
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
endfunction

autocmd! ColorScheme onedark call s:patch_onedark_colors()

colorscheme onedark

let g:indentguides_ignorelist = ['rnoweb', 'tex', 'rmd', 'rmarkdown', 'markdown', 'pandoc', 'vimwiki']

let g:doge_doc_standard_python = 'google'

let g:silicon = {
      \ 'background':         '#09121a',
      \ 'round-corner':          v:false,
      \ 'window-controls':       v:false,
      \ }

let cmdline_follow_colorscheme = 1
let cmdline_map_send           = '<CR>'
let cmdline_app = {}
let cmdline_app['python'] = 'ipython'
let cmdline_app['r'] = 'radian'
let cmdline_app['rmd'] = 'radian'

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
            \ 'coc-yank',
            \ 'coc-highlight'
            \ ]

let g:markdown_fenced_languages = ['r', 'python']
let g:rmd_fenced_languages = ['r', 'python']

" language server
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
\   'python': ['pyls', '-v'],
\ 'r': ['R', '--slave', '-e', 'languageserver::run()'],
\ }

function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()

let g:coc_snippet_next = '<tab>'

" Use <C-l> for trigger snippet expand and for others (not always needed)

" fix annoying difference between .rmd and .Rmd
autocmd BufRead,BufNewFile *.rmd set filetype=rmd
autocmd BufRead,BufNewFile *.rq set filetype=sparql

let g:pandoc#keyboard#use_default_mappings=0
let g:pandoc#modules#disabled = ["command","formatting","templates","menu","bibliographies","completion","autocomplete","folding"]

autocmd FileType clap_input nnoremap <silent> <buffer> <Esc> <Esc>:call clap#handler#exit()<CR>
"autocmd CursorHold * silent call CocActionAsync('highlight')

"let g:sneak#s_next = 1
let g:sneak#label = 1

tnoremap <Esc><Esc> <C-\><C-n>

let g:vimwiki_list = [{'path':'~/drive/wiki', 'auto_export': 0, 'auto_toc': 0, 'path_html': '~/drive/wiki/html/', 'syntax': 'markdown', 'ext': '.md'}]
map <leader>vv <Plug>VimwikiIndex
map <leader>vl <Plug>VimwikiListToggle


"lua require'nvim_lsp'.pyls.setup{on_attach=require'completion'.on_attach}
" Use completion-nvim in every buffer
"autocmd BufEnter * lua require'completion'.on_attach()

let g:vimpyter_view_directory='%:p:h'

let g:python3_host_prog = $HOME.'/.pyenv/versions/neovim/bin/python'

"lua require'nvim_lsp'.pyls_ms.setup{}
