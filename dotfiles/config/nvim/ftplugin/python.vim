nnoremap <leader>lc :Semshi rename<CR>
nnoremap <leader>lv :call PandasView()<CR>

function PandasView()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.head(50).to_csv("/tmp/_' . df . '.csv")')
    sleep 100m
    execute "e /tmp/_" . df . ".csv"
endfunction
