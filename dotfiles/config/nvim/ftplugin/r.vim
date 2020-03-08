nnoremap <silent> <Leader>lr :call Rlint()<CR>
nnoremap <silent> <Leader>kk :call RnwPDF()<CR>
nnoremap <silent> <Leader>kd :call RShowPDF()<CR>
"nmap <CR> <Plug>RDSendLine
"vmap <CR> <Plug>RDSendSelection

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 

set colorcolumn=80
set foldmethod=syntax

" Nvim R
let r_syntax_folding = 1

let R_assign = 2
let R_show_args = 1
let R_latexcmd = ['xelatex']
let R_cite_pattern = '\\\(cite\|bibentry\)\S*{'
let R_app = "radian"
let R_cmd = "R"
let R_hl_term = 0
let R_args = []
let R_bracketed_paste = 1
