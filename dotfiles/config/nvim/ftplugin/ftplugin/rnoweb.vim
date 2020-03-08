function! Rlint()
    let filename = expand("%:r:t")
    let rcmd = "require('styler');
        \styler::style_file(\"" . filename . ".rnw\")"
    let rcmd = rcmd
    call g:SendCmdToR(rcmd)
endfunction

nnoremap <silent> <Leader>ll :call Rlint()<CR>

nmap <CR> <Plug>RDSendLine
vmap <CR> <Plug>RDSendSelection

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 

"remove term numbs
autocmd TermOpen * setlocal nonumber

syn match rnwNotes "//.*"
hi rnwNotes ctermbg=8 ctermfg=59

set conceallevel=0

let R_texerr=1
let R_cite_pattern = '\\\(cite\|bibentry\)\S*{'
