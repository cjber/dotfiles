source /usr/share/zsh-antidote/antidote.zsh
antidote load

source ~/.zshalias

eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

KEYTIMEOUT=1

autoload -Uz compinit
compinit

zstyle '*:compinit' arguments -D -i -u -C -w
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors \
   "di=34" "ln=35" "so=32" "pi=33" "ex=31" "bd=34;46" "cd=34;43" \
   "su=30;41" "sg=30;46" "tw=30;42" "ow=30;43"
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

zstyle :compinstall filename '/home/cjber/.zshrc'

zstyle ':completion:*:descriptions' format '[%d]'

autoload -U zmv
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey -v '^?' backward-delete-char

# Change cursor shape: block for normal mode, line for insert mode.
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 == "block" ]]; then
        echo -ne "\e[2 q"
    else
        echo -ne "\e[6 q"
    fi
}

function zle-line-init {
    echo -ne "\e[6 q"
}

zle -N zle-keymap-select
zle -N zle-line-init


setopt extendedhistory histexpiredupsfirst histfindnodups histignoredups histignorespace histsavenodups histverify sharehistory
HISTFILE=~/.cache/history
HISTSIZE=100000
SAVEHIST=100000

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5c6370,bold,underline"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=#bb9af7,bold,underline"

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# zvm_bindkey vicmd '/' fzf-history-widget


function lf() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

eval "$(starship init zsh)"

# microsandbox needs libkrun on LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)"

export COMPOSIO_INSTALL_DIR=/home/cjber/.composio
export PATH="/home/cjber/.composio:$PATH"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

FNM_PATH="/home/cjber/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && $- == *i* ]] && command -v tmux &>/dev/null; then
  # tmux's socket already lives in /tmp/tmux-$UID, so unlike zellij there is no
  # XDG_RUNTIME_DIR split between PC mosh (systemd-logind sets XDG) and phone
  # mosh (does not) - both reach the same `main` session by name, and the
  # env -u workaround this block used to need is gone.
  #
  # -A: attach to `main` if it exists, create it otherwise.
  # -D: detach whichever client is already attached, so the NEWEST connection
  #     owns the size (tmux sizes a session to its smallest attached client).
  #     Detaching that client also ends its mosh-server, which is why the old
  #     pgrep/kill sweep for stale zellij clients is no longer needed.
  exec tmux new-session -A -D -s main
fi

# Claude Code: settings.json's `env` block only reaches spawned subprocesses
# (e.g. Bash tool calls), not the CLI's own process - so the autocompact
# percentage override has to be a real shell env var to take effect.
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=95

# cn: Claude on the NAS. Bare `cn` opens `claude agents`; anything else is
# passed through (`cn attach <id>`, `cn logs <id>`). -t for the TUI, bash -lc
# so ~/.local/bin (where claude lives) is on PATH; ${(q)@} survives the ssh hop.
function cn() {
	ssh -t nas "bash -lc ${(q)${:-claude ${(q)@:-agents}}}"
}

# Composio CLI
export COMPOSIO_INSTALL_DIR="/home/cjber/.composio"
export PATH="$COMPOSIO_INSTALL_DIR:$PATH"
export PATH=$PATH:$HOME/.maestro/bin

# Kiln persistent frecency repository picker (`kz`, and `z` if unclaimed).
eval "$(kiln shell-init)"

# >>> Codex installer >>>
export PATH="/home/cjber/.local/bin:$PATH"
# <<< Codex installer <<<
