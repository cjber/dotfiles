" leader
nnoremap <Leader>sb :Dispatch! python -m streambook %<CR>
nnoremap <Leader>ps :Dispatch! pyright --createstub 

" localleader
nnoremap <LocalLeader>l :call VimCmdLineSendCmd('%whos')<CR>
nnoremap <LocalLeader>v :call PandasViewDF()<CR>
vnoremap <LocalLeader>v :call PandasViewDFV()<CR>
nnoremap <LocalLeader>h :call Help()<CR>
vnoremap <LocalLeader>h :call HelpV()<CR>

nnoremap <silent>       <LocalLeader>z :MagmaInit python3<CR>
xnoremap <silent>       <LocalLeader>a v/# --<CR>k<C-u>:MagmaEvaluateVisual<CR>
nnoremap <silent>       <LocalLeader>rl :MagmaEvaluateLine<CR>
xnoremap <silent>       <LocalLeader>r  :<C-u>MagmaEvaluateVisual<CR>
nnoremap <silent>       <LocalLeader>rr :MagmaReevaluateCell<CR>
nnoremap <silent>       <LocalLeader>rd :MagmaDelete<CR>
nnoremap <silent>       <LocalLeader>ro :MagmaShowOutput<CR>

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

function Help()
    let obj = expand('<cword>')
    call VimCmdLineSendCmd('help(' . obj . ')')
endfunction

function HelpV()
    let obj =  getline("'<")[getpos("'<")[2] - 1:getpos("'>")[2]]
    call VimCmdLineSendCmd('help(' . obj . ')')
endfunction
