let g:mapleader = "\<Space>"
let g:maplocalleader = ','

autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')

nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>

vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual ','<CR>

" Define prefix dictionary
let g:which_key_map =  {}

" file commands
nnoremap <silent> <leader>ff :Clap filer<CR>
nnoremap <silent> <leader>fe :e $MYVIMRC<CR>
nnoremap <Leader>fg :Clap grep<CR>
" :W sudo saves the file
nnoremap <silent> <leader>fs  :w !sudo tee % > /dev/null
let g:which_key_map.f = {
            \ 'name' : '+file'        ,
            \ 'f'    : 'file-browser' ,
            \ 'e'    : 'edit-vimrc'   ,
            \ 'g'    : 'grep-files'   ,
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
nnoremap <silent> <leader>bb :Clap buffers<CR>
let g:which_key_map.b = {
      \ 'name' : '+buffer'      ,
      \ 'd'    : ['bd'          , 'delete-buffer']   ,
      \ 'o'    : ['on'          , 'delete-other']    ,
      \ 'f'    : ['bfirst'      , 'first-buffer']    ,
      \ 'l'    : ['blast'       , 'last-buffer']     ,
      \ 'n'    : ['bnext'       , 'next-buffer']     ,
      \ 'p'    : ['bprevious'   , 'previous-buffer'] ,
      \ 'b'    : 'list-buffers' ,
      \ 'q'    : 'quit-one' ,
      \ }

" language commands
let g:doge_mapping= '<Leader>ld'
nnoremap <silent> <leader>lss :CocList snippets<CR>
nnoremap <silent> <leader>lsc :CocCommand snippets.editSnippets<CR>
nnoremap <silent> <leader>le :Clap loclist<CR>
nnoremap <silent> <leader>lt :Clap tags<CR>
let g:which_key_map.l = {
      \ 'name' : '+lsp'                 ,
      \ 'f'    : ['CocAction("format")' , 'formatting']       ,
      \ 'd'    : 'docstring'            ,
      \ 's'    : {
      \ 'name' : '+snippets'            ,
      \ 's'    : 'list'                 ,
      \ 'c'    : 'coc-edit'             ,
      \ 'u'    : 'ultisnips-edit'       ,
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
nnoremap s :Win<CR>

nnoremap <Leader>rr :wincmd H<CR>
nnoremap <Leader>re :wincmd J<CR>
nnoremap <Leader>rw :Win<CR>
let g:which_key_map.r = {
            \ 'name' : '+window'        ,
            \ 'r'    : 'horizontal'     ,
            \ 'e'    : 'vertical'       ,
            \ 'w'    : 'window-manager' ,
            \}

""" end of which key

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv
" Treat long lines as break lines (useful when moving around in them)
nmap j gj
nmap k gk
vmap j gj
vmap k gk


" shift zz to remove all windows (use this for when I have an open repl)
nnoremap <S-Z><S-Z> :xa!<CR>

" Command mode shortcut
" emables ctrl navigation in menus
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
" Move to the end of line
nnoremap L $
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

" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
inoremap <c-c> <ESC>

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
" inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" navigate popup menu with ctrl j and k
inoremap <expr> <c-j> pumvisible() ? "\<C-N>" : "j"
inoremap <expr> <c-k> pumvisible() ? "\<C-P>" : "k"
