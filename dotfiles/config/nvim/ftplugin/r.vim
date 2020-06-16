nnoremap <silent> <Leader>lr :call Rlint()<CR>
nnoremap <silent> <Leader>kk :call RnwPDF()<CR>
nnoremap <silent> <Leader>kd :call RShowPDF()<CR>
nmap <CR> <Plug>RDSendLine
vmap <CR> <Plug>RDSendSelection

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 

set colorcolumn=80
" set foldmethod=syntax

" Nvim R
"let r_syntax_folding = 1

let R_args = ['--no-save', '--quiet']
let R_assign = 2
let R_esc_term = 0
let R_latexcmd = ['xelatex']
