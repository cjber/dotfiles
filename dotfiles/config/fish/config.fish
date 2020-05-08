fish_vi_key_bindings
set fish_greeting

# Set the cursor shapes for the different vi modes.
set fish_cursor_default     block      blink
set fish_cursor_insert      line       blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual      block


# alias
alias v="nvim"
alias f="nvim (fzf --height 40% --border --layout=reverse)"
alias c="cd (fd --type d | fzf --height 40% --border --layout=reverse)"
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


starship init fish | source

# Your dotdrop git repository location
export DOTREPO="/home/cjber/dotfiles"

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

set PATH /home/cjber/.gem/ruby/2.7.0/bin $PATH
