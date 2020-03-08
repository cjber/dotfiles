"Plugin Manager
call plug#begin('~/.config/nvim/pack')

" set better defaults
Plug 'vim-scripts/vim-auto-save'
Plug 'djoshea/vim-autoread'
Plug 'Konfekt/FastFold'

" Emacs style which key
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

" theme
Plug 'joshdick/onedark.vim'
"Plug 'segeljakt/vim-silicon'

" Startify
"Plug 'mhinz/vim-startify'
"Plug 'scrooloose/nerdtree'

" IDE Stuff
Plug 'liuchengxu/vista.vim'
Plug 'tpope/vim-dispatch'
Plug 'markonm/traces.vim'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
Plug 'tpope/vim-repeat'
Plug 'thaerkh/vim-indentguides'
Plug 'roxma/nvim-yarp'
Plug 'ap/vim-buftabline'
Plug 'ervandew/supertab'
Plug 'kkoomen/vim-doge'
Plug 'dstein64/vim-win'
Plug 'junegunn/vim-easy-align'

"lang stuff
Plug 'prabirshrestha/vim-lsp'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'jalvesaq/vimcmdline'
Plug 'chrisbra/Nrrwrgn'

" r plugs
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-rmarkdown'
"Plug 'jalvesaq/Nvim-R'
"Plug 'jalvesaq/R-Vim-runtime'

" python
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'tmhedberg/SimpylFold'

call plug#end()

"""""""""""""" External Scripts
runtime configs/defaults.vim
runtime configs/binds.vim
runtime configs/rconf.vim
""""""""""""""

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
let g:auto_save_silent = 1

let g:SuperTabDefaultCompletionType = "<c-n>"


function! s:patch_onedark_colors()
colorscheme onedark
    hi Comment guifg=#5C6370 ctermfg=59
    hi Normal ctermbg=none
    hi CursorLine ctermbg=8
    hi StatusLineNC ctermbg=8
    hi StatusLine ctermbg=8
    hi Visual ctermbg=8
    hi ColorColumn ctermbg=8
    hi PMenu ctermbg=8
    hi Folded ctermfg=59
    hi WhichKeyFloating ctermbg=0
    hi Conceal ctermfg=59
    hi StatusLine ctermbg=0 ctermfg=59
    hi LanguageToolGrammarError ctermfg=214
    hi texItalBoldStyle cterm=bold ctermfg=3
    hi ClapPreview ctermbg=8
endfunction

autocmd! ColorScheme onedark call s:patch_onedark_colors()

colorscheme onedark

let g:indentguides_ignorelist = ['rnoweb', 'tex', 'rmd', 'rmarkdown', 'markdown', 'pandoc']

" Extensive spelling check for all written documents, toplevel is required
autocmd BufNewFile,BufRead *rnw :set spell
autocmd BufNewFile,BufRead *.rnw :syntax spell toplevel
autocmd BufNewFile,BufRead *rmd :set spell
autocmd BufNewFile,BufRead *.rmd :syntax spell toplevel

" set harder defaults for improving shortcut use
let g:hardtime_default_on = 1
let g:hardtime_maxcount = 1000

let g:doge_doc_standard_python = 'google'

set thesaurus+=/home/cjber/drive/other/thesaurii.txt

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
            \ 'coc-snippets'
            \ ]

let g:markdown_fenced_languages = ['r', 'python']
let g:rmd_fenced_languages = ['r', 'python']

" language server
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
\   'julia': ['julia', '--startup-file=no', '--history-file=no', '-e', '
\       using LanguageServer;
\       using Pkg;
\       import StaticLint;
\       import SymbolServer;
\       env_path = dirname(Pkg.Types.Context().env.project_file);
\       debug = false; 
\       
\       server = LanguageServer.LanguageServerInstance(stdin, stdout, debug, env_path, "", Dict());
\       server.runlinter = true;
\       run(server);
\   ']
\ }


function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" fix annoying difference between .rmd and .Rmd
autocmd BufRead,BufNewFile *.rmd set filetype=rmarkdown

let g:pandoc#keyboard#use_default_mappings=0

autocmd FileType clap_input nnoremap <silent> <buffer> <Esc> <Esc>:call clap#handler#exit()<CR>
