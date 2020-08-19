"nnoremap <leader>lc :Semshi rename<CR>
nnoremap <leader>lvv :call PandasViewDF()<CR>
nnoremap <leader>lvc :call PandasViewCols()<CR>
nnoremap <leader>lvi :call PandasViewInfo()<CR>

nnoremap <leader>lp :CocCommand python.sortImports<CR>
nnoremap <leader>lT oimport ipdb;ipdb.set_trace()<ESC>

function PandasViewCols()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.columns')
endfunction

function PandasViewInfo()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.info()')
    call VimCmdLineSendCmd(df . '.describe()')
endfunction

" function! IPyRunCell()
"     let def = '# %%'
"     if type(def) == v:t_list
"         let implicit = v:false
"         let [start, end] = def
"     else
"         let implicit = v:true
"         let start = def
"         let end = def
"     endif
"     let curline = line('.')
"     let lnum2 = search(end, 'nW')
"     if lnum2 == 0
"         if implicit
"             let lnum2 = line('$')+1
"         else
"             return 0
"         end
"     endif
"     call cursor(lnum2,1)
"     let lnum1 = search(start, 'bnW')
"     if lnum1 == 0 && !implicit
"         return 0
"     endif
"     let lines = getline(lnum1+1, lnum2-1)
"     echomsg "".lnum1.":".lnum2
"     while len(lines) > 0 && match(lines[0], '^\s*$') > -1
"         let lines = lines[1:]
"     endwhile
"     call VimCmdLineSendCmd('%cpaste -q')
"     sleep 50m
"     call VimCmdLineSendCmd(join(lines, "\n"))
"     call VimCmdLineSendCmd('--')
"     return 1
" endfunction

" function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
"   let ft=toupper(a:filetype)
"   let group='textGroup'.ft
"   if exists('b:current_syntax')
"     let s:current_syntax=b:current_syntax
"     " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
"     " do nothing if b:current_syntax is defined.
"     unlet b:current_syntax
"   endif
"   execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
"   try
"     execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
"   catch
"   endtry
"   if exists('s:current_syntax')
"     let b:current_syntax=s:current_syntax
"   else
"     unlet b:current_syntax
"   endif
"   execute 'syntax region textSnip'.ft.'
"   \ matchgroup='.a:textSnipHl.'
"   \ keepend
"   \ start="'.a:start.'" end="'.a:end.'"
"   \ contains=@'.group
" endfunction

" au BufWinEnter *.py :call TextEnableCodeSnip('markdown', "^'''", "^'''", 'Comment')
" au BufWrite *.py :syn sync fromstart

" " highlight code blocks in rmd documents
" setl signcolumn=no

" hi markdownCodeBlockBG guibg=#262830
" sign define codeblock linehl=markdownCodeBlockBG

" function! MarkdownBlocks()
"     let l:continue = 0
"     execute "sign unplace * file=".expand("%")

"     " iterate through each line in the buffer
"     for l:lnum in range(1, len(getline(1, "$")))
"         " detect the start fo a code block
"         if getline(l:lnum) =~ "^# %%$" && getline(l:lnum+1) != "'''" || l:continue
"             " continue placing signs, until the block stops
"             let l:continue = 1
"             " place sign
"             execute "sign place ".l:lnum." line=".l:lnum." name=codeblock file=".expand("%")
"             " stop placing signs
"             if getline(l:lnum) =~ "^# --$"
"                 let l:continue = 0
"             endif
"         endif
"     endfor
" endfunction

" " Use signs to highlight code blocks
" " Set signs on loading the file, leaving insert mode, and after writing it
" " note that this triples startup time for documents with a lot of blocks
" " might not be worth keeping
" call MarkdownBlocks()
" au BufWrite *.py :call MarkdownBlocks()

" nnoremap <localleader>cc :call IPyRunCell()<CR>
" nnoremap <localleader>b :?# %%<CR>
" nnoremap <localleader>a :/# %%<CR>
" nnoremap zk :?# %%<CR>
" nnoremap zj :/# %%<CR>
" nnoremap <silent> <localleader>kk :call ConvertToIpy()<CR>
" nnoremap <localleader>m I# %%<CR>'''<CR>'''<CR><Esc>kO
" nnoremap <localleader>, I# %%<CR># --<Esc>O

" function ConvertToIpy()
"     Dispatch ipynb-py-convert % %:r.ipynb
"     sleep 200m
"     execute "e %:r.ipynb"
"     sleep 200m
"     Dispatch jupytext % --out %:r.Rmd
"     sleep 200m
"     execute "e %:r.Rmd"
"     sleep 200m
"     execute '%s/# --//g'
" endfunction
    
function PandasViewDF()
    let df = expand('<cword>')
    call VimCmdLineSendCmd(df . '.head(50).to_csv("/tmp/_' . df . '.csv")')
    sleep 200m
    execute "e /tmp/_" . df . ".csv"
    sleep 50m
    execute "%ArrangeColumn"
endfunction

