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

status --is-interactive; and pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source

export PYTHON_CONFIGURE_OPTS="--enable-shared"

export SPARK_HOME=/usr/local/spark
export PYSPARK_DRIVER_PYTHON=ipython
export PYSPARK_PYTHON=python

function addpaths
    contains -- $argv $fish_user_paths
       or set -U fish_user_paths $fish_user_paths $argv
    echo "Updated PATH: $PATH"
end

function removepath
    if set -l index (contains -i $argv[1] $PATH)
        set --erase --universal fish_user_paths[$index]
        echo "Updated PATH: $PATH"
    else
        echo "$argv[1] not found in PATH: $PATH"
    end
end

set PATH /usr/local/spark/bin $PATH
set PATH /home/cjber/.cargo/bin $PATH
set PATH /home/cjber/.poetry/bin $PATH
set PATH /home/cjber/.local/bin $PATH

function poetry_shell --on-variable PWD
    if test -f pyproject.toml
        poetry shell
    end
end
