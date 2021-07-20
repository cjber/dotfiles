setlocal spell
syntax spell toplevel

nnoremap <silent> <localleader>s :call StartR("R")<CR>
nnoremap <silent> <localleader>q :call RQuit("R")<CR>
nnoremap <silent> <Leader>kk :call RmdRender()<CR>
nnoremap <silent> <Leader>kp :call RmdPdf()<CR>
nnoremap <silent> <Leader>kh :call RmdHTML()<CR>
nmap <CR> <Plug>RDSendLine
vmap <CR> <Plug>RDSendSelection

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> << <Esc>:normal! a \|><CR>a 
inoremap <buffer> __ <Esc>:normal! a <-<CR>a 

function RmdRender()
    Dispatch Rscript -e 'rmarkdown::render("%:p", quiet=F)'
endfunction

function RmdPdf()
    Dispatch! zathura %:r.pdf
endfunction

function RmdHTML()
    Dispatch! firefox %:r.html
endfunction

" Nvim R
let R_args = ['--no-save', '--quiet']
let R_assign = 2
let R_esc_term = 0
let rmd_syn_hl_chunk=1
