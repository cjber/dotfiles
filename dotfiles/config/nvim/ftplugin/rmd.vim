setlocal spell
syntax spell toplevel

nnoremap <silent> <Leader>kk :call RmdRender()<CR>
nnoremap <silent> <Leader>kp :call RmdPdf()<CR>
nnoremap <silent> <Leader>kh :call RmdHTML()<CR>

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> << <Esc>:normal! a \|><CR>a 

function RmdRender()
    Dispatch! Rscript -e 'rmarkdown::render("%:p", quiet=F)'
endfunction

function RmdPdf()
    Dispatch! zathura %:r.pdf &
endfunction

function RmdHTML()
    Dispatch! firefox %:r.html &
endfunction
