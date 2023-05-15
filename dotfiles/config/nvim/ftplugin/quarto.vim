setlocal spell
set colorcolumn=
set filetype=markdown

nnoremap <silent> <Leader>kk :call QmdRender()<CR>
nnoremap <silent> <Leader>ka :call QmdPreview()<CR>
nnoremap <silent> <Leader>kp :call QmdPdf()<CR>
nnoremap <silent> <Leader>kh :call QmdHTML()<CR>
nnoremap <silent> <Leader>ls :lua require("null-ls-embedded").buf_format()

function QmdRender()
    lua require("FTerm").scratch({cmd={"quarto", "render", vim.fn.expand("%:p"), "--execute-dir", vim.fn.expand("$PWD")}})
endfunction

function QmdPreview()
    Dispatch! quarto preview %:p --execute-dir $PWD
endfunction

function QmdPdf()
    lua require("FTerm").scratch({cmd={"nohup", "zathura", vim.fn.expand("%:r") .. ".pdf" , "&"}})
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
