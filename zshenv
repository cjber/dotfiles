export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
export KITTY_ENABLE_WAYLAND=1
export OLLAMA_API_BASE=http://127.0.0.1:11434
export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --color=always --hidden --follow -E .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border=sharp --color "border:#45475A,bg+:#1E1D2D" --prompt=": " --marker="." --pointer="|" --preview-window right:noborder --ansi'
export EDITOR='nvim'
export MANPAGER='nvim -c Man!'
export LANG="en_GB.UTF-8"
export npm_config_prefix="$HOME/.local"
export GOPATH="$HOME/.go"
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=Hyprland
export BROWSER="google-chrome-stable"
export GTK_THEME="Catppuccin-Mocha-Standard-Blue-Dark"

export PATH="/home/cjber/.bun/bin:$PATH"

path+=$GOPATH/bin
path+=$HOME/.cargo/bin
path+=$HOME/bin
path+=$HOME/.local/bin
path+=$HOME/.TinyTeX/bin/x86_64-linux
path+=$HOME/scripts
