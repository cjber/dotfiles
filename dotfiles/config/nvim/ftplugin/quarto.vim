setlocal spell

nnoremap <silent> <Leader>kk :call QmdRender()<CR>
nnoremap <silent> <Leader>ka :call QmdPreview()<CR>
nnoremap <silent> <Leader>kp :call QmdPdf()<CR>
nnoremap <silent> <Leader>kh :call QmdHTML()<CR>

function QmdRender()
    Dispatch! quarto render %:p --execute-dir $PWD
endfunction

function QmdPreview()
    Dispatch! quarto preview %:p --execute-dir $PWD
endfunction

function QmdPdf()
    Dispatch! zathura %:r.pdf &
endfunction

function QmdHTML()
    Dispatch! firefox %:r.html &
endfunction

let g:nrrw_aucmd_create = "set ft=python"

let g:nrrw_custom_options={}
let g:nrrw_custom_options['filetype'] = 'python'

function NRPrepCode()
    execute "normal! gg"
    execute "normal! /```{python}<CR>jV/```<CR>k:'<,'>YodeCreateSeditorFloating<CR>"
endfunction

nnoremap <localleader>a /```{python}<CR>jV/```<CR>k:'<,'>NR<CR>:nohl<CR>

" let zotcite_conceallevel = 0
