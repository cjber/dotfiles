nnoremap <leader>lc :Semshi rename<CR>
nnoremap <leader>lvv :call PandasViewDF()<CR>
nnoremap <leader>lvc :call PandasViewCols()<CR>
nnoremap <leader>lvi :call PandasViewInfo()<CR>

function PandasViewDF()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.head(50).to_csv("/tmp/_' . df . '.csv")')
    sleep 200m
    execute "e /tmp/_" . df . ".csv"
    sleep 50m
    execute "%ArrangeColumn"
endfunction

function PandasViewCols()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.columns')
endfunction

function PandasViewInfo()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.info()')
    call VimCmdLineSendCmd(df . '.describe()')
endfunction
