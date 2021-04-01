" leader
nnoremap <Leader>lp :lua OrganizeImports()<CR>

" localleader
nnoremap <LocalLeader>l :call VimCmdLineSendCmd('%whos')<CR>
nnoremap <LocalLeader>v :call PandasViewDF()<CR>
function PandasViewDF()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.sample(n=50).to_csv("/tmp/_' . df . '.csv")')
    execute "ter vd /tmp/_" . df . ".csv"
endfunction
