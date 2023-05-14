" leader
nnoremap <Leader>sb :Dispatch! python -m streambook %<CR>
nnoremap <Leader>ps :Dispatch! pyright --createstub 

" localleader

nnoremap <LocalLeader>sl :call RunToLine()<CR>
nnoremap <LocalLeader>sf :call RunFile()<CR>
nnoremap <LocalLeader>sd :call PandasViewDF()<CR>
vnoremap <LocalLeader>sd :call PandasViewDFV()<CR>
nnoremap <LocalLeader>sh :call Help()<CR>
vnoremap <LocalLeader>sh :call HelpV()<CR>
" nnoremap <LocalLeader>sl :call VimCmdLineSendCmd('%whos')<CR>

function RunFile()
    let file = expand('%:p')
    call VimCmdLineSendCmd('%run \"' . file . '\"')
endfunction

" function RunFile()
"     let file = expand('%:p')
"     exec ':lua require("iron.core").send("python", "%run ' . file . "\")"
" endfunction

function RunToLine()
    let curline = getpos('.')[1]
    exec ':call b:cmdline_source_fun(getline(1, curline))'
endfunction

function PandasViewDF()
    let df = expand('<cword>')
    call cmdline#SendCmd(df . '.sample(n=50).to_csv("/tmp/_' . df . '.csv")')
    execute ":lua require('FTerm').run('vd /tmp/_" . df . ".csv'"")"
endfunction

function PandasViewDFV()
    let df = getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]]
    call VimCmdLineSendCmd(df . '.sample(n=50).to_csv("/tmp/_' . df . '.csv")')
    execute ":lua require('FTerm').run('vd /tmp/_" . df . ".csv'"")"
endfunction

function Help()
    let obj = expand('<cword>')
    call VimCmdLineSendCmd('help(' . obj . ')')
endfunction

function HelpV()
    let obj =  getline("'<")[getpos("'<")[2] - 1:getpos("'>")[2]]
    call VimCmdLineSendCmd('help(' . obj . ')')
endfunction
