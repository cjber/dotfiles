fish_vi_key_bindings
set fish_greeting

# Set the cursor shapes for the different vi modes.
set fish_cursor_default     block      blink
set fish_cursor_insert      line       blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual      block


# alias
alias v="nvim"
alias lf="ranger"
alias vinit="nvim ~/.config/nvim/init.vim"
alias r="radian"
alias la="ncdu"
alias rm="trashf"
alias empty='echo -n Emptying the Bin | pv -qL 10 && command rm -rf ~/.local/share/Trash/files/*'
thefuck --alias | source
alias conf="cd ~/dotfiles/dotfiles/"

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
