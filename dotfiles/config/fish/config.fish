fish_vi_key_bindings

# custom theme
set SPACEFISH_VI_MODE_SHOW false
#set SPACEFISH_CHAR_SYMBOL ">"

# alias
alias v="nvim"
alias lf="ranger"
alias vinit="nvim ~/.config/nvim/init.vim"
alias r="radian"
alias la="ncdu"
alias rm="trashf"
alias empty='echo -n Emptying the Bin | pv -qL 10 && command rm -rf ~/.local/share/Trash/files/*'
thefuck --alias | source

function sudo --description "Replacement for Bash 'sudo !!' command to run last command using sudo."
    if test "$argv" = !!
    eval command sudo $history[1]
else
    command sudo $argv
    end
end

status --is-interactive; and source (pyenv init -|psub)

starship init fish | source

# Your dotdrop git repository location
export DOTREPO="/home/cjber/dotfiles"

alias dotgit="git -C $DOTREPO"
alias dotsync="dotgit pull && dotgit add -A && dotgit commit && dotgit push; dotdrop install"
