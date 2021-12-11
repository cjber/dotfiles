" nnoremap <silent> <localleader>s :call StartR("R")<CR>
" nnoremap <silent> <localleader>q :call RQuit("R")<CR>

nnoremap <LocalLeader>s :IronRepl<CR><ESC>

inoremap <buffer> __ <Esc>:normal! a <-<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> << <Esc>:normal! a \|><CR>a 

let R_assign = 2
let R_esc_term = 0
let R_latexcmd = ['xelatex']
let R_app = "radian"
let R_cmd = "R"
let R_hl_term = 0
let R_bracketed_paste = 1
