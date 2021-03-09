let g:mapleader = "\<Space>"
let g:maplocalleader = ','

" stop space moving cursor
nnoremap <Space> <NOP>

" use esc esc to exit insert mode in terminal
tnoremap <Esc><Esc> <C-\><C-n>

" file commands
nnoremap <silent> <leader>ff :Rg<CR>
nnoremap <silent> <leader>fo :Files<CR>
nnoremap <silent> <leader>fe :Ranger<CR>

" :W sudo saves the file
nnoremap <silent> <leader>fs  :w !sudo tee % > /dev/null
nnoremap <silent> <leader>fu :MundoToggle<CR>

" open commands
nnoremap <silent> <leader>oq  :copen<CR>
nnoremap <silent> <leader>ol  :lopen<CR>

" buffer commands
" exit only one buffer
nnoremap <silent> <leader>bq :w\|bd<cr>
nnoremap <silent> <leader>bb :Buffers<CR>
nnoremap <silent> <leader>bl :Lines<CR>
nnoremap <silent> <leader>bo :Bdelete! other<CR>

" sourcery
nnoremap <leader>cl :CocDiagnostics<cr>
nnoremap <leader>cf :CocFix<cr>
nnoremap <leader>ch :call CocAction('doHover')<cr>

" language commands
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nnoremap <silent> <leader>lh :call <SID>show_documentation()<CR>
nnoremap <silent> <leader>lp :CocCommand editor.action.organizeImport<CR>
nmap <silent><leader>la <Plug>(coc-definition)
nmap <silent><leader>ly <Plug>(coc-type-definition)
nmap <silent><leader>li <Plug>(coc-implementation)
nmap <silent><leader>lr <Plug>(coc-references)
nmap <silent><leader>lc <Plug>(coc-rename)
nmap <silent><leader>le :CocList diagnostics<CR>
nmap <silent><leader>lf :call CocAction("format")<CR>
let g:doge_mapping= '<Leader>ld'
nnoremap <silent> <leader>lss :CocList snippets<CR>
nnoremap <silent> <leader>lsc :CocCommand snippets.editSnippets<CR>
nnoremap <silent> <leader>lt :CocList outline<CR>

" spelling
nnoremap <leader>ss :set invspell<CR>
nnoremap <leader>sf mz[s1z=e`z

" rotate windows
nnoremap <Leader>rr :wincmd H<CR>
nnoremap <Leader>re :wincmd J<CR>

" Configuration example
nnoremap <Leader>pp :Skylight!<CR>

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv
" Treat long lines as break lines (useful when moving around in them)
nmap j gj
nmap k gk
vmap j gj
vmap k gk

" Command mode shortcut
" enables ctrl navigation in menus
cnoremap <C-h> <BS>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Delete>
" Quit visual mode
vnoremap v <Esc>
" Move to the start of line
nnoremap H ^
vnoremap H ^
" Move to the end of line
nnoremap L $
vnoremap L $
" Redo
nnoremap U <C-r>

" shift M to merge lines together
nnoremap M J
vnoremap M J

" navigate through paragraphs with JK
nnoremap J }
nnoremap K {
vnoremap J }
vnoremap K {

" quick cycling through buffers
nnoremap <C-Space> :bnext<CR>

" Unhighlight searches with double esc
nnoremap <esc><esc> :noh<return><esc>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. Gap)
nmap ga <Plug>(EasyAlign)


" In the quickfix window, <CR> is used to jump to the error under the
" cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
" Yank to the end of line
nnoremap Y y$

" exit only one buffer
nnoremap Q :w\|bd<cr>

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" swap windows
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

nnoremap s :HopWord<CR>

nnoremap <Tab> %
nnoremap <S-Tab> *

nnoremap <Leader>lm V:s/[,)]/&\r/g <cr>='<
