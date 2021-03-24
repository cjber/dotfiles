# Start X at login
{%@@ if profile != "docker" @@%}
if status --is-interactive
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx -- -keeptty
  end
end
{%@@ endif @@%}

source ("/usr/bin/starship" init fish --print-full-init | psub)

fish_vi_key_bindings
set fish_greeting

# Set the cursor shapes for the different vi modes.
set fish_cursor_default     block      blink
set fish_cursor_insert      line       blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual      block

set fish_ambiguous_width    1

# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border=sharp'

# alias
alias v="nvim"
alias vf="nvim (fzf)"
alias lf="ranger"
alias vinit="cd ~/.config/nvim; nvim init.lua"
alias r="radian"
alias py="ipython"
alias la="ncdu"
alias rm="trashf"
alias empty='echo -n Emptying the Bin | pv -qL 10 && command rm -rf ~/.local/share/Trash/files/*'
alias conf="cd $HOME/dotfiles/; nvim (fzf)"
alias bat="bat --style=grid,numbers --theme TwoDark"

# Your dotdrop git repository location
export DOTREPO=$HOME/dotfiles

alias dotdrop='dotdrop --cfg=$HOME/dotfiles/config.yaml'
alias dotgit="git -C $DOTREPO"
alias dotsync="dotgit pull origin master && dotgit add -A && dotgit commit && dotgit push origin master; dotdrop install"

status --is-interactive; and pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source

export PYTHON_CONFIGURE_OPTS="--enable-shared"

function addpath
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

# function poetry_shell --on-variable PWD
#     if test -f pyproject.toml
#         poetry shell
#     end
# end

# use anaconda to source conda only when needed
# I use this because anaconda slows shell startup
function anaconda
    eval $HOME/.miniconda/bin/conda "shell.fish" "hook" $argv | source
end

function poetryreq
    for item in (cat requirements.txt); poetry add $item; end
end

function fish_right_prompt_loading_indicator
    echo (set_color '#aaa')' … '(set_color normal)
end
