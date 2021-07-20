" leader
nnoremap <Leader>lp :lua OrganizeImports()<CR>
nnoremap <Leader>sb :Dispatch! python -m streambook %<CR>
nnoremap <Leader>ps :Dispatch! pyright --createstub 

" localleader
nnoremap <LocalLeader>l :call VimCmdLineSendCmd('%whos')<CR>
nnoremap <LocalLeader>v :call PandasViewDF()<CR>
vnoremap <LocalLeader>v :call PandasViewDFV()<CR>
function PandasViewDF()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.sample(n=50).to_csv("/tmp/_' . df . '.csv")')
    execute ":lua require('lspsaga.floaterm').open_float_terminal('vd /tmp/_" . df . ".csv'"")"
endfunction

function PandasViewDFV()
    let df = getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]]
    call VimCmdLineSendCmd(df . '.sample(n=50).to_csv("/tmp/_' . df . '.csv")')
    execute ":lua require('lspsaga.floaterm').open_float_terminal('vd /tmp/_" . df . ".csv'"")"
endfunction

nnoremap <LocalLeader>h :call Help()<CR>
vnoremap <LocalLeader>h :call HelpV()<CR>

function Help()
    let obj = expand('<cword>')
    call VimCmdLineSendCmd('help(' . obj . ')')
endfunction

function HelpV()
    let obj =  getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]]
    call VimCmdLineSendCmd('help(' . obj . ')')
endfunction
