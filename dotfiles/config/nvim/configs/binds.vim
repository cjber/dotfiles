let g:mapleader = "\<Space>"
let g:maplocalleader = ','

nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>

vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual ','<CR>

" use esc esc to exit insert mode in terminal
tnoremap <Esc><Esc> <C-\><C-n>

" Define prefix dictionary
let g:which_key_map =  {}
call which_key#register('<Space>', 'g:which_key_map')

" file commands
nnoremap <silent> <leader>ff :Rg<CR>
nnoremap <silent> <leader>fo :Files<CR>
nnoremap <silent> <leader>fe :Ranger<CR>
" :W sudo saves the file
nnoremap <silent> <leader>fs  :w !sudo tee % > /dev/null
let g:which_key_map.f = {
            \ 'name' : '+file'        ,
            \ 'f'    : 'rip-grep' ,
            \ 'e'    : 'ranger'   ,
            \ 'o'    : 'file-browser'   ,
            \}

" open commands
nnoremap <silent> <leader>oq  :copen<CR>
nnoremap <silent> <leader>ol  :lopen<CR>
let g:which_key_map.o = {
      \ 'name' : '+open'             ,
      \ 'q'    : 'open-quickfix'     ,
      \ 'l'    : 'open-locationlist' ,
      \ }

" buffer commands
" exit only one buffer
nnoremap <silent> <leader>bq :w\|bd<cr>
nnoremap <silent> <leader>bb :Buffers<CR>
nnoremap <silent> <leader>bl :Lines<CR>
nnoremap <silent> <leader>bo :Bdelete! other<CR>
let g:which_key_map.b = {
      \ 'name' : '+buffer'      ,
      \ 'd'    : ['bd'          , 'delete-buffer']   ,
      \ 'f'    : ['bfirst'      , 'first-buffer']    ,
      \ 'l'    : ['blast'       , 'last-buffer']     ,
      \ 'n'    : ['bnext'       , 'next-buffer']     ,
      \ 'p'    : ['bprevious'   , 'previous-buffer'] ,
      \ 'b'    : 'list-buffers' ,
      \ 'q'    : 'quit-one'     ,
      \ 'o'    : 'delete-other' ,
      \ }

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
  else
    call CocActionAsync('doHover')
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
let g:doge_mapping= '<Leader>ld'
nnoremap <silent> <leader>lss :CocList snippets<CR>
nnoremap <silent> <leader>lsc :CocCommand snippets.editSnippets<CR>
nnoremap <silent> <leader>lt :CocList outline<CR>

let g:which_key_map.l = {
      \ 'name' : '+lsp'                 ,
      \ 'f'    : ['CocAction("format")' , 'formatting']       ,
      \ 'p'    : 'imports'              ,
      \ 't'    : 'tags'                 ,
      \ 'e'    : 'errors'               ,
      \ 'd'    : 'docstring'            ,
      \ 'a'    : 'definition'           ,
      \ 'y'    : 'type definition'      ,
      \ 'i'    : 'implementation'       ,
      \ 'r'    : 'references'           ,
      \ 'c'    : 'rename'               ,
      \ 'h'    : 'documentation'        ,
      \ 's'    : {
      \ 'name' : '+snippets'            ,
      \ 's'    : 'list'                 ,
      \ 'c'    : 'coc-edit'             ,
      \},
      \ }

" spelling
nnoremap <leader>ss :set invspell<CR>
nnoremap <leader>sf mz[s1z=e`z
let g:which_key_map.s = {
            \ 'name' : '+spelling'       ,
            \ 's'    : 'toggle-spelling' ,
            \ 'f'    : 'spell-fix'       ,
            \}

" window movement
" quick window manager
"nnoremap s :Win<CR>

nnoremap <Leader>rr :wincmd H<CR>
nnoremap <Leader>re :wincmd J<CR>
nnoremap <Leader>rw :Win<CR>
let g:which_key_map.r = {
            \ 'name' : '+window'        ,
            \ 'r'    : 'horizontal'     ,
            \ 'e'    : 'vertical'       ,
            \ 'w'    : 'window-manager' ,
            \}

" Configuration example
nnoremap <Leader>pp :Skylight!<CR>

""" end of which key

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

" move lines with alt
"nnoremap <A-j> :m .+1<CR>==
"nnoremap <A-k> :m .-2<CR>==
"inoremap <A-k> <Esc>:m .-2<CR>==gi
"inoremap <A-j> <Esc>:m .+1<CR>==gi
"vnoremap <A-j> :m '>+1<CR>gv=gv
"vnoremap <A-k> :m '<-2<CR>gv=gv

" exit only one buffer
nnoremap Q :w\|bd<cr>

" " Use <C-l> for trigger snippet expand.
" imap <C-l> <Plug>(coc-snippets-expand)
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" " navigate popup menu with ctrl j and k
" inoremap <expr> <c-j> pumvisible() ? "\<C-N>" : "j"
" inoremap <expr> <c-k> pumvisible() ? "\<C-P>" : "k"

" swap windows
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" one char sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

nnoremap <Tab> %
nnoremap <S-Tab> *

nnoremap <Leader>lm V:s/[,)]/&\r/g <cr>='<
