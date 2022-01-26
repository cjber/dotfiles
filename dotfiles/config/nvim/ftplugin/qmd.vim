setlocal spell
syntax spell toplevel

nnoremap <silent> <Leader>kk :call QmdRender()<CR>
nnoremap <silent> <Leader>kp :call QmdPdf()<CR>
nnoremap <silent> <Leader>kh :call QmdHTML()<CR>

function QmdRender()
    Dispatch! quarto render %:p
endfunction

function QmdPdf()
    Dispatch! zathura %:r.pdf &
endfunction

function QmdHTML()
    Dispatch! firefox %:r.html &
endfunction
