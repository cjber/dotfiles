map <buffer> <M-j> <Plug>(PythonsenseStartOfNextPythonFunction)
map <buffer> <M-k> <Plug>(PythonsenseStartOfPythonFunction)

nnoremap <leader>lv :call PandasViewDF()<CR>
function PandasViewDF()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.sample(n=50).to_csv("/tmp/_' . df . '.csv")')
    execute "ter vd /tmp/_" . df . ".csv"
endfunction
