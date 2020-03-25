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
let R_clear_line = 1

let rmd_syn_hl_chunk=1
