set spell
syntax spell toplevel

function Rlint()
    Dispatch Rscript -e 'styler::style_file("'%'")'
endfunction

function RmdRender()
    Dispatch Rscript -e 'rmarkdown::render("'%'", quiet=T)'
endfunction

function RmdPdf()
    Dispatch zathura "%:r:t".pdf &
endfunction

nnoremap <silent> <Leader>ll :call Rlint()<CR>
nnoremap <silent> <Leader>kk :call RmdRender()<CR>
nnoremap <silent> <Leader>kp :call RmdPdf()<CR>
nmap <CR> <Plug>RDSendLine
vmap <CR> <Plug>RDSendSelection

inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 
inoremap <buffer> >> <Esc>:normal! a %>%<CR>a 

let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '"""':'"""', "'''":"'''"}

set nonumber
set norelativenumber
set concealcursor=
set conceallevel=2
set signcolumn=yes

hi FoldColumn ctermfg=238
hi pandocEmphasis ctermfg=3
hi pandocStrong ctermfg=3

nnoremap <Leader>rn :RNrrw<CR>

" presudo fold navigation without slow folds
nmap zj <Plug>(pandoc-keyboard-next-header)
nmap zk <Plug>(pandoc-keyboard-prev-header)

" Nvim R
let R_app = "radian"
let R_cmd = "R"
let R_hl_term = 0
let R_args = []  " if you had set any
let R_bracketed_paste = 1

let R_assign = 2
let R_show_args = 1
let R_esc_term = 0
let R_latexcmd = ['xelatex']

let rmd_syn_hl_chunk=1

" highlight code blocks in rmd documents
setl signcolumn=no

hi markdownCodeBlockBG guibg=#2C343C
sign define codeblock linehl=markdownCodeBlockBG

function! MarkdownBlocks()
    let l:continue = 0
    execute "sign unplace * file=".expand("%")

    " iterate through each line in the buffer
    for l:lnum in range(1, len(getline(1, "$")))
        " detect the start fo a code block
        if getline(l:lnum) =~ "^```.*$" || l:continue
            " continue placing signs, until the block stops
            let l:continue = 1
            " place sign
            execute "sign place ".l:lnum." line=".l:lnum." name=codeblock file=".expand("%")
            " stop placing signs
            if getline(l:lnum) =~ "^```$"
                let l:continue = 0
            endif
        endif
    endfor
endfunction

" Use signs to highlight code blocks
" Set signs on loading the file, leaving insert mode, and after writing it
call MarkdownBlocks()
