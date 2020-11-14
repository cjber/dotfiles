scriptencoding utf-8

syntax on                      " Syntax highlighting
filetype plugin indent on      " Automatically detect file types
set autoindent                 " Indent at the same level of the previous line
set autoread                   " Automatically read a file changed outside of vim
set backspace=indent,eol,start " Backspace for dummies
set complete-=i                " Exclude files completion
set display=lastline           " Show as much as possible of the last line
set encoding=utf-8             " Set default encoding
set history=10000              " Maximum history record
set hlsearch                   " Highlight search terms
set incsearch                  " Find as you type search
set mouse=a                    " Automatically enable mouse usage
set smarttab                   " Smart tab
set ttyfast                    " Faster redrawing
set viminfo+=!                 " Viminfo include !
set wildmenu                   " Show list instead of just completing
set wildmode=longest:full,full
set timeoutlen=200
set ttimeoutlen=0
set cmdheight=1
set noshowmode
set noruler
set noshowcmd
set laststatus=0
set autochdir
set updatetime=300
set termguicolors
set colorcolumn=81

set exrc " allows using local init.vim with .exrc files

set ignorecase     " Case insensitive search
set smartcase      " ... but case sensitive when uc present
set scrolljump=5   " Line to scroll when cursor leaves screen
set scrolloff=3    " Minumum lines to keep above and below cursor
set shiftwidth=4   " Use indents of 4 spaces
set tabstop=4      " An indentation every four columns
set softtabstop=4  " Let backspace delete indent
set splitright     " Puts new vsplit windows to the right of the current
set splitbelow     " Puts new split windows to the bottom of the current
set autowrite      " Automatically write a file when leaving a modified buffer
set mousehide      " Hide the mouse cursor while typing
set hidden         " Allow buffer switching without saving
set showmatch      " Show matching brackets/parentthesis
set matchtime=1    " Show matching time
set linespace=0    " No extra spaces between rows
set pumheight=10   " Avoid the pop up menu occupying the whole screen
set expandtab      " Tabs are spaces, not tabs
set t_ut=
set winminheight=0
set whichwrap+=<,>,h,l  " Allow backspace and cursor keys to cross line boundaries
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set wildignore+=*swp,*.class,*.pyc,*.png,*.jpg,*.gif,*.zip
set wildignore+=*/tmp/*,*.o,*.obj,*.so     " Unix
set wildignore+=*\\tmp\\*,*.exe            " Windows
set showtabline=0
set signcolumn=yes

set nobackup
set noswapfile
set nowritebackup

" set foldenable
" set foldlevel=0
" set foldlevelstart=0

set background=dark         " Assume dark background
set cursorline              " Highlight current line
set fileformats=unix,dos,mac        " Use Unix as the standard file type
set number relativenumber                  " Line numbers on
set fillchars=vert:│,stl:\ ,stlnc:\ 

" Annoying temporary files
set directory=/tmp//,.
set backupdir=/tmp//,.

set clipboard=unnamedplus " allow using clipboard

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Undo
set undofile " Maintain undo history
set undodir=~/.config/nvim/undodir
set undolevels=1000      " Maximum number of changes that can be undone
set undoreload=10000     " Maximum number lines to save for undo on a buffer reload

" softwrapping
set linebreak
set spellsuggest=10

" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" dont conceal cursor on lines
" but do conceal otherwise
set conceallevel=2
set concealcursor=

" auto close preview window
autocmd CompleteDone * if !pumvisible() | pclose | endif
" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

let g:netrw_banner = 0
