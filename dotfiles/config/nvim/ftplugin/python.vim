nnoremap <leader>lc :Semshi rename<CR>
nnoremap <leader>lvv :call PandasViewDF()<CR>
nnoremap <leader>lvc :call PandasViewCols()<CR>
nnoremap <leader>lvi :call PandasViewInfo()<CR>
nnoremap <localleader>ch :call IPyRunCell()<CR>

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

function! IPyRunCell()
    let def = '# %%'
    if type(def) == v:t_list
        let implicit = v:false
        let [start, end] = def
    else
        let implicit = v:true
        let start = def
        let end = def
    endif
    let curline = line('.')
    let lnum2 = search(end, 'nW')
    if lnum2 == 0
        if implicit
            let lnum2 = line('$')+1
        else
            return 0
        end
    endif
    call cursor(lnum2,1)
    let lnum1 = search(start, 'bnW')
    if lnum1 == 0 && !implicit
        return 0
    endif
    let lines = getline(lnum1+1, lnum2-1)
    echomsg "".lnum1.":".lnum2
    while len(lines) > 0 && match(lines[0], '^\s*$') > -1
        let lines = lines[1:]
    endwhile
    call VimCmdLineSendCmd(join(lines, "\n"))
    return 1
endfunction
