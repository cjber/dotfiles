fish_vi_key_bindings
set fish_greeting

# Set the cursor shapes for the different vi modes.
set fish_cursor_default     block      blink
set fish_cursor_insert      line       blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual      block

set fish_ambiguous_width    2

# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border=sharp'

# alias
alias v="nvim"
alias c="cd (fd --type d | fzf --height 40% --border --layout=reverse)"
alias lf="ranger"
alias vinit="nvim ~/.config/nvim/init.vim"
alias r="radian"
alias py="ipython"
alias la="ncdu"
alias rm="trashf"
alias empty='echo -n Emptying the Bin | pv -qL 10 && command rm -rf ~/.local/share/Trash/files/*'
alias conf="cd ~/dotfiles/dotfiles/"
alias bat="bat --style=grid,numbers --theme TwoDark"

starship init fish | source

# Your dotdrop git repository location
export DOTREPO="/home/cjber/dotfiles"
export DOTDROP_PROFILE=home

alias dotdrop='dotdrop --cfg=/home/cjber/dotfiles/config.yaml'
alias dotgit="git -C $DOTREPO"
alias dotsync="dotgit pull origin master && dotgit add -A && dotgit commit && dotgit push origin master; dotdrop install"

# pyenv
status --is-interactive; and source (pyenv init -|psub)
status --is-interactive; and pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source

#vim wiki
alias vw="nvim ~/drive/wiki/index.md"
alias enc="encfs ~/drive/data_enc ~/data"

export PYTHON_CONFIGURE_OPTS="--enable-shared"

export SPARK_HOME=/usr/local/spark
export PYSPARK_DRIVER_PYTHON=ptpython
export PYSPARK_PYTHON=python

set PATH /usr/local/spark/bin $PATH
set PATH /home/cjber/.cargo/bin $PATH
