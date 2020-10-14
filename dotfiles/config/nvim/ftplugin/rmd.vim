nnoremap <silent> <localleader>s :call StartR("R")<CR>
nnoremap <silent> <localleader>q :call RQuit("R")<CR>

set foldmethod=marker
set foldmarker=```{,```

set spell
syntax spell toplevel

function Rlint()
    Dispatch Rscript -e 'styler::style_file("'%'")'
endfunction

function RmdRender()
    Dispatch Rscript -e 'rmarkdown::render("'%'", quiet=T)'
endfunction

function RmdPdf()
    Dispatch zathura %:r.pdf &
endfunction

function RmdHTML()
    Dispatch brave %:r.html &
endfunction

nnoremap <silent> <Leader>ll :call Rlint()<CR>
nnoremap <silent> <Leader>kk :call RmdRender()<CR>
nnoremap <silent> <Leader>kp :call RmdPdf()<CR>
nnoremap <silent> <Leader>kh :call RmdHTML()<CR>
nmap <CR> <Plug>RDSendLine
vmap <CR> <Plug>RDSendSelection

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> __ <Esc>:normal! a <-<CR>a 

nnoremap zk ?^#\\|^```{<CR>
nnoremap zj /^#\\|^```{<CR>

let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '"""':'"""', "'''":"'''"}

set nonumber
set norelativenumber

nnoremap <Leader>rn :RNrrw<CR>

" Nvim R
let R_args = ['--no-save', '--quiet']
let R_assign = 2
let R_esc_term = 0
let R_latexcmd = ['xelatex'] " allows using system fonts
let rmd_syn_hl_chunk=1
"let g:disable_r_ftplugin=1

" highlight code blocks in rmd documents
" setl signcolumn=no
" hi markdownCodeBlockBG guibg=#262830
" sign define codeblock linehl=markdownCodeBlockBG

" function! MarkdownBlocks()
"     let l:continue = 0
"     execute "sign unplace * file=".expand("%")

"     " iterate through each line in the buffer
"     for l:lnum in range(1, len(getline(1, "$")))
"         " detect the start fo a code block
"         if getline(l:lnum) =~ "^```.*$" || l:continue
"             " continue placing signs, until the block stops
"             let l:continue = 1
"             " place sign
"             execute "sign place ".l:lnum." line=".l:lnum." name=codeblock file=".expand("%")
"             " stop placing signs
"             if getline(l:lnum) =~ "^```$"
"                 let l:continue = 0
"             endif
"         endif
"     endfor
" endfunction

" " Use signs to highlight code blocks
" " Set signs on loading the file, leaving insert mode, and after writing it
" call MarkdownBlocks()

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

" au BufWinEnter *.rmd,*.Rmd :call TextEnableCodeSnip('tex', '<!-- tex -->', '<!-- tex -->', 'texStatement')
